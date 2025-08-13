// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupTypeAdapter extends TypeAdapter<GroupType> {
  @override
  final int typeId = 3;

  @override
  GroupType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GroupType.groceries;
      case 1:
        return GroupType.utilities;
      case 2:
        return GroupType.rent;
      case 3:
        return GroupType.other;
      default:
        return GroupType.groceries;
    }
  }

  @override
  void write(BinaryWriter writer, GroupType obj) {
    switch (obj) {
      case GroupType.groceries:
        writer.writeByte(0);
        break;
      case GroupType.utilities:
        writer.writeByte(1);
        break;
      case GroupType.rent:
        writer.writeByte(2);
        break;
      case GroupType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
