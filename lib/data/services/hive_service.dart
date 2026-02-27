import 'package:hive_flutter/hive_flutter.dart';
import 'meal_model.dart';

class HiveService {
  static const String _mealsBoxName = 'meals';
  static Box<MealModel>? _mealsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register the adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MealModelAdapter());
    }
    
    _mealsBox = await Hive.openBox<MealModel>(_mealsBoxName);
  }

  static Box<MealModel> get mealsBox {
    if (_mealsBox == null || !_mealsBox!.isOpen) {
      throw Exception('Meals box is not initialized');
    }
    return _mealsBox!;
  }

  static Future<void> addMeal(MealModel meal) async {
    await mealsBox.put(meal.id, meal);
  }

  static List<MealModel> getAllMeals() {
    return mealsBox.values.toList();
  }

  static List<MealModel> getTodayMeals() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return mealsBox.values.where((meal) {
      final mealDate = DateTime(
        meal.addedAt.year,
        meal.addedAt.month,
        meal.addedAt.day,
      );
      return mealDate == today;
    }).toList();
  }

  static List<MealModel> getMealsByType(String type) {
    return getTodayMeals().where((meal) => meal.mealType == type).toList();
  }

  static Future<void> deleteMeal(String id) async {
    await mealsBox.delete(id);
  }

  static Future<void> clearAllMeals() async {
    await mealsBox.clear();
  }

  static int getTodayMealsCount() {
    return getTodayMeals().length;
  }

  static Future<void> updateMeal(MealModel meal) async {
    await mealsBox.put(meal.id, meal);
  }
}