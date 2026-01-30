import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_result.dart';
import 'analysis_provider.dart';

/// 히스토리 목록 Provider
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<AnalysisResult>>((ref) {
      final repository = ref.watch(analysisRepositoryProvider);
      return HistoryNotifier(repository);
    });

class HistoryNotifier extends StateNotifier<List<AnalysisResult>> {
  final dynamic _repository;

  HistoryNotifier(this._repository) : super([]) {
    loadHistory();
  }

  void loadHistory() {
    state = _repository.getHistory();
  }

  Future<void> deleteResult(String id) async {
    await _repository.deleteResult(id);
    loadHistory();
  }

  Future<void> clearAll() async {
    await _repository.clearHistory();
    state = [];
  }
}
