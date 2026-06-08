// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'composite_meal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompositeMealModelAdapter extends TypeAdapter<CompositeMealModel> {
  @override
  final int typeId = 3;

  @override
  CompositeMealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompositeMealModel(
      id: fields[0] as String,
      name: fields[1] as String,
      items: (fields[2] as List).cast<CompositeMealItem>(),
      mealType: fields[3] as String,
      createdAt: fields[4] as DateTime,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CompositeMealModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositeMealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompositeMealItemAdapter extends TypeAdapter<CompositeMealItem> {
  @override
  final int typeId = 4;

  @override
  CompositeMealItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompositeMealItem(
      foodName: fields[0] as String,
      calories: fields[1] as String,
      protein: fields[2] as String,
      carbs: fields[3] as String,
      fat: fields[4] as String,
      categoryName: fields[5] as String,
      categoryEmoji: fields[6] as String,
      categoryColorValue: fields[7] as int,
      quantity: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CompositeMealItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.foodName)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.protein)
      ..writeByte(3)
      ..write(obj.carbs)
      ..writeByte(4)
      ..write(obj.fat)
      ..writeByte(5)
      ..write(obj.categoryName)
      ..writeByte(6)
      ..write(obj.categoryEmoji)
      ..writeByte(7)
      ..write(obj.categoryColorValue)
      ..writeByte(8)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositeMealItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
