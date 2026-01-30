# Fashion Critic - 냉정한 패션 평가 앱

패션 사진 한 장으로 즉시 AI 기반 코디 평가를 받는 모바일 앱입니다.

## 🎯 주요 기능

- 📸 **카메라 촬영 또는 갤러리 선택**: 즉시 분석 시작
- 🤖 **AI 기반 냉정한 평가**: 점수, 감점 포인트, 개선안 제공
- 📊 **항목별 점수**: 핏/실루엣, 컬러 조화, 레이어링 등 6가지
- 💡 **즉시 개선 3가지**: 바로 고칠 수 있는 구체적인 액션 아이템
- 🎨 **스타일 태그 & 컬러 팔레트**: 스타일 분석 및 컬러 추출
- 📚 **히스토리**: 최근 10개 분석 결과 저장
- ⚙️ **프리셋 선택**: 미니멀/스트릿/포멀 등 평가 기준 변경

## 🚀 빠른 시작

### 1. 서버 실행
```bash
cd server
npm install
cp .env.example .env
# .env에 OPENAI_API_KEY 입력
npm start
```

### 2. 앱 실행
```bash
cd ..
flutter pub get
flutter run
```

## 📱 사용 방법

1. 홈 화면에서 평가 기준 선택 (미니멀/스트릿/포멀)
2. 카메라 촬영 또는 갤러리에서 사진 선택
3. AI 분석 완료 후 결과 확인
4. 최근 분석 내역은 하단에 자동 저장

## 🏗️ 프로젝트 구조

```
fashion_critic/
├── lib/                    # Flutter 앱
│   ├── data/              # 데이터 레이어
│   ├── domain/            # 비즈니스 로직 (Riverpod)
│   ├── presentation/      # UI
│   └── core/              # 공통 설정
├── server/                 # Node.js 서버
│   ├── index.js           # Express 서버
│   ├── aiService.js       # OpenAI 연동
│   └── package.json
└── assets/
    └── presets/           # 평가 기준 JSON
```

자세한 내용은 프로젝트 폴더의 문서를 참고하세요.
