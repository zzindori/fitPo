import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../datasources/remote/api_client.dart';
import '../datasources/local/hive_data_source.dart';
import '../models/analysis_result.dart';

class AnalysisRepository {
  final ApiClient _apiClient;
  final HiveDataSource _localDataSource;
  final _uuid = const Uuid();

  AnalysisRepository(this._apiClient, this._localDataSource);

  /// 패션 분석 실행
  Future<AnalysisResult> analyzeImage({
    required File imageFile,
    required String presetId,
  }) async {
    try {
      // 1. API 호출
      debugPrint('[DEBUG] Repository: Calling API...');
      final responseData = await _apiClient.analyzeFashion(
        imageFile: imageFile,
        presetId: presetId,
      );
      debugPrint('[DEBUG] Repository: API Response - $responseData');

      // 2. AnalysisResult 객체 생성
      debugPrint(
        '[DEBUG] Repository: Creating AnalysisResult from response...',
      );
      final result = AnalysisResult.fromJson(
        responseData,
        id: _uuid.v4(),
        imagePath: imageFile.path,
        presetId: presetId,
      );
      debugPrint('[DEBUG] Repository: AnalysisResult created successfully');

      // 3. 로컬 저장 (Hive 어댑터 미등록 시 스킵)
      try {
        debugPrint('[DEBUG] Repository: Saving to local storage...');
        await _localDataSource.saveAnalysisResult(result);
        debugPrint('[DEBUG] Repository: Saved successfully');
      } catch (saveError) {
        debugPrint(
          '[WARN] Repository: Failed to save locally, but returning result anyway',
        );
      }

      return result;
    } catch (e, stackTrace) {
      debugPrint('[ERROR] Repository Error: $e');
      debugPrint('[ERROR] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// 히스토리 목록 가져오기
  List<AnalysisResult> getHistory() {
    return _localDataSource.getAllHistory();
  }

  /// 특정 결과 조회
  AnalysisResult? getResultById(String id) {
    return _localDataSource.getResult(id);
  }

  /// 결과 삭제
  Future<void> deleteResult(String id) async {
    await _localDataSource.deleteResult(id);
  }

  /// 전체 히스토리 삭제
  Future<void> clearHistory() async {
    await _localDataSource.clearAllHistory();
  }
}
