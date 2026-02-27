# 💾 Data Layer - Services (الخدمات)

## نظرة عامة
طبقة الخدمات تحتوي على جميع العمليات المتعلقة بالبيانات والـ API والتخزين المحلي.

---

## 1. Authentication Service - `lib/data/services/auth_service.dart`

### الوصف
خدمة المصادقة وإدارة الجلسات باستخدام Flutter Secure Storage.

### الأكواد الرئيسية

```dart
class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const _secureStorage = FlutterSecureStorage();

  // التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // الحصول على التوكين المحفوظ
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // حفظ التوكينات
  static Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // مسح بيانات المصادقة
  static Future<void> _clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // تسجيل الدخول التلقائي
  static Future<Map<String, dynamic>> autoLogin() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token != null && token.isNotEmpty) {
        DioHelper.setToken(token);
        return {'success': true, 'message': 'تم استعادة الجلسة'};
      }
      return {'success': false, 'message': 'لا توجد جلسة محفوظة'};
    } catch (e) {
      return {'success': false, 'message': 'خطأ في استعادة الجلسة'};
    }
  }

  // تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await DioHelper.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        String? accessToken = data['access_token'] ?? data['data']?['access_token'];
        String? refreshToken = data['refresh_token'] ?? data['data']?['refresh_token'];

        if (accessToken != null) {
          await _saveTokens(accessToken, refreshToken ?? '');
          DioHelper.setToken(accessToken);
        }
        
        return {'success': true, 'data': response.data, 'message': 'تم التسجيل بنجاح'};
      }
      return {'success': false, 'message': 'فشل التسجيل'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // تسجيل الدخول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioHelper.login(email: email, password: password);

      if (response.statusCode == 200) {
        final data = response.data;
        String? accessToken = data['access_token'] ?? data['data']?['access_token'];
        String? refreshToken = data['refresh_token'] ?? data['data']?['refresh_token'];

        if (accessToken != null) {
          await _saveTokens(accessToken, refreshToken ?? '');
          DioHelper.setToken(accessToken);

          return {
            'success': true,
            'data': response.data,
            'accessToken': accessToken,
            'message': 'تم تسجيل الدخول بنجاح',
          };
        }
      }
      return {'success': false, 'message': 'فشل تسجيل الدخول'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    await _clearAuthData();
    DioHelper.removeToken();
  }

  // معالجة الأخطاء
  static String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        }
        return 'خطأ في الخادم';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
```

### الاستخدام

```dart
// تسجيل الدخول
final result = await AuthService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result['success']) {
  Navigator.pushReplacementNamed(context, '/home');
} else {
  showError(result['message']);
}

// التحقق من الجلسة
final isLoggedIn = await AuthService.isLoggedIn();
if (isLoggedIn) {
  await AuthService.autoLogin();
}

// تسجيل الخروج
await AuthService.logout();
```

---

## 2. Hive Service - `lib/data/services/hive_service.dart`

### الوصف
خدمة قاعدة البيانات المحلية لتخزين الوجبات باستخدام Hive.

### الأكواد

```dart
class HiveService {
  static const String _mealsBoxName = 'meals';
  static Box<MealModel>? _mealsBox;

  // التهيئة
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // تسجيل الـ Adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MealModelAdapter());
    }
    
    _mealsBox = await Hive.openBox<MealModel>(_mealsBoxName);
  }

  // الحصول على الـ Box
  static Box<MealModel> get mealsBox {
    if (_mealsBox == null || !_mealsBox!.isOpen) {
      throw Exception('Meals box is not initialized');
    }
    return _mealsBox!;
  }

  // إضافة وجبة
  static Future<void> addMeal(MealModel meal) async {
    await mealsBox.put(meal.id, meal);
  }

  // الحصول على جميع الوجبات
  static List<MealModel> getAllMeals() {
    return mealsBox.values.toList();
  }

  // الحصول على وجبات اليوم
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

  // الحصول على وجبات حسب النوع
  static List<MealModel> getMealsByType(String type) {
    return getTodayMeals().where((meal) => meal.mealType == type).toList();
  }

  // حذف وجبة
  static Future<void> deleteMeal(String id) async {
    await mealsBox.delete(id);
  }

  // مسح جميع الوجبات
  static Future<void> clearAllMeals() async {
    await mealsBox.clear();
  }

  // عدد وجبات اليوم
  static int getTodayMealsCount() {
    return getTodayMeals().length;
  }

  // تحديث وجبة
  static Future<void> updateMeal(MealModel meal) async {
    await mealsBox.put(meal.id, meal);
  }
}
```

