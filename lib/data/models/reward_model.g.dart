// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RewardModelAdapter extends TypeAdapter<RewardModel> {
  @override
  final int typeId = 2;

  @override
  RewardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RewardModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      requiredPoints: fields[3] as int,
      imageUrl: fields[4] as String?,
      storeId: fields[5] as String?,
      storeName: fields[6] as String?,
      category: fields[7] as String,
      quantity: fields[8] as int,
      expiresAt: fields[9] as DateTime?,
      isActive: fields[10] as bool,
      userId: fields[11] as String?,
      lastModifiedAt: fields[12] as DateTime,
      syncStatusString: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RewardModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.requiredPoints)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.storeId)
      ..writeByte(6)
      ..write(obj.storeName)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.quantity)
      ..writeByte(9)
      ..write(obj.expiresAt)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.userId)
      ..writeByte(12)
      ..write(obj.lastModifiedAt)
      ..writeByte(13)
      ..write(obj.syncStatusString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
