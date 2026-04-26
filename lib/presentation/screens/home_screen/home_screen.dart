import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_nutrition/presentation/screens/home_screen/widgets/food_categories_data.dart';
import 'package:smart_nutrition/presentation/screens/home_screen/widgets/food_details_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/hive_service.dart';
import '../../../data/services/meal_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'widgets/category_card.dart';
import 'widgets/category_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  Timer? _autoScrollTimer;
  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.30,
      initialPage: foodCategories.length, // Start at last item (was length - 1)
    );
    _selectedIndex = foodCategories.length; // Adjust for add button

    // Header animation
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // FAB animation
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabAnimationController.forward();
    });

    // Don't start auto-scroll immediately - wait for user interaction
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPage = _selectedIndex - 1;
        if (nextPage < 0) {
          nextPage = foodCategories.length; // Adjust for add button
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _restartAutoScroll() {
    _stopAutoScroll();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Smart Nutrition',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),

            // Categories Slider
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.rtl,
                      children: [
                        const Text(
                          'الفئات الغذائية',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        IconButton(
                          onPressed: () => _showAddMealDialog(),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCategoriesSlider(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Category Preview
            if (_selectedIndex > 0)
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    key: ValueKey(_selectedIndex),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CategoryPreview(
                      category: foodCategories[_selectedIndex - 1],
                      onTap: () => _navigateToDetails(),
                    ),
                  ),
                ),
              ),

            // Features Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'الخدمات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 15),
                    _buildSimpleFeatureCard(
                      icon: Icons.calculate,
                      title: 'حاسبة التغذية',
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(context, '/input'),
                    ),
                    const SizedBox(height: 12),
                    _buildSimpleFeatureCard(
                      icon: Icons.camera_alt,
                      title: 'ماسح الطعام',
                      color: Colors.blue,
                      onTap: () =>
                          Navigator.pushNamed(context, '/food_scanner'),
                    ),
                    const SizedBox(height: 12),
                    _buildSimpleFeatureCard(
                      icon: Icons.psychology,
                      title: 'توصيات الذكاء الاصطناعي',
                      color: Colors.purple,
                      onTap: () => _showAIMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildMyMealsButton(),
    );
  }

  Widget _buildSimpleFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyMealsButton() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: ValueListenableBuilder(
        valueListenable: HiveService.mealsBox.listenable(),
        builder: (context, Box<MealModel> box, _) {
          final mealsCount = HiveService.getTodayMealsCount();

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/my_meals'),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    if (mealsCount > 0) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$mealsCount',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'وجباتي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSlider() {
    final totalItems = foodCategories.length + 1; // +1 for add button

    return RepaintBoundary(
      child: SizedBox(
        height: 140,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          itemCount: totalItems,
          itemBuilder: (context, index) {
            final isSelected = index == _selectedIndex;
            final scale = isSelected ? 1.0 : 0.85;
            final opacity = isSelected ? 1.0 : 0.6;

            // Add button as first item
            if (index == 0) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Transform.scale(
                  scale: scale,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: opacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: RepaintBoundary(
                        child: _buildAddMealCard(isSelected),
                      ),
                    ),
                  ),
                ),
              );
            }

            // Regular category cards
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: Transform.scale(
                scale: scale,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: opacity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: RepaintBoundary(
                      child: CategoryCard(
                        category: foodCategories[index - 1],
                        isSelected: isSelected,
                        onTap: () {
                          _stopAutoScroll();
                          setState(() {
                            _selectedIndex = index;
                          });
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                          _restartAutoScroll();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddMealCard(bool isSelected) {
    return GestureDetector(
      onTap: () {
        _stopAutoScroll();
        setState(() {
          _selectedIndex = 0;
        });
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
        _restartAutoScroll();
        _showAddMealDialog();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [Colors.purple.shade400, Colors.purple.shade600]
                : [Colors.purple.shade300, Colors.purple.shade500],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 15 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'إضافة وجبة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FoodDetailsScreen(category: foodCategories[_selectedIndex - 1]),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showAddMealDialog() {
    String? selectedCategory;
    String? selectedFoodItem;
    String selectedMealType = 'breakfast';
    Map<String, dynamic>? selectedFood;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إضافة وجبة جديدة',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
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

                  // Meal Type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        const Icon(Icons.category, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text(
                          'نوع الوجبة:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedMealType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'breakfast',
                                child: Text(
                                  'فطور',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'lunch',
                                child: Text(
                                  'غداء',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'dinner',
                                child: Text(
                                  'عشاء',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'snack',
                                child: Text(
                                  'وجبة خفيفة',
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedMealType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selection
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          selectedCategory != null
                              ? foodCategories.firstWhere(
                                      (c) => c['name'] == selectedCategory,
                                    )['emoji']
                                    as String
                              : '🍽️',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'الفئة:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            hint: const Text(
                              'اختر الفئة',
                              textDirection: TextDirection.rtl,
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: foodCategories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['name'] as String,
                                child: Text(
                                  '${category['emoji']} ${category['name']}',
                                  textDirection: TextDirection.rtl,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedCategory = value;
                                selectedFoodItem = null;
                                selectedFood = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Food Item Selection
                  if (selectedCategory != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          const Icon(Icons.restaurant, color: Colors.grey),
                          const SizedBox(width: 12),
                          const Text(
                            'الطعام:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedFoodItem,
                              hint: const Text(
                                'اختر الطعام',
                                textDirection: TextDirection.rtl,
                              ),
                              isExpanded: true,
                              underline: const SizedBox(),
                              items:
                                  (foodCategories.firstWhere(
                                            (c) =>
                                                c['name'] == selectedCategory,
                                          )['items']
                                          as List)
                                      .map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item['name'] as String,
                                          child: Text(
                                            item['name'] as String,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        );
                                      })
                                      .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedFoodItem = value;
                                  selectedFood =
                                      (foodCategories.firstWhere(
                                                (c) =>
                                                    c['name'] ==
                                                    selectedCategory,
                                              )['items']
                                              as List)
                                          .firstWhere(
                                            (item) => item['name'] == value,
                                          );
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Nutrition Info Display
                  if (selectedFood != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'القيم الغذائية (لكل 100 جرام)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNutritionInfo(
                                icon: Icons.local_fire_department,
                                label: 'سعرات',
                                value: selectedFood!['calories'] as String,
                                color: Colors.red,
                              ),
                              _buildNutritionInfo(
                                icon: Icons.fitness_center,
                                label: 'بروتين',
                                value: '${selectedFood!['protein']}g',
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildNutritionInfo(
                                icon: Icons.eco,
                                label: 'كربوهيدرات',
                                value: '${selectedFood!['carbs']}g',
                                color: Colors.green,
                              ),
                              _buildNutritionInfo(
                                icon: Icons.water_drop,
                                label: 'دهون',
                                value: '${selectedFood!['fat']}g',
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedFood == null
                          ? null
                          : () {
                              final category = foodCategories.firstWhere(
                                (c) => c['name'] == selectedCategory,
                              );

                              final meal = MealModel(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: selectedFood!['name'] as String,
                                calories: selectedFood!['calories'] as String,
                                protein: selectedFood!['protein'] as String,
                                carbs: selectedFood!['carbs'] as String,
                                fat: selectedFood!['fat'] as String,
                                categoryName: category['name'] as String,
                                categoryEmoji: category['emoji'] as String,
                                categoryColorValue: (category['color'] as Color)
                                    .toARGB32(),
                                addedAt: DateTime.now(),
                                mealType: selectedMealType,
                                imageUrl: category['imageUrl'] as String?,
                              );

                              HiveService.addMeal(meal);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تمت إضافة ${meal.name} بنجاح',
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFood == null
                            ? Colors.grey
                            : AppColors.primary,
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
      ),
    );
  }

  Widget _buildNutritionInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAIMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'الرجاء إدخال بياناتك أولاً من حاسبة التغذية',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
