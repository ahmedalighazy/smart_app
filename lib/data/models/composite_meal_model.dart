import 'package:hive/hive.dart';

part 'composite_meal_model.g.dart';

@HiveType(typeId: 3)
class CompositeMealModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<CompositeMealItem> items;

  @HiveField(3)
  final String mealType; // breakfast, lunch, dinner, snack

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? notes;

  CompositeMealModel({
    required this.id,
    required this.name,
    required this.items,
    required this.mealType,
    required this.createdAt,
    this.notes,
  });

  // حساب إجمالي القيم الغذائية
  Map<String, double> get totalNutrition {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var item in items) {
      totalCalories += double.tryParse(item.calories) ?? 0;
      totalProtein += double.tryParse(item.protein) ?? 0;
      totalCarbs += double.tryParse(item.carbs) ?? 0;
      totalFat += double.tryParse(item.fat) ?? 0;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }

  String get totalCaloriesString =>
      totalNutrition['calories']!.toStringAsFixed(0);
  String get totalProteinString =>
      totalNutrition['protein']!.toStringAsFixed(1);
  String get totalCarbsString => totalNutrition['carbs']!.toStringAsFixed(1);
  String get totalFatString => totalNutrition['fat']!.toStringAsFixed(1);
}

@HiveType(typeId: 4)
class CompositeMealItem {
  @HiveField(0)
  final String foodName;

  @HiveField(1)
  final String calories;

  @HiveField(2)
  final String protein;

  @HiveField(3)
  final String carbs;

  @HiveField(4)
  final String fat;

  @HiveField(5)
  final String categoryName;

  @HiveField(6)
  final String categoryEmoji;

  @HiveField(7)
  final int categoryColorValue;

  @HiveField(8)
  final double quantity; // الكمية (مثلاً 1.5 حصة)

  CompositeMealItem({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.categoryName,
    required this.categoryEmoji,
    required this.categoryColorValue,
    this.quantity = 1.0,
  });

  // نسخة معدلة من العنصر مع كمية مختلفة
  CompositeMealItem copyWith({double? quantity}) {
    return CompositeMealItem(
      foodName: foodName,
      calories:
          (double.parse(calories) * (quantity ?? this.quantity) / this.quantity)
              .toStringAsFixed(0),
      protein:
          (double.parse(protein) * (quantity ?? this.quantity) / this.quantity)
              .toStringAsFixed(1),
      carbs: (double.parse(carbs) * (quantity ?? this.quantity) / this.quantity)
          .toStringAsFixed(1),
      fat: (double.parse(fat) * (quantity ?? this.quantity) / this.quantity)
          .toStringAsFixed(1),
      categoryName: categoryName,
      categoryEmoji: categoryEmoji,
      categoryColorValue: categoryColorValue,
      quantity: quantity ?? this.quantity,
    );
  }
}
