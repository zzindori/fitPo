import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ApiClient {
  late final GenerativeModel _model;

  static const String apiKey = 'AIzaSyABLPPyAy0xQEMLnIzwzczgStDuYrutlsw';

  ApiClient() {
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  /// 패션 분석 API 호출 (Google Gemini 직접 호출)
  Future<Map<String, dynamic>> analyzeFashion({
    required File imageFile,
    required String presetId,
  }) async {
    try {
      debugPrint('[DEBUG] Starting fashion analysis...');

      // 이미지 파일 확인
      if (!await imageFile.exists()) {
        throw ApiException('이미지 파일을 찾을 수 없습니다', 400);
      }
      debugPrint('[DEBUG] Image file exists: ${imageFile.path}');

      // 이미지를 base64로 인코딩
      final imageBytes = await imageFile.readAsBytes();
      debugPrint('[DEBUG] Image bytes read: ${imageBytes.length} bytes');

      final base64Image = base64Encode(imageBytes);
      debugPrint('[DEBUG] Image encoded to base64');

      // 프리셋별 규칙
      final presetRules = _getPresetRules(presetId);

      final systemPrompt =
          '''당신은 냉정하고 솔직한 패션 평가 전문가입니다.
과한 칭찬은 금지되며, 모호한 표현 없이 단호하게 평가합니다.

평가 규칙:
- 총점: 0~100점
- categoryScores: 각 항목별 0~20점
- deductions: 최대 5개의 감점 사유
- fixes: 정확히 3개의 즉시 개선 방법
- styleTags: 3~6개의 스타일 태그
- paletteHex: 3~6개의 HEX 컬러 코드 (#RRGGBB)
- oneLineReview: 한 줄 총평

프리셋: $presetRules

출력: JSON만 반환하세요.''';

      final userPrompt = '''패션 코디를 평가해주세요.
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
  "deductions": ["감점1", "감점2"],
  "fixes": ["개선1", "개선2", "개선3"],
  "styleTags": ["tag1", "tag2"],
  "paletteHex": ["#000000", "#FFFFFF"],
  "oneLineReview": "평가"
}''';

      // Gemini API 호출
      debugPrint('[DEBUG] Calling Gemini API...');
      final response = await _model.generateContent([
        Content.text(systemPrompt),
        Content.multi([
          TextPart(userPrompt),
          DataPart('image/jpeg', base64Decode(base64Image)),
        ]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw ApiException('AI 응답이 없습니다', 500);
      }

      // API 응답 로깅
      final content = response.text!;
      debugPrint('[DEBUG] API Response received: ${content.length} characters');
      debugPrint('[DEBUG] Response: $content');

      // JSON 추출 (여러 형식 지원)
      late String jsonString;

      // 1. ```json ... ``` 형식 확인
      var jsonMatch = RegExp(r'```json\n([\s\S]*?)\n```').firstMatch(content);
      if (jsonMatch != null) {
        jsonString = jsonMatch.group(1) ?? '';
        debugPrint('[DEBUG] JSON found in ```json format');
      } else {
        // 2. ``` ... ``` 형식 확인
        jsonMatch = RegExp(r'```\n([\s\S]*?)\n```').firstMatch(content);
        if (jsonMatch != null) {
          jsonString = jsonMatch.group(1) ?? '';
          debugPrint('[DEBUG] JSON found in ``` format');
        } else {
          // 3. { ... } 형식 확인
          jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
          if (jsonMatch != null) {
            jsonString = jsonMatch.group(0) ?? '';
            debugPrint('[DEBUG] JSON found in { } format');
          } else {
            // 4. 전체가 JSON인 경우
            jsonString = content;
            debugPrint('[DEBUG] Using entire response as JSON');
          }
        }
      }

      debugPrint('[DEBUG] Extracted JSON: $jsonString');

      // JSON 파싱
      late Map<String, dynamic> result;
      try {
        result = jsonDecode(jsonString) as Map<String, dynamic>;
        debugPrint('[DEBUG] JSON parsing successful');
      } catch (parseError) {
        debugPrint('[ERROR] JSON Parse Error: $parseError');
        debugPrint('[ERROR] Attempted to parse: $jsonString');
        throw ApiException('AI 응답을 분석할 수 없습니다. 응답 형식이 잘못되었습니다.', 500);
      }

      // 결과 검증
      debugPrint('[DEBUG] Validating result...');
      _validateResult(result);
      debugPrint('[DEBUG] Validation successful');

      return result;
    } on ApiException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('[ERROR] Analysis Error: $e');
      debugPrint('[ERROR] Stack trace: $stackTrace');
      throw ApiException('분석 중 오류가 발생했습니다: $e', 0);
    }
  }

  String _getPresetRules(String presetId) {
    switch (presetId) {
      case 'street':
        return '''스트릿 스타일 평가 기준:
- 좋은 점: 포인트 컬러(색감), 로고, 통통한 핏, 운동화 매칭, 여러 겹 입기(레이어링)
- 나쁜 점: 밋밋한 색상, 정확한 정장 같은 핏
- 강조: 개성 있고 자유로운 느낌''';
      case 'formal':
        return '''포멀 스타일 평가 기준:
- 좋은 점: 절제된 색상(검정/네이비/회색), 몸에 맞는 정확한 핏, 신발/벨트/가방이 격식 있게 어울림
- 나쁜 점: 캐주얼한 요소, 밝은 색상, 캐릭터나 큰 로고
- 강조: 깔끔하고 정중한 분위기''';
      default:
        return '''미니멀 스타일 평가 기준:
- 좋은 점: 색상 조화(톤온톤), 깨끗한 느낌, 정돈된 디테일
- 나쁜 점: 큰 로고, 과한 색 조합, 너무 많은 악세서리
- 강조: 간단하고 우아한 느낌''';
    }
  }

  void _validateResult(Map<String, dynamic> result) {
    const requiredFields = [
      'totalScore',
      'categoryScores',
      'deductions',
      'fixes',
      'styleTags',
      'paletteHex',
      'oneLineReview',
    ];

    for (final field in requiredFields) {
      if (!result.containsKey(field)) {
        throw ApiException('필수 필드 누락: $field', 500);
      }
    }

    const requiredCategories = [
      'fit_silhouette',
      'color_harmony',
      'composition_layering',
      'tpo_appropriateness',
      'details_points',
      'overall_cohesion',
    ];

    final categoryScores = result['categoryScores'] as Map<String, dynamic>;
    for (final category in requiredCategories) {
      if (!categoryScores.containsKey(category)) {
        throw ApiException('categoryScores에 $category 누락', 500);
      }
    }

    final fixes = result['fixes'] as List<dynamic>;
    if (fixes.length != 3) {
      throw ApiException('fixes는 정확히 3개여야 합니다', 500);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
