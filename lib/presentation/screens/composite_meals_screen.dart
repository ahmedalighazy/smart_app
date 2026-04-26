import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/colors.dart';
import '../../data/models/composite_meal_model.dart';
import '../../data/services/composite_meal_service.dart';
import '../../logic/cubits/settings_cubit.dart';
import 'composite_meal_builder_screen.dart';

class CompositeMealsScreen extends StatefulWidget {
  const CompositeMealsScreen({super.key});

  @override
  State<CompositeMealsScreen> createState() => _CompositeMealsScreenState();
}

class _CompositeMealsScreenState extends State<CompositeMealsScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkBackground
              : const Color(0xFFF8F9FA),
          body: Column(
            children: [
              _buildHeader(context, isDark),
              _buildFilterTabs(isDark),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: CompositeMealService.box.listenable(),
                  builder: (context, Box<CompositeMealModel> box, _) {
                    final meals = _getFilteredMeals();

                    if (meals.isEmpty) {
                      return _buildEmptyState(context, isDark);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        return _buildMealCard(meals[index], isDark);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _navigateToBuilder(context),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'تكوين وجبة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'الوجبات المركبة',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'كوّن وجباتك الخاصة',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    final filters = [
      {'id': 'all', 'name': 'الكل', 'icon': Icons.grid_view_rounded},
      {'id': 'breakfast', 'name': 'فطور', 'icon': Icons.free_breakfast},
      {'id': 'lunch', 'name': 'غداء', 'icon': Icons.lunch_dining},
      {'id': 'dinner', 'name': 'عشاء', 'icon': Icons.dinner_dining},
      {'id': 'snack', 'name': 'خفيفة', 'icon': Icons.cookie},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['id'];

          return GestureDetector(
            onTap: () =>
                setState(() => _selectedFilter = filter['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppTheme.darkCard : Colors.white),
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 18,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['name'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCard(CompositeMealModel meal, bool isDark) {
    final nutrition = meal.totalNutrition;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primaryLight.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${meal.items.length} عنصر',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey[400]
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Edit Button
                    IconButton(
                      onPressed: () => _navigateToBuilder(context, meal: meal),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () => _confirmDelete(context, meal),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...meal.items.map((item) => _buildItemRow(item, isDark)),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                const SizedBox(height: 12),
                // Total Nutrition
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientChip(
                      '🔥',
                      nutrition['calories']!.toStringAsFixed(0),
                      AppColors.calories,
                    ),
                    _buildNutrientChip(
                      '💪',
                      '${nutrition['protein']!.toStringAsFixed(1)}g',
                      AppColors.protein,
                    ),
                    _buildNutrientChip(
                      '🌾',
                      '${nutrition['carbs']!.toStringAsFixed(1)}g',
                      AppColors.carbs,
                    ),
                    _buildNutrientChip(
                      '💧',
                      '${nutrition['fat']!.toStringAsFixed(1)}g',
                      AppColors.fats,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(CompositeMealItem item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(item.categoryEmoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.foodName,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
          ),
          if (item.quantity != 1.0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x${item.quantity.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String emoji, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text('🍽️', style: TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد وجبات مركبة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بتكوين وجباتك الخاصة',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  List<CompositeMealModel> _getFilteredMeals() {
    if (_selectedFilter == 'all') {
      return CompositeMealService.getAllCompositeMeals();
    }
    return CompositeMealService.getCompositeMealsByType(_selectedFilter);
  }

  void _navigateToBuilder(BuildContext context, {CompositeMealModel? meal}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompositeMealBuilderScreen(meal: meal),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CompositeMealModel meal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'حذف الوجبة',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'هل تريد حذف "${meal.name}"؟',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              CompositeMealService.deleteCompositeMeal(meal.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حذف ${meal.name}',
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
