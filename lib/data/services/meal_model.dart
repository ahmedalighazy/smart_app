// lib/data/models/meal_model.dart

import 'package:hive/hive.dart';

part 'meal_model.g.dart';

@HiveType(typeId: 0)
class MealModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String calories;

  @HiveField(3)
  String protein;

  @HiveField(4)
  String carbs;

  @HiveField(5)
  String fat;

  @HiveField(6)
  String categoryName;

  @HiveField(7)
  String categoryEmoji;

  @HiveField(8)
  int categoryColorValue;

  @HiveField(9)
  DateTime addedAt;

  @HiveField(10)
  String mealType;

  @HiveField(11)
  String? imageUrl;

  MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.categoryName,
    required this.categoryEmoji,
    required this.categoryColorValue,
    required this.addedAt,
    this.mealType = 'snack',
    this.imageUrl,
  });

  static Map<String, double> getTotalNutrition(List<MealModel> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var meal in meals) {
      totalCalories += double.tryParse(meal.calories) ?? 0;
      totalProtein += double.tryParse(meal.protein) ?? 0;
      totalCarbs += double.tryParse(meal.carbs) ?? 0;
      totalFat += double.tryParse(meal.fat) ?? 0;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
}

