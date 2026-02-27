# 🚀 Advanced Features - المميزات المتقدمة

## نظرة عامة
هذا الملف يوثق المميزات المتقدمة في التطبيق.

---

## 1. Food Scanner with AI - مسح الطعام بالذكاء الاصطناعي

### الوصف
استخدام Google Gemini Vision API لتحليل صور الطعام وتقديم معلومات غذائية دقيقة.

### الشاشة - `lib/presentation/screens/food_scanner_screen.dart`

**المميزات**:
- 📸 التقاط صورة من الكاميرا
- 🖼️ اختيار صورة من المعرض
- 🤖 تحليل تلقائي بالـ AI
- 📊 عرض المعلومات الغذائية
- 💡 نصائح صحية
- ⭐ تقييم صحي للطعام

**الكود الرئيسي**:

```dart
class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  // التقاط صورة من الكاميرا
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        final file = File(photo.path);
        context.read<FoodScannerCubit>().analyzeFood(file);
      }
    } catch (e) {
      _showError('خطأ في التقاط الصورة: $e');
    }
  }

  // اختيار صورة من المعرض
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final file = File(image.path);
        context.read<FoodScannerCubit>().analyzeFood(file);
      }
    } catch (e) {
      _showError('خطأ في اختيار الصورة: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FoodScannerCubit, FoodScannerState>(
        builder: (context, state) {
          if (state is FoodScannerAnalyzing) {
            return _buildAnalyzing();
          }

          if (state is FoodScannerAnalyzed) {
            return _buildResults(state);
          }

          if (state is FoodScannerError) {
            return _buildError(state.message);
          }

          return _buildInitial();
        },
      ),
    );
  }

  // عرض النتائج
  Widget _buildResults(FoodScannerAnalyzed state) {
    final result = state.result;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // الصورة
          Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(state.imageFile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Overlay
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // اسم الطعام
              Positioned(
                bottom: 20,
                right: 20,
                left: 20,
                child: Text(
                  result.foodName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // العناصر الغذائية
                Row(
                  children: [
                    Expanded(
                      child: _buildNutrientCard(
                        'السعرات',
                        '${result.calories}',
                        'سعرة',
                        Icons.local_fire_department,
                        AppColors.calories,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNutrientCard(
                        'البروتين',
                        '${result.protein}',
                        'جرام',
                        Icons.fitness_center,
                        AppColors.protein,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildNutrientCard(
                        'الكربوهيدرات',
                        '${result.carbs}',
                        'جرام',
                        Icons.grain,
                        AppColors.carbs,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNutrientCard(
                        'الدهون',
                        '${result.fats}',
                        'جرام',
                        Icons.opacity,
                        AppColors.fats,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // التقييم الصحي
                _buildHealthRating(result.healthRating),
                
                // المكونات
                _buildIngredientsCard(result.ingredients),
                
                // النصائح
                _buildTipsCard(result.tips),
                
                // التحليل المفصل
                _buildDetailedAnalysis(result.detailedAnalysis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCard(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

### كيفية الاستخدام:

```dart
// 1. المستخدم يضغط على زر الكاميرا
ElevatedButton(
  onPressed: _takePhoto,
  child: Text('التقط صورة'),
)

// 2. يتم التقاط الصورة وإرسالها للتحليل
context.read<FoodScannerCubit>().analyzeFood(imageFile);

// 3. FoodVisionService يحلل الصورة باستخدام Gemini
final result = await FoodVisionService().analyzeFood(imageFile);

