import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/datasources/local/hive_data_source.dart';
import '../../data/repositories/analysis_repository.dart';
import '../../data/models/analysis_result.dart';

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Hive DataSource Provider
final hiveDataSourceProvider = Provider<HiveDataSource>((ref) {
  throw UnimplementedError('HiveDataSource must be initialized in main()');
});

/// Analysis Repository Provider
final analysisRepositoryProvider = Provider<AnalysisRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final hiveDataSource = ref.watch(hiveDataSourceProvider);
  return AnalysisRepository(apiClient, hiveDataSource);
});

/// 분석 상태 Provider
class AnalysisState {
  final bool isLoading;
  final AnalysisResult? result;
  final String? error;

  AnalysisState({this.isLoading = false, this.result, this.error});

  AnalysisState copyWith({
    bool? isLoading,
    AnalysisResult? result,
    String? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : error,
    );
  }
}

/// 분석 실행 Provider
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AnalysisRepository _repository;

  AnalysisNotifier(this._repository) : super(AnalysisState());

  Future<void> analyze({
    required File imageFile,
    required String presetId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearResult: true,
    );

    try {
      final result = await _repository.analyzeImage(
        imageFile: imageFile,
        presetId: presetId,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        clearResult: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '분석 중 오류가 발생했습니다',
        clearResult: true,
      );
    }
  }

  void clearResult() {
    state = AnalysisState();
  }
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) {
    final repository = ref.watch(analysisRepositoryProvider);
    return AnalysisNotifier(repository);
  },
);