### الاستخدام

```dart
// في main.dart
await HiveService.init();

// إضافة وجبة
final meal = MealModel(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  name: 'دجاج مشوي',
  calories: '250',
  protein: '30',
  carbs: '10',
  fat: '12',
  categoryName: 'لحوم',
  categoryEmoji: '🍗',
  categoryColorValue: Colors.red.value,
  addedAt: DateTime.now(),
  mealType: 'lunch',
);
await HiveService.addMeal(meal);

// الحصول على وجبات اليوم
final todayMeals = HiveService.getTodayMeals();

// حذف وجبة
await HiveService.deleteMeal(meal.id);
```

---

## 3. Calculation Service - `lib/data/services/calculation_service.dart`

### الوصف
خدمة حساب BMI, BMR, TDEE والعناصر الغذائية.

### الأكواد

```dart
class CalculationService {
  // حساب BMI (مؤشر كتلة الجسم)
  double calculateBMI(double weight, double height) {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // تصنيف BMI
  String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'نقص الوزن';
    if (bmi < 25) return 'وزن طبيعي';
    if (bmi < 30) return 'زيادة في الوزن';
    return 'سمنة';
  }

  // حساب BMR (معدل الأيض الأساسي) - معادلة Mifflin-St Jeor
  double calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // حساب TDEE (إجمالي الطاقة اليومية المستهلكة)
  double calculateTDEE(double bmr, String activityLevel, String? physiologicalState) {
    double activityMultiplier;

    switch (activityLevel) {
      case 'sedentary':      // قليل جداً
        activityMultiplier = 1.2;
        break;
      case 'light':          // خفيف
        activityMultiplier = 1.375;
        break;
      case 'moderate':       // معتدل
        activityMultiplier = 1.55;
        break;
      case 'active':         // نشط
        activityMultiplier = 1.725;
        break;
      case 'very_active':    // نشط جداً
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double tdee = bmr * activityMultiplier;

    // إضافة سعرات للحالات الفسيولوجية الخاصة
    if (physiologicalState == 'pregnant') {
      tdee += 300;  // حامل
    } else if (physiologicalState == 'breastfeeding') {
      tdee += 500;  // مرضعة
    } else if (physiologicalState == 'athlete') {
      tdee += 200;  // رياضي
    }

    return tdee;
  }

  // حساب توزيع العناصر الغذائية الكبرى
  MacroNutrients calculateMacros(double tdee, String? physiologicalState) {
    double carbsPercent, proteinPercent, fatsPercent;

    if (physiologicalState == 'athlete') {
      carbsPercent = 0.50;    // 50% كربوهيدرات
      proteinPercent = 0.30;  // 30% بروتين
      fatsPercent = 0.20;     // 20% دهون
    } else {
      carbsPercent = 0.45;    // 45% كربوهيدرات
      proteinPercent = 0.25;  // 25% بروتين
      fatsPercent = 0.30;     // 30% دهون
    }

    double carbsCalories = tdee * carbsPercent;
    double proteinCalories = tdee * proteinPercent;
    double fatsCalories = tdee * fatsPercent;

    // تحويل السعرات إلى جرامات
    // 1 جرام كربوهيدرات = 4 سعرات
    // 1 جرام بروتين = 4 سعرات
    // 1 جرام دهون = 9 سعرات
    double carbsGrams = carbsCalories / 4;
    double proteinGrams = proteinCalories / 4;
    double fatsGrams = fatsCalories / 9;

    return MacroNutrients(
      carbs: carbsGrams,
      protein: proteinGrams,
      fats: fatsGrams,
      carbsCalories: carbsCalories,
      proteinCalories: proteinCalories,
      fatsCalories: fatsCalories,
    );
  }

  // الحساب الشامل
  CalculationResult performCalculation(UserModel user) {
    double bmi = calculateBMI(user.weight, user.height);
    String bmiCategory = getBMICategory(bmi);
    double bmr = calculateBMR(user.weight, user.height, user.age, user.gender);
    double tdee = calculateTDEE(bmr, user.activityLevel, user.physiologicalState);
    MacroNutrients macros = calculateMacros(tdee, user.physiologicalState);

    return CalculationResult(
      bmi: bmi,
      bmiCategory: bmiCategory,
      bmr: bmr,
      tdee: tdee,
      macros: macros,
    );
  }
}
```

