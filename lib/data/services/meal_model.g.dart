// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealModelAdapter extends TypeAdapter<MealModel> {
  @override
  final int typeId = 0;

  @override
  MealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealModel(
      id: fields[0] as String,
      name: fields[1] as String,
      calories: fields[2] as String,
      protein: fields[3] as String,
      carbs: fields[4] as String,
      fat: fields[5] as String,
      categoryName: fields[6] as String,
      categoryEmoji: fields[7] as String,
      categoryColorValue: fields[8] as int,
      addedAt: fields[9] as DateTime,
      mealType: fields[10] as String,
      imageUrl: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MealModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.carbs)
      ..writeByte(5)
      ..write(obj.fat)
      ..writeByte(6)
      ..write(obj.categoryName)
      ..writeByte(7)
      ..write(obj.categoryEmoji)
      ..writeByte(8)
      ..write(obj.categoryColorValue)
      ..writeByte(9)
      ..write(obj.addedAt)
      ..writeByte(10)
      ..write(obj.mealType)
      ..writeByte(11)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
