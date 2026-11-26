// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogEntryAdapter extends TypeAdapter<LogEntry> {
  @override
  final int typeId = 1;

  @override
  LogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogEntry(
      username: fields[0] as String,
      dateTime: fields[1] as DateTime,
      note: fields[2] as String,
      lat: fields[3] as double?,
      lng: fields[4] as double?,
      address: fields[5] as String?,
      condition: fields[6] as String?,
      symptoms: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, LogEntry obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.lat)
      ..writeByte(4)
      ..write(obj.lng)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.condition)
      ..writeByte(7)
      ..write(obj.symptoms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
