const express = require('express');
const multer = require('multer');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');
const sharp = require('sharp');
require('dotenv').config();

const { analyzeWithGemini } = require('./aiService');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Multer 설정 (이미지 업로드)
const upload = multer({
  dest: 'uploads/',
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('이미지 파일만 업로드 가능합니다'));
    }
  },
});

// 프리셋 정의 (JSON에서 로드하거나 여기서 하드코딩)
const PRESETS = {
  minimal: {
    id: 'minimal',
    name: '미니멀 기준',
    rules: '과한 로고, 강한 색 대비, 잡다한 액세서리는 감점. 톤온톤 조화, 여백감, 절제된 디테일은 가산.',
  },
  street: {
    id: 'street',
    name: '스트릿 기준',
    rules: '포인트 컬러, 로고, 오버핏 허용. 실루엣의 힘, 스니커 매칭, 레이어링 완성도 강조.',
  },
  formal: {
    id: 'formal',
    name: '포멀 기준',
    rules: '컬러는 절제, 핏의 정확성, 신발/벨트/가방의 격식 매칭 중시. 캐주얼 요소는 감점.',
  },
};

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 패션 분석 API
app.post('/analyze', upload.single('image'), async (req, res) => {
  let imagePath = null;

  try {
    if (!req.file) {
      return res.status(400).json({ error: '이미지 파일이 필요합니다' });
    }

    const { preset_id = 'minimal' } = req.body;
    imagePath = req.file.path;

    // 이미지 리사이징 (API 비용 절감)
    const resizedPath = `${imagePath}_resized.jpg`;
    await sharp(imagePath)
      .resize(1024, 1024, { fit: 'inside' })
      .jpeg({ quality: 85 })
      .toFile(resizedPath);

    // 프리셋 로드
    const preset = PRESETS[preset_id] || PRESETS.minimal;

    // AI 분석 호출
    const result = await analyzeWithGemini(resizedPath, preset);

    // 임시 파일 삭제
    await fs.unlink(imagePath);
    await fs.unlink(resizedPath);

    res.json(result);
  } catch (error) {
    console.error('분석 오류:', error);

    // 임시 파일 삭제
    if (imagePath) {
      try {
        await fs.unlink(imagePath);
      } catch (e) {
        // 무시
      }
    }

    res.status(500).json({
      error: '분석 중 오류가 발생했습니다',
      message: error.message,
    });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
