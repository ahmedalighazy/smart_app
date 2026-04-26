import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/colors.dart';
import '../../data/models/composite_meal_model.dart';
import '../../data/services/composite_meal_service.dart';
import '../../data/services/notification_service.dart';
import '../../logic/cubits/settings_cubit.dart';
import 'home_screen/widgets/food_categories_data.dart';

class CompositeMealBuilderScreen extends StatefulWidget {
  final CompositeMealModel? meal;

  const CompositeMealBuilderScreen({super.key, this.meal});

  @override
  State<CompositeMealBuilderScreen> createState() =>
      _CompositeMealBuilderScreenState();
}

class _CompositeMealBuilderScreenState
    extends State<CompositeMealBuilderScreen> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  String _selectedMealType = 'breakfast';
  List<CompositeMealItem> _items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();

    if (widget.meal != null) {
      _nameController.text = widget.meal!.name;
      _notesController.text = widget.meal!.notes ?? '';
      _selectedMealType = widget.meal!.mealType;
      _items = List.from(widget.meal!.items);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
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
          body: Column(
            children: [
              _buildHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildNameField(isDark),
                      const SizedBox(height: 20),
                      _buildMealTypeSelector(isDark),
                      const SizedBox(height: 20),
                      _buildItemsList(isDark),
                      const SizedBox(height: 20),
                      _buildAddItemButton(isDark),
                      const SizedBox(height: 20),
                      if (_items.isNotEmpty) _buildNutritionSummary(isDark),
                      const SizedBox(height: 20),
                      _buildNotesField(isDark),
                      const SizedBox(height: 30),
                      _buildSaveButton(isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
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
          Row(
            textDirection: TextDirection.rtl,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.meal == null ? 'تكوين وجبة جديدة' : 'تعديل الوجبة',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_items.length} عنصر',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'اسم الوجبة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'مثال: وجبة الإفطار الصحية',
            hintStyle: TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector(bool isDark) {
    final types = [
      {'id': 'breakfast', 'name': 'فطور', 'emoji': '🌅'},
      {'id': 'lunch', 'name': 'غداء', 'emoji': '☀️'},
      {'id': 'dinner', 'name': 'عشاء', 'emoji': '🌙'},
      {'id': 'snack', 'name': 'خفيفة', 'emoji': '🍪'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'نوع الوجبة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: types.map((type) {
            final isSelected = _selectedMealType == type['id'];
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedMealType = type['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppTheme.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        type['emoji'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
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
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildItemsList(bool isDark) {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'لم تضف أي عناصر بعد',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'العناصر المضافة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildItemCard(item, index, isDark);
        }),
      ],
    );
  }

  Widget _buildItemCard(CompositeMealItem item, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(item.categoryColorValue).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(item.categoryEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.foodName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.calories} سعرة • ${item.protein}g بروتين',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _decreaseQuantity(index),
                      icon: const Icon(Icons.remove, size: 16),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: AppColors.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'x${item.quantity.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _increaseQuantity(index),
                      icon: const Icon(Icons.add, size: 16),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              IconButton(
                onPressed: () => _removeItem(index),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () => _showAddItemDialog(),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'إضافة عنصر',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionSummary(bool isDark) {
    final totalCalories = _items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.calories) ?? 0),
    );
    final totalProtein = _items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.protein) ?? 0),
    );
    final totalCarbs = _items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.carbs) ?? 0),
    );
    final totalFat = _items.fold<double>(
      0,
      (sum, item) => sum + (double.tryParse(item.fat) ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'إجمالي القيم الغذائية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientItem(
                '🔥',
                totalCalories.toStringAsFixed(0),
                'سعرة',
                AppColors.calories,
              ),
              _buildNutrientItem(
                '💪',
                '${totalProtein.toStringAsFixed(1)}g',
                'بروتين',
                AppColors.protein,
              ),
              _buildNutrientItem(
                '🌾',
                '${totalCarbs.toStringAsFixed(1)}g',
                'كربو',
                AppColors.carbs,
              ),
              _buildNutrientItem(
                '💧',
                '${totalFat.toStringAsFixed(1)}g',
                'دهون',
                AppColors.fats,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(
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
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'ملاحظات (اختياري)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          textDirection: TextDirection.rtl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'أضف ملاحظات عن الوجبة...',
            hintStyle: TextStyle(color: AppColors.textLight),
            filled: true,
            fillColor: isDark ? AppTheme.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _items.isEmpty || _nameController.text.trim().isEmpty
            ? null
            : _saveMeal,
        icon: const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          widget.meal == null ? 'حفظ الوجبة' : 'حفظ التعديلات',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    String? selectedCategory;
    Map<String, dynamic>? selectedFood;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
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
                      const Text(
                        'إضافة عنصر',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'اختر الفئة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: foodCategories.length,
                          itemBuilder: (context, index) {
                            final cat = foodCategories[index];
                            final isSelected = selectedCategory == cat['name'];
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() {
                                  selectedCategory = cat['name'] as String;
                                  selectedFood = null;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : (isDark
                                            ? AppTheme.darkSurface
                                            : Colors.grey[50]),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cat['emoji'] as String,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat['name'] as String,
                                      style: const TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        if (selectedCategory != null) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'اختر العنصر',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...((foodCategories.firstWhere(
                                    (c) => c['name'] == selectedCategory,
                                  )['items']
                                  as List)
                              .map((food) {
                                final isSelected = selectedFood == food;
                                return GestureDetector(
                                  onTap: () {
                                    setDialogState(() => selectedFood = food);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.1,
                                            )
                                          : (isDark
                                                ? AppTheme.darkSurface
                                                : Colors.grey[50]),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            food['name'] as String,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${food['calories']} سعرة',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: selectedFood == null
                                ? null
                                : () {
                                    _addItem(selectedFood!, selectedCategory!);
                                    Navigator.pop(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'إضافة',
                              style: TextStyle(
                                fontSize: 16,
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
          );
        },
      ),
    );
  }

  void _addItem(Map<String, dynamic> food, String categoryName) {
    final category = foodCategories.firstWhere(
      (c) => c['name'] == categoryName,
    );

    final item = CompositeMealItem(
      foodName: food['name'] as String,
      calories: food['calories'] as String,
      protein: food['protein'] as String,
      carbs: food['carbs'] as String,
      fat: food['fat'] as String,
      categoryName: category['name'] as String,
      categoryEmoji: category['emoji'] as String,
      categoryColorValue: (category['color'] as Color).toARGB32(),
      quantity: 1.0,
    );

    setState(() {
      _items.add(item);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      final item = _items[index];
      _items[index] = item.copyWith(quantity: item.quantity + 0.5);
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      final item = _items[index];
      if (item.quantity > 0.5) {
        _items[index] = item.copyWith(quantity: item.quantity - 0.5);
      }
    });
  }

  void _saveMeal() {
    if (_nameController.text.trim().isEmpty || _items.isEmpty) {
      return;
    }

    final meal = CompositeMealModel(
      id: widget.meal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      items: _items,
      mealType: _selectedMealType,
      createdAt: widget.meal?.createdAt ?? DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (widget.meal == null) {
      CompositeMealService.addCompositeMeal(meal);

      // إرسال إشعار
      NotificationService().showMealNotification(
        mealName: meal.name,
        calories: meal.totalCaloriesString,
        protein: meal.totalProteinString,
      );
    } else {
      CompositeMealService.updateCompositeMeal(meal);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.meal == null ? 'تم حفظ الوجبة ✓' : 'تم تحديث الوجبة ✓',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