// 4. عرض النتائج
BlocBuilder<FoodScannerCubit, FoodScannerState>(
  builder: (context, state) {
    if (state is FoodScannerAnalyzed) {
      return ResultsWidget(state.result);
    }
    return LoadingWidget();
  },
)
```

---

## 2. AI Recommendations - توصيات الذكاء الاصطناعي

### الوصف
توصيات غذائية مخصصة بناءً على بيانات المستخدم باستخدام Google Gemini.

### الشاشة - `lib/presentation/screens/ai_recommendations_screen.dart`

**المميزات**:
- 🤖 تحليل شامل للحالة الصحية
- 📋 5 نصائح غذائية محددة
- 🍽️ أمثلة على وجبات يومية
- ✅ أطعمة يُنصح بها
- ❌ أطعمة يُنصح بتجنبها
- 🔄 تحديث التوصيات

**الكود**:

```dart
class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() => _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  final FoodVisionService _aiService = FoodVisionService();
  String _recommendations = '';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final userState = context.read<UserCubit>().state;

      if (userState is! UserCalculated) {
        setState(() {
          _error = 'الرجاء إدخال بياناتك أولاً من حاسبة التغذية';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final recommendations = await _aiService.getAIRecommendations(
        userState.user,
        userState.result,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'خطأ في الحصول على التوصيات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('توصيات AI مخصصة'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRecommendations,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildError();
    }

    if (_isLoading) {
      return _buildLoading();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'توصيات مخصصة من AI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'بناءً على بياناتك الشخصية',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recommendations Content
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SelectableText(
              _recommendations,
              style: const TextStyle(
                fontSize: 16,
                height: 2.0,
                color: AppColors.textDark,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 3. PDF Export - تصدير التقارير

### الوصف
تصدير تقرير شامل بصيغة PDF يحتوي على جميع البيانات والوجبات.

### الخدمة - `lib/data/services/pdf_service.dart`

**المحتويات**:
- 📊 بيانات المستخدم
- 📈 BMI و BMR و TDEE
- 🥗 العناصر الغذائية المطلوبة
- 🍽️ الوجبات المضافة اليوم
- 📊 إجمالي السعرات والعناصر

**الكود**:

```dart
class PDFService {
  static Future<String?> generateNutritionReport({
    required dynamic result,
    required List<MealModel> meals,
    required String userName,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';

    // حساب الإجماليات
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var meal in meals) {
      totalCalories += double.parse(meal.calories);
      totalProtein += double.parse(meal.protein);
      totalCarbs += double.parse(meal.carbs);
      totalFats += double.parse(meal.fat);
    }

    // إنشاء PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header
          pw.Center(
            child: pw.Text(
              'Nutrition Analysis Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // User Info
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('User Name: $userName'),
                pw.Text('Date: $dateStr'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // BMI Section
          pw.Text(
            'Body Mass Index (BMI)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('BMI Value'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('Category'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.bmi.toStringAsFixed(1)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.bmiCategory),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Daily Needs
          pw.Text(
            'Daily Nutritional Requirements',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('TDEE (Calories)'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('BMR (Calories)'),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.tdee.toStringAsFixed(0)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(result.bmr.toStringAsFixed(0)),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Meals Section
          if (meals.isNotEmpty) ...[
            pw.Text(
              'Meals Added Today',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Meal Name'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Calories'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Protein (g)'),
                    ),
                  ],
                ),
                ...meals.map((meal) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(meal.name),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(meal.calories),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(meal.protein),
                    ),
                  ],
                )),
              ],
            ),
          ],

          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text(
              'Generated by Smart Nutrition App',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
        ],
      ),
    );

    // حفظ PDF
    return await _savePDF(pdf, 'nutrition_report_$dateStr.pdf');
  }

  static Future<String?> _savePDF(pw.Document pdf, String fileName) async {
    try {
      Directory cacheDir = await getTemporaryDirectory();
      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
```

### الاستخدام:

```dart
// في Results Screen
IconButton(
  icon: Icon(Icons.download),
  onPressed: () async {
    final pdfPath = await PDFService.generateNutritionReport(
      result: state.result,
      meals: HiveService.getTodayMeals(),
      userName: 'المستخدم',
    );

    if (pdfPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: pdfPath),
        ),
      );
    }
  },
)
```

---

## 4. Notifications System - نظام الإشعارات

### المميزات:
- 🔔 إشعارات محلية
- 📝 سجل الإشعارات
- 💡 نصائح يومية تلقائية
- 🍽️ إشعارات الوجبات

### الخدمات:

**1. NotificationService**:
```dart
// إشعار وجبة
await NotificationService().showMealNotification(
  mealName: 'دجاج مشوي',
  calories: '250',
  protein: '30',
);

// إشعار نصيحة
await NotificationService().scheduleDailyTip(
  'اشرب 8 أكواب ماء يومياً',
);
```

**2. NotificationHistoryService**:
```dart
// إضافة إشعار للسجل
await NotificationHistoryService.addNotification(
  title: 'تم إضافة وجبة',
  body: 'دجاج مشوي - 250 سعرة',
  type: 'meal',
);

// الحصول على السجل
final notifications = NotificationHistoryService.getAllNotifications();

// حذف إشعار
await NotificationHistoryService.deleteNotification(id);
```

**3. BackgroundTipsService**:
```dart
// بدء الخدمة
BackgroundTipsService.start();

// إيقاف الخدمة
BackgroundTipsService.stop();
```

---

## ملخص المميزات المتقدمة

### المميزات المتوفرة:
1. ✅ **Food Scanner**: مسح الطعام بالـ AI
2. ✅ **AI Recommendations**: توصيات مخصصة
3. ✅ **PDF Export**: تصدير التقارير
4. ✅ **Notifications**: نظام إشعارات متقدم
5. ✅ **Dark Mode**: وضع داكن/فاتح
6. ✅ **Localization**: دعم لغتين
7. ✅ **Offline Storage**: تخزين محلي بـ Hive
8. ✅ **Charts**: رسوم بيانية تفاعلية

### التقنيات المستخدمة:
- Google Gemini AI
- Flutter Local Notifications
- PDF Generation
- Hive Database
- FL Chart
- Image Picker
- Dio HTTP Client
