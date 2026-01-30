import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_preset.dart';

/// 프리셋 로딩 Provider
final presetsProvider = FutureProvider<List<AnalysisPreset>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/presets/presets.json');
  final jsonData = json.decode(jsonString);
  final presetsList = jsonData['presets'] as List;

  return presetsList.map((json) => AnalysisPreset.fromJson(json)).toList();
});

/// 선택된 프리셋 Provider (기본값: minimal)
final selectedPresetProvider = StateProvider<String>((ref) => 'minimal');

/// 현재 선택된 프리셋 객체를 반환하는 Provider
final currentPresetProvider = Provider<AnalysisPreset?>((ref) {
  final presetsAsync = ref.watch(presetsProvider);
  final selectedId = ref.watch(selectedPresetProvider);

  return presetsAsync.whenData((presets) {
    return presets.firstWhere(
      (preset) => preset.id == selectedId,
      orElse: () => presets.first,
    );
  }).value;
});
