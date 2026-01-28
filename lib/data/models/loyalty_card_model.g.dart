// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoyaltyCardModelAdapter extends TypeAdapter<LoyaltyCardModel> {
  @override
  final int typeId = 0;

  @override
  LoyaltyCardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoyaltyCardModel(
      id: fields[0] as String,
      storeName: fields[1] as String,
      storeLogoUrl: fields[2] as String?,
      currentPoints: fields[3] as int,
      tier: fields[4] as String,
      colorIndex: fields[5] as int,
      createdAt: fields[6] as DateTime,
      lastActivityAt: fields[7] as DateTime,
      isActive: fields[8] as bool,
      userId: fields[9] as String?,
      lastModifiedAt: fields[10] as DateTime,
      syncStatusString: fields[11] as String,
      isEcoFriendly: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LoyaltyCardModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.storeName)
      ..writeByte(2)
      ..write(obj.storeLogoUrl)
      ..writeByte(3)
      ..write(obj.currentPoints)
      ..writeByte(4)
      ..write(obj.tier)
      ..writeByte(5)
      ..write(obj.colorIndex)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastActivityAt)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.lastModifiedAt)
      ..writeByte(11)
      ..write(obj.syncStatusString)
      ..writeByte(12)
      ..write(obj.isEcoFriendly);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
