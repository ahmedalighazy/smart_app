import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../logic/cubits/user_cubit.dart';
import '../../data/services/hive_service.dart';
import '../../data/services/meal_model.dart';
import '../../data/services/pdf_service.dart';
import '../../core/constants/colors.dart';
import 'pdf_viewer_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            );
          }

          if (state is UserCalculated) {
            final result = state.result;
            return _buildResultsContent(context, result);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 20),
                const Text(
                  'لا توجد بيانات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                const Text(
                  'الرجاء إدخال بياناتك أولاً',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsContent(BuildContext context, dynamic result) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Macros with Circular Progress
                _buildMacrosWithCircle(result),
                const SizedBox(height: 20),

                // Bar Chart for Macros Comparison
                _buildMacrosBarChart(result),
                const SizedBox(height: 20),

                // Suggested Meals
                _buildSuggestedMeals(result),
                const SizedBox(height: 16),

                // Today's Meals
                _buildTodaysMeals(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/ai_recommendations');
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.psychology, size: 20, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showAddMealDialog(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _exportToPDF(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'نتائج التحليل',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'احتياجاتك الغذائية اليومية',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context) {
    Navigator.pushNamed(context, '/home');
  }

  void _exportToPDF(BuildContext context) async {
    final state = context.read<UserCubit>().state;
    if (state is UserCalculated) {
      final todayMeals = HiveService.getTodayMeals();
      final userName = state.user.name ?? 'المستخدم';
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'جاري حفظ التقرير...',
            textDirection: TextDirection.rtl,
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final pdfPath = await PDFService.generateNutritionReport(
        result: state.result,
        meals: todayMeals,
        userName: userName,
      );

      if (context.mounted) {
        if (pdfPath != null) {
          // Navigate to PDF viewer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewerScreen(pdfPath: pdfPath),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '❌ حدث خطأ في حفظ التقرير',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildMacrosWithCircle(dynamic result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Circular Progress on the right
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: result.tdee / 2500,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCalorieColor(result.tdee),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.tdee.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const Text(
                      'سعرة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Macros on the left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMacroRow(
                  'الكربوهيدرات',
                  '${result.macros.carbs.toStringAsFixed(1)} / 275.0 ج',
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildMacroRow(
                  'الدهون',
                  '${result.macros.fats.toStringAsFixed(1)} / 78.0 ج',
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildMacroRow(
                  'البروتين',
                  '${result.macros.protein.toStringAsFixed(1)} / 50.0 ج',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.6,
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCalorieColor(double tdee) {
    if (tdee < 1500) return Colors.blue;
    if (tdee < 2000) return Colors.green;
    if (tdee < 2500) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMacrosBarChart(dynamic result) {
    final carbs = result.macros.carbs;
    final protein = result.macros.protein;
    final fats = result.macros.fats;

    // الأهداف المقترحة
    final carbsGoal = 275.0;
    final proteinGoal = 50.0;
    final fatsGoal = 78.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'مقارنة العناصر الغذائية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          const Text(
            'احتياجاتك مقارنة بالأهداف المقترحة',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF757575),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 350,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = '';
                      String type = rodIndex == 0 ? 'احتياجاتك' : 'الهدف';
                      
                      if (groupIndex == 0) label = 'الكربوهيدرات';
                      if (groupIndex == 1) label = 'البروتين';
                      if (groupIndex == 2) label = 'الدهون';
                      
                      return BarTooltipItem(
                        '$label\n$type: ${rod.toY.toStringAsFixed(1)} ج',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 0) text = 'كربوهيدرات';
                        if (value == 1) text = 'بروتين';
                        if (value == 2) text = 'دهون';
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  // الكربوهيدرات
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: carbs,
                        color: const Color(0xFF4CAF50),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: carbsGoal,
                        color: const Color(0xFFA5D6A7),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  // البروتين
                  BarChartGroupData(
                    x: 1,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: protein,
                        color: const Color(0xFF9C27B0),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: proteinGoal,
                        color: const Color(0xFFCE93D8),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  // الدهون
                  BarChartGroupData(
                    x: 2,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: fats,
                        color: const Color(0xFFFF9800),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: fatsGoal,
                        color: const Color(0xFFFFCC80),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              _buildLegendItem('احتياجاتك', const Color(0xFF4CAF50)),
              const SizedBox(width: 24),
              _buildLegendItem('الهدف المقترح', const Color(0xFFA5D6A7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedMeals(dynamic result) {
    final suggestions = _generateMealSuggestions(result);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'وجبات مقترحة بناءً على احتياجاتك',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          ...suggestions.map((suggestion) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSuggestionItem(suggestion),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (suggestion['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (suggestion['color'] as Color).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                suggestion['emoji'] as String,
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                suggestion['title'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion['description'] as String,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMealSuggestions(dynamic result) {
    final suggestions = <Map<String, dynamic>>[];
    final bmi = result.bmi;
    final tdee = result.tdee;
    final carbs = result.macros.carbs;
    final protein = result.macros.protein;

    // BMI-based suggestions
    if (bmi < 18.5) {
      suggestions.add({
        'emoji': '🍗',
        'title': 'زيادة البروتين والسعرات',
        'description': 'وزنك أقل من الطبيعي. ركز على الأطعمة الغنية بالبروتين والسعرات الحرارية مثل الدجاج والبيض والمكسرات.',
        'color': Colors.orange,
      });
    } else if (bmi > 30) {
      suggestions.add({
        'emoji': '🥗',
        'title': 'تقليل السعرات والدهون',
        'description': 'وزنك أعلى من الطبيعي. ركز على الخضروات والفواكه والبروتين قليل الدسم.',
        'color': Colors.red,
      });
    } else {
      suggestions.add({
        'emoji': '⚖️',
        'title': 'الحفاظ على التوازن',
        'description': 'وزنك صحي. استمر في تناول وجبات متوازنة من جميع المجموعات الغذائية.',
        'color': Colors.green,
      });
    }

    // Protein-based suggestions
    if (protein < 50) {
      suggestions.add({
        'emoji': '💪',
        'title': 'زيادة البروتين',
        'description': 'احتياجك من البروتين منخفض. أضف المزيد من اللحوم والأسماك والبيض والألبان.',
        'color': Colors.orange,
      });
    }

    // Carbs-based suggestions
    if (carbs > 300) {
      suggestions.add({
        'emoji': '🌾',
        'title': 'اختر الكربوهيدرات المعقدة',
        'description': 'احتياجك من الكربوهيدرات مرتفع. اختر الحبوب الكاملة والأرز البني بدلاً من الأبيض.',
        'color': Colors.blue,
      });
    }

    // Calorie-based suggestions
    if (tdee > 2500) {
      suggestions.add({
        'emoji': '🔥',
        'title': 'احتياجك من السعرات مرتفع',
        'description': 'تحتاج إلى سعرات حرارية أكثر. تأكد من تناول وجبات منتظمة وخفيفة بين الوجبات الرئيسية.',
        'color': Colors.red,
      });
    }

    return suggestions;
  }

  Widget _buildTodaysMeals() {
    return ValueListenableBuilder(
      valueListenable: HiveService.mealsBox.listenable(),
      builder: (context, Box<MealModel> box, _) {
        final todayMeals = HiveService.getTodayMeals();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${todayMeals.length} وجبة',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Text(
                    'الوجبات المضافة اليوم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (todayMeals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'لم تضف أي وجبات بعد',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                )
              else
                Column(
                  children: List.generate(
                    todayMeals.length,
                    (index) {
                      if (index > 0) {
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            _buildMealItem(todayMeals[index]),
                          ],
                        );
                      }
                      return _buildMealItem(todayMeals[index]);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealItem(MealModel meal) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: meal.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      meal.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(meal.categoryEmoji, style: const TextStyle(fontSize: 24)),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(meal.categoryEmoji, style: const TextStyle(fontSize: 24)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  meal.categoryName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'سعرة',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
