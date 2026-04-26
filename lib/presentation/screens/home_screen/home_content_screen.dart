import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/meal_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../logic/cubits/settings_cubit.dart';
import 'widgets/food_categories_data.dart';

class HomeContentScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeContentScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  late TextEditingController _searchController;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];

      // البحث عن الطعام في جميع الفئات
      for (var category in foodCategories) {
        final items = category['items'] as List;
        final matchingItems = items.where((item) {
          final name = (item['name'] as String).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();

        if (matchingItems.isNotEmpty) {
          _searchResults.addAll(
            matchingItems.map(
              (item) => {
                ...item,
                'categoryName': category['name'],
                'categoryColor': category['color'],
                'categoryEmoji': category['emoji'],
              },
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final isDark = state.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? AppTheme.darkBackground
              : const Color(0xFFF8F9FA),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                const SizedBox(height: 20),
                _buildQuickActions(context, isDark),
                const SizedBox(height: 24),
                _buildTodaySummary(context, isDark),
                const SizedBox(height: 24),
                _buildFoodCategories(context, isDark),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 55, 20, 25),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${context.tr('welcome')} ',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('app_name'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, bool isDark) {
    return ValueListenableBuilder(
      valueListenable: HiveService.mealsBox.listenable(),
      builder: (context, Box<MealModel> box, _) {
        final todayMeals = HiveService.getTodayMeals();
        final stats = MealModel.getTotalNutrition(todayMeals);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      context.tr('today_meals'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${todayMeals.length} ${context.tr('meals')}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientItem(
                      icon: Icons.local_fire_department_rounded,
                      value: stats['calories']!.toStringAsFixed(0),
                      label: context.tr('calories'),
                      color: AppColors.calories,
                      isDark: isDark,
                    ),
                    _buildNutrientItem(
                      icon: Icons.fitness_center_rounded,
                      value: '${stats['protein']!.toStringAsFixed(0)}g',
                      label: context.tr('protein'),
                      color: AppColors.protein,
                      isDark: isDark,
                    ),
                    _buildNutrientItem(
                      icon: Icons.grain_rounded,
                      value: '${stats['carbs']!.toStringAsFixed(0)}g',
                      label: context.tr('carbs'),
                      color: AppColors.carbs,
                      isDark: isDark,
                    ),
                    _buildNutrientItem(
                      icon: Icons.water_drop_rounded,
                      value: '${stats['fat']!.toStringAsFixed(0)}g',
                      label: context.tr('fats'),
                      color: AppColors.fats,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.tr('services'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_circle_rounded,
                  title: context.tr('add_meal'),
                  color: AppColors.primary,
                  isDark: isDark,
                  onTap: () => _showAddMealDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.calculate_rounded,
                  title: context.tr('nutrition_calc'),
                  color: Colors.orange,
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/input'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.camera_alt_rounded,
                  title: context.tr('food_scanner'),
                  color: Colors.blue,
                  isDark: isDark,
                  onTap: () => widget.onNavigateToTab?.call(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: context.tr('meals'),
                  color: Colors.purple,
                  isDark: isDark,
                  onTap: () => widget.onNavigateToTab?.call(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodCategories(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.tr('food_categories'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 15),
          _buildSearchBar(context, isDark),
          const SizedBox(height: 15),

          // عرض نتائج البحث أو الفئات
          if (_isSearching && _searchResults.isEmpty)
            _buildEmptySearchState(isDark)
          else if (_isSearching && _searchResults.isNotEmpty)
            _buildSearchResults(context, isDark)
          else
            _buildCategoriesGrid(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: 'ابحث عن طعام...',
        hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: AppColors.primary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: AppColors.primary),
                onPressed: () {
                  _searchController.clear();
                  _performSearch('');
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? AppTheme.darkSurface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        _performSearch(value);
      },
    );
  }

  Widget _buildEmptySearchState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على نتائج',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : AppColors.textLight,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, bool isDark) {
    return Column(
      children: _searchResults.map((food) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (food['categoryColor'] as Color).withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          food['categoryEmoji'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          food['categoryName'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey[400]
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: food['categoryColor'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildMiniNutrient(
                          '🔥',
                          food['calories'] as String,
                          Colors.red,
                        ),
                        const SizedBox(width: 12),
                        _buildMiniNutrient(
                          '💪',
                          '${food['protein']}g',
                          Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _buildMiniNutrient(
                          '🌾',
                          '${food['carbs']}g',
                          Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  _addMealDirectly(context, food, {
                    'name': food['categoryName'],
                    'emoji': food['categoryEmoji'],
                    'color': food['categoryColor'],
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'إضافة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: foodCategories.length,
      itemBuilder: (context, index) {
        final category = foodCategories[index];
        return _buildCategoryItem(
          emoji: category['emoji'] as String,
          name: category['name'] as String,
          color: category['color'] as Color,
          isDark: isDark,
          category: category,
          onTap: () => _showCategoryFoods(context, category),
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required String emoji,
    required String name,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    required Map<String, dynamic> category,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // عرض الصورة أو الأيقونة
              if (category['imageUrl'] != null)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (category['isLocalImage'] as bool? ?? false)
                        ? Image.asset(
                            category['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                emoji,
                                style: const TextStyle(fontSize: 32),
                              );
                            },
                          )
                        : Image.network(
                            category['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                emoji,
                                style: const TextStyle(fontSize: 32),
                              );
                            },
                          ),
                  ),
                )
              else
                Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryFoods(BuildContext context, Map<String, dynamic> category) {
    final items = category['items'] as List;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    category['emoji'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildFoodItem(context, item, category, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(
    BuildContext context,
    Map<String, dynamic> item,
    Map<String, dynamic> category,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildMiniNutrient(
                      '🔥',
                      item['calories'] as String,
                      Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _buildMiniNutrient(
                      '💪',
                      '${item['protein']}g',
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addMealDirectly(context, item, category);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'إضافة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNutrient(String emoji, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _addMealDirectly(
    BuildContext context,
    Map<String, dynamic> food,
    Map<String, dynamic> category,
  ) {
    final meal = MealModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: food['name'] as String,
      calories: food['calories'] as String,
      protein: food['protein'] as String,
      carbs: food['carbs'] as String,
      fat: food['fat'] as String,
      categoryName: category['name'] as String,
      categoryEmoji: category['emoji'] as String,
      categoryColorValue: (category['color'] as Color).toARGB32(),
      addedAt: DateTime.now(),
      mealType: 'snack',
      imageUrl: category['imageUrl'] as String?,
    );

    HiveService.addMeal(meal);

    // Show notification
    NotificationService().showMealNotification(
      mealName: meal.name,
      calories: meal.calories,
      protein: meal.protein,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إضافة ${meal.name} ✓',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'عرض الوجبات',
          textColor: Colors.white,
          onPressed: () => widget.onNavigateToTab?.call(2),
        ),
      ),
    );
  }

  void _showAddMealDialog(BuildContext context) {
    String? selectedCategory;
    String? selectedFoodItem;
    String selectedMealType = 'breakfast';
    Map<String, dynamic>? selectedFood;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      this.context.tr('add_meal'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Meal Type Selection
                      _buildMealTypeSelector(selectedMealType, isDark, (type) {
                        setDialogState(() => selectedMealType = type);
                      }),
                      const SizedBox(height: 20),

                      // Category Selection
                      _buildSelectionCard(
                        title: this.context.tr('select_category'),
                        value: selectedCategory,
                        hint: 'اختر فئة الطعام',
                        emoji: selectedCategory != null
                            ? foodCategories.firstWhere(
                                    (c) => c['name'] == selectedCategory,
                                  )['emoji']
                                  as String
                            : '🍽️',
                        isDark: isDark,
                        items: foodCategories
                            .map((c) => c['name'] as String)
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedCategory = value;
                            selectedFoodItem = null;
                            selectedFood = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Food Selection
                      if (selectedCategory != null)
                        _buildSelectionCard(
                          title: this.context.tr('select_food'),
                          value: selectedFoodItem,
                          hint: 'اختر الطعام',
                          emoji: '🍴',
                          isDark: isDark,
                          items:
                              (foodCategories.firstWhere(
                                        (c) => c['name'] == selectedCategory,
                                      )['items']
                                      as List)
                                  .map((i) => i['name'] as String)
                                  .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedFoodItem = value;
                              selectedFood =
                                  (foodCategories.firstWhere(
                                            (c) =>
                                                c['name'] == selectedCategory,
                                          )['items']
                                          as List)
                                      .firstWhere((i) => i['name'] == value);
                            });
                          },
                        ),
                      const SizedBox(height: 20),

                      // Nutrition Preview
                      if (selectedFood != null)
                        _buildNutritionPreview(selectedFood!, isDark),
                      const SizedBox(height: 24),

                      // Add Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: selectedFood == null
                              ? null
                              : () {
                                  _addMealFromDialog(
                                    selectedCategory!,
                                    selectedFood!,
                                    selectedMealType,
                                  );
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            this.context.tr('save'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector(
    String selected,
    bool isDark,
    Function(String) onSelect,
  ) {
    final types = [
      {
        'id': 'breakfast',
        'name': context.tr('breakfast'),
        'icon': Icons.free_breakfast,
      },
      {'id': 'lunch', 'name': context.tr('lunch'), 'icon': Icons.lunch_dining},
      {
        'id': 'dinner',
        'name': context.tr('dinner'),
        'icon': Icons.dinner_dining,
      },
      {'id': 'snack', 'name': context.tr('snack'), 'icon': Icons.cookie},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: types.map((type) {
        final isSelected = selected == type['id'];
        return GestureDetector(
          onTap: () => onSelect(type['id'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppTheme.darkSurface : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  type['icon'] as IconData,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  type['name'] as String,
                  style: TextStyle(
                    fontSize: 11,
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
      }).toList(),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String? value,
    required String hint,
    required String emoji,
    required bool isDark,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(hint, style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white : Colors.grey,
                ),
                dropdownColor: isDark ? AppTheme.darkCard : Colors.white,
                items: items.map((item) {
                  String itemEmoji = emoji;
                  if (title == context.tr('select_category')) {
                    itemEmoji =
                        foodCategories.firstWhere(
                              (c) => c['name'] == item,
                            )['emoji']
                            as String;
                  }
                  return DropdownMenuItem(
                    value: item,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(itemEmoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          item,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPreview(Map<String, dynamic> food, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            food['name'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNutrientPreviewItem(
                '🔥',
                food['calories'] as String,
                'سعرة',
                Colors.red,
              ),
              _buildNutrientPreviewItem(
                '💪',
                '${food['protein']}g',
                'بروتين',
                Colors.orange,
              ),
              _buildNutrientPreviewItem(
                '🌾',
                '${food['carbs']}g',
                'كربوهيدرات',
                Colors.green,
              ),
              _buildNutrientPreviewItem(
                '💧',
                '${food['fat']}g',
                'دهون',
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientPreviewItem(
    String emoji,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  void _addMealFromDialog(
    String categoryName,
    Map<String, dynamic> food,
    String mealType,
  ) {
    final category = foodCategories.firstWhere(
      (c) => c['name'] == categoryName,
    );

    final meal = MealModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: food['name'] as String,
      calories: food['calories'] as String,
      protein: food['protein'] as String,
      carbs: food['carbs'] as String,
      fat: food['fat'] as String,
      categoryName: category['name'] as String,
      categoryEmoji: category['emoji'] as String,
      categoryColorValue: (category['color'] as Color).toARGB32(),
      addedAt: DateTime.now(),
      mealType: mealType,
      imageUrl: category['imageUrl'] as String?,
    );

    HiveService.addMeal(meal);

    // Show notification
    NotificationService().showMealNotification(
      mealName: meal.name,
      calories: meal.calories,
      protein: meal.protein,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت إضافة ${meal.name} ✓',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'عرض الوجبات',
          textColor: Colors.white,
          onPressed: () => widget.onNavigateToTab?.call(2),
        ),
      ),
    );
  }
}
