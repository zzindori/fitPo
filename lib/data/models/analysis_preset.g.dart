// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_preset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalysisPresetAdapter extends TypeAdapter<AnalysisPreset> {
  @override
  final int typeId = 0;

  @override
  AnalysisPreset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalysisPreset(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      promptStyleRules: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AnalysisPreset obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.promptStyleRules);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisPresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
