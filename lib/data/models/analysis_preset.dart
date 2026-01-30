import 'package:hive/hive.dart';

part 'analysis_preset.g.dart';

@HiveType(typeId: 0)
class AnalysisPreset {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String promptStyleRules;

  AnalysisPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.promptStyleRules,
  });

  factory AnalysisPreset.fromJson(Map<String, dynamic> json) {
    return AnalysisPreset(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      promptStyleRules: json['promptStyleRules'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'promptStyleRules': promptStyleRules,
    };
  }
}
