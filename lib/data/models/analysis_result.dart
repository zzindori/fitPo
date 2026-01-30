import 'package:hive/hive.dart';

part 'analysis_result.g.dart';

@HiveType(typeId: 1)
class AnalysisResult {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime createdAt;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final int totalScore;

  @HiveField(4)
  final Map<String, int> categoryScores;

  @HiveField(5)
  final List<String> deductions;

  @HiveField(6)
  final List<String> fixes;

  @HiveField(7)
  final List<String> styleTags;

  @HiveField(8)
  final List<String> paletteHex;

  @HiveField(9)
  final String oneLineReview;

  @HiveField(10)
  final String? presetId;

  AnalysisResult({
    required this.id,
    required this.createdAt,
    required this.imagePath,
    required this.totalScore,
    required this.categoryScores,
    required this.deductions,
    required this.fixes,
    required this.styleTags,
    required this.paletteHex,
    required this.oneLineReview,
    this.presetId,
  });

  factory AnalysisResult.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String imagePath,
    String? presetId,
  }) {
    return AnalysisResult(
      id: id,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      totalScore: json['totalScore'] as int,
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      deductions: List<String>.from(json['deductions'] as List),
      fixes: List<String>.from(json['fixes'] as List),
      styleTags: List<String>.from(json['styleTags'] as List),
      paletteHex: List<String>.from(json['paletteHex'] as List),
      oneLineReview: json['oneLineReview'] as String,
      presetId: presetId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'totalScore': totalScore,
      'categoryScores': categoryScores,
      'deductions': deductions,
      'fixes': fixes,
      'styleTags': styleTags,
      'paletteHex': paletteHex,
      'oneLineReview': oneLineReview,
      'presetId': presetId,
    };
  }

  // Category 이름을 한글로 변환 (표현 데이터이지만 UI 헬퍼로 분리)
  static const Map<String, String> categoryNameMap = {
    'fit_silhouette': '핏/실루엣',
    'color_harmony': '컬러 조화',
    'composition_layering': '구성/레이어링',
    'tpo_appropriateness': 'TPO 적합성',
    'details_points': '디테일/포인트',
    'overall_cohesion': '전체 완성도',
  };
}
