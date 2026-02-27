import 'package:flutter/material.dart';
import '../../../../data/services/hive_service.dart';
import '../../../../data/services/meal_model.dart';
import '../../../../data/services/notification_service.dart';

class FoodItemCard extends StatefulWidget {
  final Map<String, dynamic> food;
  final Map<String, dynamic> category;

  const FoodItemCard({
    super.key,
    required this.food,
    required this.category,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = widget.category['color'] as Color;

    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Main Card Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Food Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          categoryColor.withOpacity(0.8),
                          categoryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.category['emoji'] ?? '🍽️',
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),

                  // Food Name and Calories
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.food['name'] ?? 'طعام',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.food['calories']} سعرة',
                              style: TextStyle(
                                fontSize: 14,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand Button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: categoryColor,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Details
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            categoryColor.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // Nutrition Info Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      textDirection: TextDirection.rtl,
                      children: [
                        _buildNutritionItem(
                          icon: Icons.fitness_center,
                          label: 'بروتين',
                          value: widget.food['protein'] ?? '0g',
                          color: categoryColor,
                        ),
                        _buildNutritionItem(
                          icon: Icons.eco,
                          label: 'كربوهيدرات',
                          value: widget.food['carbs'] ?? '0g',
                          color: categoryColor,
                        ),
                        _buildNutritionItem(
                          icon: Icons.water_drop,
                          label: 'دهون',
                          value: widget.food['fat'] ?? '0g',
                          color: categoryColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Add Button
                    Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor,
                            categoryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showAddMealDialog(context, categoryColor),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'إضافة إلى الوجبة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddMealDialog(BuildContext context, Color categoryColor) {
    String selectedMealType = 'breakfast';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'إضافة إلى الوجبات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        ),
                      textDirection: TextDirection.rtl,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Food Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        widget.category['emoji'] ?? '🍽️',
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.food['name'] ?? 'طعام',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.food['calories']} سعرة | ${widget.food['protein']}g بروتين',
                              style: TextStyle(
                                fontSize: 14,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Meal Type Selection
                const Text(
                  'اختر نوع الوجبة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildMealTypeChip(
                      'breakfast',
                      'فطور',
                      Icons.free_breakfast,
                      Colors.orange,
                      selectedMealType,
                      (value) => setDialogState(() => selectedMealType = value),
                    ),
                    _buildMealTypeChip(
                      'lunch',
                      'غداء',
                      Icons.lunch_dining,
                      Colors.green,
                      selectedMealType,
                      (value) => setDialogState(() => selectedMealType = value),
                    ),
                    _buildMealTypeChip(
                      'dinner',
                      'عشاء',
                      Icons.dinner_dining,
                      Colors.blue,
                      selectedMealType,
                      (value) => setDialogState(() => selectedMealType = value),
                    ),
                    _buildMealTypeChip(
                      'snack',
                      'وجبة خفيفة',
                      Icons.cookie,
                      Colors.purple,
                      selectedMealType,
                      (value) => setDialogState(() => selectedMealType = value),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Add Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final meal = MealModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: widget.food['name']?.toString() ?? 'طعام',
                        calories: widget.food['calories']?.toString() ?? '0',
                        protein: widget.food['protein']?.toString() ?? '0',
                        carbs: widget.food['carbs']?.toString() ?? '0',
                        fat: widget.food['fat']?.toString() ?? '0',
                        categoryName: widget.category['name']?.toString() ?? 'طعام',
                        categoryEmoji: widget.category['emoji']?.toString() ?? '🍽️',
                        categoryColorValue: (widget.category['color'] as Color?)?.value ?? Colors.grey.value,
                        addedAt: DateTime.now(),
                        mealType: selectedMealType,
                        imageUrl: widget.category['imageUrl']?.toString(),
                      );

                      HiveService.addMeal(meal);
                      
                      // Show notification
                      NotificationService().showMealNotification(
                        mealName: meal.name,
                        calories: meal.calories,
                        protein: meal.protein,
                      );
                      
                      // Close dialog and navigate
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/my_meals');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'إضافة الوجبة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeChip(
    String value,
    String label,
    IconData icon,
    Color color,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = value == selectedValue;
    
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}