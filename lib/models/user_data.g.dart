// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      id: fields[0] as String,
      username: fields[1] as String,
      phoneSerialNumber: fields[2] as String,
      appAccess: fields[3] as bool,
      normalPassword: fields[4] as String,
      specialPassword: fields[5] as String,
      hiddenApps: (fields[6] as Map).cast<String, String>(),
      version: fields[7] as int,
      lastUpdated: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.phoneSerialNumber)
      ..writeByte(3)
      ..write(obj.appAccess)
      ..writeByte(4)
      ..write(obj.normalPassword)
      ..writeByte(5)
      ..write(obj.specialPassword)
      ..writeByte(6)
      ..write(obj.hiddenApps)
      ..writeByte(7)
      ..write(obj.version)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