### مثال الاستخدام

```dart
final service = CalculationService();

final user = UserModel(
  age: 25,
  gender: 'male',
  height: 175,  // سم
  weight: 70,   // كجم
  activityLevel: 'moderate',
  physiologicalState: null,
);

// حساب شامل
final result = service.performCalculation(user);

print('BMI: ${result.bmi.toStringAsFixed(1)}');
print('Category: ${result.bmiCategory}');
print('BMR: ${result.bmr.toStringAsFixed(0)} cal');
print('TDEE: ${result.tdee.toStringAsFixed(0)} cal');
print('Carbs: ${result.macros.carbs.toStringAsFixed(1)}g');
print('Protein: ${result.macros.protein.toStringAsFixed(1)}g');
print('Fats: ${result.macros.fats.toStringAsFixed(1)}g');
```

---

## 4. Food Vision Service - `lib/data/services/food_vision_service.dart`

### الوصف
خدمة تحليل الطعام باستخدام Google Gemini AI.

### الأكواد الرئيسية

```dart
class FoodVisionService {
  final String apiKey = 'YOUR_GEMINI_API_KEY';
  
  static DateTime? _lastRequestTime;
  static const Duration _minDelayBetweenRequests = Duration(seconds: 2);

  // الانتظار بين الطلبات
  Future<void> _waitIfNeeded() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minDelayBetweenRequests) {
        final waitTime = _minDelayBetweenRequests - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  // الحصول على توصيات AI
  Future<String> getAIRecommendations(UserModel user, CalculationResult result) async {
    await _waitIfNeeded();

    final prompt = '''
أنت أخصائي تغذية خبير. قدم توصيات غذائية مخصصة للشخص التالي:

📊 البيانات:
- العمر: ${user.age} سنة
- الجنس: ${user.gender == 'male' ? 'ذكر' : 'أنثى'}
- الوزن: ${user.weight} كجم
- الطول: ${user.height} سم
- BMI: ${result.bmi.toStringAsFixed(1)} (${result.bmiCategory})
- السعرات اليومية: ${result.tdee.toStringAsFixed(0)} سعرة
- مستوى النشاط: ${_getActivityLevelArabic(user.activityLevel)}

📝 المطلوب (بالعربية):
1. تقييم الحالة الصحية
2. 5 نصائح غذائية محددة
3. مثال على وجبات يومية
4. أطعمة يُنصح بها
5. أطعمة يُنصح بتجنبها
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 8000,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else if (response.statusCode == 429) {
        return 'تم تجاوز حد الطلبات. انتظر 10 ثواني وحاول مرة أخرى';
      }
      return 'خطأ في الحصول على التوصيات';
    } catch (e) {
      return 'خطأ: $e';
    }
  }

  // تحليل صورة الطعام
  Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    await _waitIfNeeded();

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''
حلل هذه الصورة وقدم المعلومات بهذا التنسيق:

FOOD_NAME: [اسم الطعام بالعربية]
INGREDIENTS: [المكونات]
PORTION_SIZE: [صغير/متوسط/كبير]
CALORIES: [رقم]
PROTEIN: [رقم]
CARBS: [رقم]
FATS: [رقم]
FIBER: [رقم]
HEALTH_RATING: [ممتاز/جيد/متوسط/ضعيف]
TIPS: [نصيحة]
DETAILED_ANALYSIS: [تحليل تفصيلي]
                '''
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final analysisText = data['candidates'][0]['content']['parts'][0]['text'];
      return _parseAnalysis(analysisText);
    }
    throw Exception('فشل تحليل الصورة');
  }

  // تحليل النص
  FoodAnalysisResult _parseAnalysis(String text) {
    return FoodAnalysisResult(
      foodName: _extractField(text, 'FOOD_NAME'),
      ingredients: _extractField(text, 'INGREDIENTS'),
      portionSize: _extractField(text, 'PORTION_SIZE'),
      calories: _extractNumber(text, 'CALORIES'),
      protein: _extractNumber(text, 'PROTEIN'),
      carbs: _extractNumber(text, 'CARBS'),
      fats: _extractNumber(text, 'FATS'),
      fiber: _extractNumber(text, 'FIBER'),
      healthRating: _extractField(text, 'HEALTH_RATING'),
      tips: _extractField(text, 'TIPS'),
      detailedAnalysis: _extractField(text, 'DETAILED_ANALYSIS'),
    );
  }
}
```

