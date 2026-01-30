const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);

/**
 * Google Gemini 2.0 Flash를 사용한 패션 분석
 */
async function analyzeWithGemini(imagePath, preset) {
  // 이미지를 base64로 인코딩
  const imageBuffer = fs.readFileSync(imagePath);
  const base64Image = imageBuffer.toString('base64');

  // 시스템 프롬프트 (공통 규칙)
  const systemPrompt = `
당신은 냉정하고 솔직한 패션 평가 전문가입니다.
과한 칭찬은 금지되며, 모호한 표현 없이 단호하게 평가합니다.

평가 규칙:
- 총점: 0~100점 (냉정하게 매기되, 평균은 60~75점)
- categoryScores: 각 항목별 0~20점
  * fit_silhouette: 핏과 실루엣
  * color_harmony: 컬러 조화
  * composition_layering: 구성과 레이어링
  * tpo_appropriateness: TPO 적합성
  * details_points: 디테일과 포인트
  * overall_cohesion: 전체 완성도
- deductions: 최대 5개의 감점 사유 (짧고 단호하게)
- fixes: 정확히 3개의 즉시 개선 방법 (구체적으로)
- styleTags: 3~6개의 스타일 태그
- paletteHex: 3~6개의 HEX 컬러 코드 (#RRGGBB)
- oneLineReview: 한 줄 총평 (냉정한 톤)

프리셋별 추가 규칙: ${preset.rules}

**출력은 반드시 아래 JSON 형식만 반환하고, 다른 설명은 절대 포함하지 마세요.**
`;

  const userPrompt = `
위 사진 속 패션 코디를 평가해주세요.

반환 형식 (JSON만):
{
  "totalScore": 78,
  "categoryScores": {
    "fit_silhouette": 16,
    "color_harmony": 14,
    "composition_layering": 12,
    "tpo_appropriateness": 14,
    "details_points": 10,
    "overall_cohesion": 12
  },
  "deductions": [
    "상의 기장이 애매해서 비율이 끊긴다",
    "신발 톤이 바지와 연결이 약하다"
  ],
  "fixes": [
    "상의는 2~3cm 더 짧게(또는 바지를 하이웨이스트로)",
    "신발을 상의와 같은 톤(화이트/오프화이트)으로 맞추기",
    "가방/시계 중 하나만 남기고 포인트를 하나로"
  ],
  "styleTags": ["minimal", "city", "clean", "monotone"],
  "paletteHex": ["#111111", "#F2F2F2", "#8A8A8A"],
  "oneLineReview": "깔끔한데 비율이 끊겨서 완성도가 떨어진다."
}
`;

  try {
    // Gemini 2.0 Flash 모델 사용
    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.0-flash-exp',
      generationConfig: {
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 2048,
      },
    });

    const result = await model.generateContent([
      systemPrompt + '\n\n' + userPrompt,
      {
        inlineData: {
          mimeType: 'image/jpeg',
          data: base64Image,
        },
      },
    ]);

    const response = await result.response;
    const content = response.text();

    // JSON 파싱 시도
    let parsedResult;
    try {
      // Gemini가 ```json ... ``` 형식으로 반환할 경우 처리
      const jsonMatch = content.match(/```json\n([\s\S]*?)\n```/) || 
                        content.match(/```\n([\s\S]*?)\n```/);
      
      if (jsonMatch) {
        parsedResult = JSON.parse(jsonMatch[1]);
      } else {
        parsedResult = JSON.parse(content);
      }
    } catch (parseError) {
      console.error('JSON 파싱 실패:', content);
      throw new Error('AI 응답을 파싱할 수 없습니다');
    }

    // 필수 필드 검증
    validateResult(parsedResult);

    return parsedResult;
  } catch (error) {
    console.error('Gemini API 오류:', error);
    throw error;
  }
}

/**
 * 결과 검증
 */
function validateResult(result) {
  const requiredFields = [
    'totalScore',
    'categoryScores',
    'deductions',
    'fixes',
    'styleTags',
    'paletteHex',
    'oneLineReview',
  ];

  for (const field of requiredFields) {
    if (!(field in result)) {
      throw new Error(`필수 필드 누락: ${field}`);
    }
  }

  // categoryScores 검증
  const requiredCategories = [
    'fit_silhouette',
    'color_harmony',
    'composition_layering',
    'tpo_appropriateness',
    'details_points',
    'overall_cohesion',
  ];

  for (const category of requiredCategories) {
    if (!(category in result.categoryScores)) {
      throw new Error(`categoryScores에 ${category} 누락`);
    }
  }

  // fixes는 정확히 3개
  if (result.fixes.length !== 3) {
    throw new Error('fixes는 정확히 3개여야 합니다');
  }
}

module.exports = { analyzeWithGemini };
