// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptAdapter extends TypeAdapter<Receipt> {
  @override
  final int typeId = 1;

  @override
  Receipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receipt(
      id: fields[0] as String?,
      purchaseDate: fields[1] as DateTime?,
      items: (fields[2] as List).cast<GroceryItem>(),
      groupType: fields[3] as GroupType,
      numberOfPeople: fields[4] as int,
      paidBy: fields[5] as String?,
      paidUsers: (fields[6] as Map?)?.cast<String, bool>(),
      discount: fields[7] as double?,
      userNames: (fields[8] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Receipt obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.purchaseDate)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.groupType)
      ..writeByte(4)
      ..write(obj.numberOfPeople)
      ..writeByte(5)
      ..write(obj.paidBy)
      ..writeByte(6)
      ..write(obj.paidUsers)
      ..writeByte(7)
      ..write(obj.discount)
      ..writeByte(8)
      ..write(obj.userNames);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