### الاستخدام

```dart
final service = FoodVisionService();

// الحصول على توصيات
final recommendations = await service.getAIRecommendations(user, result);
print(recommendations);

// تحليل صورة طعام
final imageFile = File('path/to/image.jpg');
final analysis = await service.analyzeFood(imageFile);
print('Food: ${analysis.foodName}');
print('Calories: ${analysis.calories}');
```

---

## 5. Notification Services

### `lib/data/services/notification_service.dart`

```dart
class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  // إشعار إضافة وجبة
  Future<void> showMealNotification({
    required String mealName,
    required String calories,
    required String protein,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'meal_channel',
      'وجبات',
      channelDescription: 'إشعارات الوجبات المضافة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      'تم إضافة وجبة جديدة',
      '$mealName - $calories سعرة حرارية',
      details,
    );

    // حفظ في السجل
    await NotificationHistoryService.addNotification(
      title: 'تم إضافة وجبة جديدة',
      body: '$mealName - $calories سعرة حرارية',
      type: 'meal',
      data: {'mealName': mealName, 'calories': calories},
    );
  }

  // إشعار نصيحة يومية
  Future<void> scheduleDailyTip(String tip) async {
    await _notificationsPlugin.show(
      DateTime.now().millisecond + 100,
      'نصيحة اليوم 💡',
      tip,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tips_channel',
          'نصائح',
          importance: Importance.high,
        ),
      ),
    );
  }
}
```

---

## ملخص الخدمات

### الخدمات المتوفرة:
1. ✅ **AuthService**: المصادقة والجلسات
2. ✅ **HiveService**: قاعدة البيانات المحلية
3. ✅ **CalculationService**: حسابات BMI/BMR/TDEE
4. ✅ **FoodVisionService**: تحليل الطعام بالـ AI
5. ✅ **NotificationService**: الإشعارات
6. ✅ **PDFService**: تصدير التقارير
7. ✅ **TipsService**: النصائح الغذائية
8. ✅ **SocialMediaService**: خدمات السوشيال ميديا

### الاستخدام العام:
```dart
// في main.dart
await HiveService.init();
await NotificationService().initialize();
DioHelper.init();

// في التطبيق
final authResult = await AuthService.login(email, password);
final meals = HiveService.getTodayMeals();
final result = CalculationService().performCalculation(user);
```
