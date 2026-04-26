import 'package:hive_flutter/hive_flutter.dart';
import '../models/composite_meal_model.dart';

class CompositeMealService {
  static const String _boxName = 'composite_meals';
  static late Box<CompositeMealModel> _box;

  static Future<void> init() async {
    // سيتم تسجيل المحولات في main.dart
    _box = await Hive.openBox<CompositeMealModel>(_boxName);
  }

  static Box<CompositeMealModel> get box => _box;

  // إضافة وجبة مركبة جديدة
  static Future<void> addCompositeMeal(CompositeMealModel meal) async {
    await _box.put(meal.id, meal);
  }

  // تحديث وجبة مركبة
  static Future<void> updateCompositeMeal(CompositeMealModel meal) async {
    await _box.put(meal.id, meal);
  }

  // حذف وجبة مركبة
  static Future<void> deleteCompositeMeal(String id) async {
    await _box.delete(id);
  }

  // الحصول على وجبة مركبة بالمعرف
  static CompositeMealModel? getCompositeMeal(String id) {
    return _box.get(id);
  }

  // الحصول على جميع الوجبات المركبة
  static List<CompositeMealModel> getAllCompositeMeals() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // الحصول على الوجبات المركبة حسب النوع
  static List<CompositeMealModel> getCompositeMealsByType(String mealType) {
    return _box.values.where((meal) => meal.mealType == mealType).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // البحث في الوجبات المركبة
  static List<CompositeMealModel> searchCompositeMeals(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values
        .where(
          (meal) =>
              meal.name.toLowerCase().contains(lowerQuery) ||
              meal.items.any(
                (item) => item.foodName.toLowerCase().contains(lowerQuery),
              ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // حذف جميع الوجبات المركبة
  static Future<void> clearAll() async {
    await _box.clear();
  }
}
