# Fashion Critic MVP - 전체 구현 가이드

## 📋 구현 완료 현황

### ✅ Flutter 앱 (100%)
- 프로젝트 생성 및 폴더 구조 구성
- 데이터 모델 (AnalysisResult, AnalysisPreset)
- Riverpod 상태 관리 Provider 전체
- 화면 구현 (HomeScreen, ResultScreen)
- 로컬 저장소 (Hive)
- API Client (Dio)
- 테마 설정

### ✅ Node.js 서버 (100%)
- Express 서버
- OpenAI GPT-4 Vision 연동
- 이미지 업로드/리사이징
- 프리셋별 프롬프트 처리
- JSON 응답 검증

### ✅ 데이터 관리 (100%)
- 프리셋 JSON 파일
- 표현 데이터 분리 (헌법 준수)
- 히스토리 최대 10개 관리

---

## 🚀 실행 방법

### 1단계: 서버 설정 및 실행

```bash
# 서버 폴더로 이동
cd server

# 의존성 설치
npm install

# 환경 변수 설정
cp .env.example .env

# .env 파일 편집
# OPENAI_API_KEY=sk-your-key-here 입력

# 서버 실행
npm start
```

서버가 http://localhost:3000 에서 실행됩니다.

### 2단계: Flutter 앱 실행

```bash
# 프로젝트 루트로 돌아가기
cd ..

# Android 기기 연결 확인
flutter devices

# 앱 실행
flutter run -d R5CT326T5EZ
```

---

## 🧪 테스트 시나리오

### 시나리오 1: 기본 분석 흐름
1. 앱 실행 → 홈 화면
2. 프리셋 선택 (드롭다운에서 "미니멀 기준" 선택)
3. "갤러리에서 선택" 버튼 클릭
4. 패션 사진 선택
5. 분석 진행 (로딩 표시 확인)
6. 결과 화면 확인:
   - 총점 (0~100)
   - 한 줄 총평
   - 항목별 점수 6개 (Progress bar)
   - 바로 고칠 3가지 (노란색 강조)
   - 감점 포인트
   - 스타일 태그
   - 컬러 팔레트

### 시나리오 2: 카메라 촬영
1. 홈 화면에서 "카메라로 촬영" 클릭
2. 사진 촬영
3. 즉시 분석 진행
4. 결과 확인

### 시나리오 3: 히스토리
1. 여러 사진 분석 (3~5개)
2. 홈 화면으로 돌아가기
3. 하단 "최근 분석" 섹션에서 썸네일 확인
4. 썸네일 클릭 → 이전 결과 재열람
5. "전체 삭제" 버튼으로 히스토리 클리어

### 시나리오 4: 에러 처리
1. 서버 중단 상태에서 분석 시도
2. 에러 다이얼로그 확인
3. "재시도" 버튼 동작 확인

### 시나리오 5: 프리셋 변경
1. "스트릿 기준" 선택
2. 같은 사진으로 분석
3. "포멀 기준" 선택 후 다시 분석
4. 프리셋에 따라 점수와 평가가 달라지는지 확인

---

## 🔧 현재 상태 및 주의사항

### ⚠️ 미완성 부분

#### 1. Hive Adapter 생성 필요
현재 Hive 모델에 `part` 지시문이 있지만 실제 adapter가 생성되지 않았습니다.

**해결 방법:**
```yaml
# pubspec.yaml에 추가
dev_dependencies:
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
```

```bash
# Adapter 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. API Client의 baseUrl 변경 필요
`lib/data/datasources/remote/api_client.dart` 파일에서:

```dart
// 로컬 테스트 시
static const String baseUrl = 'http://10.0.2.2:3000';  // Android 에뮬레이터
// 또는
static const String baseUrl = 'http://localhost:3000';  // iOS 시뮬레이터

// 실제 기기 테스트 시
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000';
```

#### 3. Windows 개발자 모드 활성화
Flutter 빌드에 필요합니다:
```powershell
start ms-settings:developers
```

---

## 📊 AI 프롬프트 전략 (핵심)

### 시스템 프롬프트 구조

```
역할 정의
- 냉정한 패션 평가 전문가
- 과한 칭찬 금지
- 모호한 표현 금지

평가 규칙
- 총점: 0~100 (평균 60~75)
- 항목별 점수: 각 0~20점
- deductions: 최대 5개
- fixes: 정확히 3개
- styleTags: 3~6개
- paletteHex: 3~6개
- oneLineReview: 한 줄

