import 'package:hive_flutter/hive_flutter.dart';
import '../../models/analysis_result.dart';

class HiveDataSource {
  static const String _historyBoxName = 'fashion_history';
  static const int _maxHistoryCount = 10;

  late Box<AnalysisResult> _historyBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Hive Adapter 등록 (build_runner로 생성된 adapter 사용)
    // Hive.registerAdapter(AnalysisResultAdapter());
    // Hive.registerAdapter(AnalysisPresetAdapter());
    
    _historyBox = await Hive.openBox<AnalysisResult>(_historyBoxName);
  }

  /// 분석 결과 저장 (최신 10개만 유지)
  Future<void> saveAnalysisResult(AnalysisResult result) async {
    await _historyBox.put(result.id, result);
    
    // 10개 초과 시 가장 오래된 항목 삭제
    if (_historyBox.length > _maxHistoryCount) {
      final sortedKeys = _historyBox.keys.toList()
        ..sort((a, b) {
          final aResult = _historyBox.get(a);
          final bResult = _historyBox.get(b);
          return aResult!.createdAt.compareTo(bResult!.createdAt);
        });
      
      await _historyBox.delete(sortedKeys.first);
    }
  }

  /// 전체 히스토리 가져오기 (최신순)
  List<AnalysisResult> getAllHistory() {
    final results = _historyBox.values.toList();
    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  /// 특정 결과 가져오기
  AnalysisResult? getResult(String id) {
    return _historyBox.get(id);
  }

  /// 특정 결과 삭제
  Future<void> deleteResult(String id) async {
    await _historyBox.delete(id);
  }

  /// 전체 히스토리 삭제
  Future<void> clearAllHistory() async {
    await _historyBox.clear();
  }
}
