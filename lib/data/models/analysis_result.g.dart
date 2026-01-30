// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisResultAdapter extends TypeAdapter<AnalysisResult> {
  @override
  final int typeId = 1;

  @override
  AnalysisResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisResult(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      imagePath: fields[2] as String,
      totalScore: fields[3] as int,
      categoryScores: (fields[4] as Map).cast<String, int>(),
      deductions: (fields[5] as List).cast<String>(),
      fixes: (fields[6] as List).cast<String>(),
      styleTags: (fields[7] as List).cast<String>(),
      paletteHex: (fields[8] as List).cast<String>(),
      oneLineReview: fields[9] as String,
      presetId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisResult obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.totalScore)
      ..writeByte(4)
      ..write(obj.categoryScores)
      ..writeByte(5)
      ..write(obj.deductions)
      ..writeByte(6)
      ..write(obj.fixes)
      ..writeByte(7)
      ..write(obj.styleTags)
      ..writeByte(8)
      ..write(obj.paletteHex)
      ..writeByte(9)
      ..write(obj.oneLineReview)
      ..writeByte(10)
      ..write(obj.presetId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