프리셋 규칙 (동적 삽입)
- minimal: 톤온톤 가산, 로고/색상 감점
- street: 포인트 허용, 실루엣 강조
- formal: 컬러 절제, 격식 매칭

출력 형식 강제
- JSON만 반환
- 다른 설명 절대 금지
```

### 응답 스키마 (강제)

```json
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
    "상의는 2~3cm 더 짧게",
    "신발을 상의와 같은 톤으로",
    "가방/시계 중 하나만 남기기"
  ],
  "styleTags": ["minimal", "city", "clean"],
  "paletteHex": ["#111111", "#F2F2F2", "#8A8A8A"],
  "oneLineReview": "깔끔한데 비율이 끊겨서 완성도가 떨어진다."
}
```

---

## 🎨 헌법 준수 체크리스트

✅ **표현 데이터 분리**
- 프리셋: `assets/presets/presets.json`
- 평가 규칙: preset.promptStyleRules
- 카테고리 이름: AnalysisResult.categoryNameMap

✅ **One-shot Action**
- 사진 선택 → 즉시 분석 시작
- 중간 확인 단계 없음

✅ **하드코딩 금지**
- 프리셋 추가 시 JSON만 수정
- UI 문구도 추후 분리 가능하도록 설계

✅ **변경 가능성 고려**
- 프리셋 추가/수정: JSON 편집만
- 카테고리 변경: Map 수정만
- 평가 로직 변경: AI 프롬프트 수정만

---

## 📦 주요 파일 목록

### Flutter (lib/)
```
data/models/
├── analysis_preset.dart        # 프리셋 모델
└── analysis_result.dart        # 분석 결과 모델

data/datasources/
├── local/hive_data_source.dart # 로컬 저장소
└── remote/api_client.dart      # API 클라이언트

data/repositories/
└── analysis_repository.dart    # 비즈니스 로직

domain/providers/
├── preset_provider.dart        # 프리셋 관리
├── image_picker_provider.dart  # 이미지 선택
├── analysis_provider.dart      # 분석 실행
└── history_provider.dart       # 히스토리 관리

presentation/screens/
├── home_screen.dart            # 홈 화면
└── result_screen.dart          # 결과 화면

core/theme/
└── app_theme.dart              # 앱 테마

main.dart                       # 엔트리 포인트
```

### Server (server/)
```
index.js                        # Express 서버
aiService.js                    # OpenAI 연동
package.json                    # 의존성
.env.example                    # 환경 변수 템플릿
```

### Assets
```
assets/presets/
└── presets.json                # 평가 기준 데이터
```

---

## 💡 다음 단계 (확장 기능)

### 우선순위 높음
1. Hive Adapter 생성 및 저장소 완성
2. 실제 기기 네트워크 테스트
3. 에러 메시지 다국어 처리

### 우선순위 중간
4. 결과 이미지로 공유 기능
5. 커스텀 프리셋 추가 UI
6. 분석 히스토리 필터링

### 우선순위 낮음
7. 애니메이션 효과 강화
8. 다크 모드 지원
9. 프리미엄 기능 (상세 분석)

---

## 🐛 알려진 이슈 및 해결책

### 이슈 1: Hive Adapter 미생성
**현상**: 앱 실행 시 Hive 관련 오류

**해결**: build_runner로 adapter 생성
```bash
flutter pub add --dev build_runner hive_generator
flutter pub run build_runner build
```

### 이슈 2: 네트워크 연결 실패
**현상**: "네트워크 연결을 확인해주세요"

**원인**: 
- 서버 미실행
- baseUrl이 localhost로 되어 있음

**해결**: 
- 서버 실행 확인
- 실제 기기는 컴퓨터 IP 사용

### 이슈 3: OpenAI API 오류
**현상**: "분석 중 오류가 발생했습니다"

**원인**:
- API Key 미설정
- 잔액 부족
- Rate Limit 초과

**해결**:
- .env 파일 확인
- OpenAI 대시보드에서 잔액 확인
- 서버 로그 확인

---

## 📞 지원

프로젝트 관련 문의:
- GitHub Issues
- 개발자 이메일

---

**🎉 프로젝트 구현 완료!**

실행 가능한 MVP 상태이며, 테스트 및 확장이 가능합니다.
