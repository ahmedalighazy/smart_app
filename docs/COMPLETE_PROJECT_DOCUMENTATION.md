# 📚 التوثيق الكامل لمشروع Smart Nutrition App

## 📋 جدول المحتويات

### 📖 الملفات الرئيسية:

1. **[01_CORE_LAYER.md](./01_CORE_LAYER.md)** - الطبقة الأساسية
   - الألوان والثيمات
   - HTTP Client (Dio)
   - نظام الترجمة

2. **[02_DATA_LAYER_SERVICES.md](./02_DATA_LAYER_SERVICES.md)** - طبقة الخدمات
   - AuthService - المصادقة
   - HiveService - قاعدة البيانات المحلية
   - CalculationService - الحسابات الغذائية
   - FoodVisionService - تحليل الطعام بالـ AI
   - NotificationService - الإشعارات
   - PDFService - تصدير التقارير

3. **[03_LOGIC_LAYER_CUBITS.md](./03_LOGIC_LAYER_CUBITS.md)** - إدارة الحالة
   - UserCubit - المستخدم والحسابات
   - SettingsCubit - الإعدادات
   - FoodScannerCubit - مسح الطعام
   - TipsCubit - النصائح
   - NotificationHistoryCubit - سجل الإشعارات

4. **[04_PRESENTATION_LAYER_SCREENS.md](./04_PRESENTATION_LAYER_SCREENS.md)** - الشاشات
   - Main Entry Point
   - Authentication Screens
   - Main Navigation
   - Input & Results Screens
   - Food Scanner Screen

5. **[05_ADVANCED_FEATURES.md](./05_ADVANCED_FEATURES.md)** - المميزات المتقدمة
   - Food Scanner with AI
   - AI Recommendations
   - PDF Export
   - Notifications System

6. **[06_USAGE_GUIDE.md](./06_USAGE_GUIDE.md)** - دليل الاستخدام الكامل
   - البدء السريع
   - إدارة الحساب
   - حساب الاحتياجات الغذائية
   - مسح الطعام
   - إدارة الوجبات
   - حل المشاكل الشائعة

---

## 🎯 نظرة عامة على المشروع {#نظرة-عامة}

**Smart Nutrition App** هو تطبيق Flutter متكامل لحساب السعرات الحرارية والعناصر الغذائية باستخدام الذكاء الاصطناعي.

### المميزات الرئيسية:
- ✅ حساب BMI و BMR و TDEE
- 📸 مسح الطعام بالكاميرا باستخدام Google Gemini AI
- 🤖 توصيات غذائية مخصصة من AI
- 📊 تتبع الوجبات اليومية
- 💡 نصائح غذائية ورياضية
- 🔔 نظام إشعارات متقدم
- 📄 تصدير التقارير PDF
- 🌙 وضع داكن/فاتح
- 🌍 دعم اللغتين العربية والإنجليزية
- 🔐 نظام مصادقة كامل

### التقنيات المستخدمة:
- **Framework**: Flutter 3.x
- **State Management**: BLoC/Cubit
- **Local Database**: Hive
- **API Client**: Dio
- **AI Service**: Google Gemini API
- **Charts**: FL Chart
- **Notifications**: Flutter Local Notifications
- **PDF Generation**: PDF Package

---

## 🏗️ هيكل المشروع {#هيكل-المشروع}

```
lib/
├── core/                    # الطبقة الأساسية
│   ├── constants/
│   │   ├── colors.dart     # ألوان التطبيق والثيمات
│   │   └── dio/
│   │       └── dio_helper.dart  # إعدادات HTTP
│   └── localization/
│       └── app_localizations.dart  # الترجمة
│
├── data/                    # طبقة البيانات
│   ├── models/             # نماذج البيانات
│   │   ├── user_model.dart
│   │   └── social_media_model.dart
│   └── services/           # الخدمات
│       ├── auth_service.dart
│       ├── hive_service.dart
│       ├── meal_model.dart
│       ├── calculation_service.dart
│       ├── food_vision_service.dart
│       ├── notification_service.dart
│       ├── notification_history_service.dart
│       ├── tips_service.dart
│       ├── background_tips_service.dart
│       ├── pdf_service.dart
│       └── social_media_service.dart
│
├── logic/                   # طبقة المنطق
│   └── cubits/             # State Management
│       ├── user_cubit.dart
│       ├── settings_cubit.dart
│       ├── food_scanner_cubit.dart
│       ├── food_search_cubit.dart
│       ├── social_media_cubit.dart
│       ├── tips_cubit.dart
│       ├── tips_state.dart
│       ├── notification_history_cubit.dart
│       └── notification_history_state.dart
│
├── presentation/            # طبقة العرض
│   └── screens/            # الشاشات
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── home_screen/
│       │   ├── home_screen.dart
│       │   ├── home_content_screen.dart
│       │   └── widgets/
│       ├── main_navigation_screen.dart
│       ├── splash_screen.dart
│       ├── input_screen.dart
│       ├── results_screen.dart
│       ├── food_scanner_screen.dart
│       ├── food_search_screen.dart
│       ├── ai_recommendations_screen.dart
│       ├── tips_screen.dart
│       ├── notifications_screen.dart
│       ├── settings_screen.dart
│       ├── pdf_viewer_screen.dart
│       ├── privacy_policy_screen.dart
│       └── terms_of_service_screen.dart
│
└── main.dart               # نقطة البداية
```

---

## 🚀 البدء السريع

### 1. المتطلبات

```bash
# تثبيت Flutter
flutter doctor

# تثبيت المكتبات
flutter pub get

# تشغيل build_runner
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. إعداد API Keys

```dart
// في lib/data/services/food_vision_service.dart
final String apiKey = 'YOUR_GEMINI_API_KEY';
```

### 3. تشغيل التطبيق

```bash
flutter run
```

---

## 📊 إحصائيات المشروع

- **إجمالي الملفات**: ~50 ملف Dart
- **عدد الشاشات**: 18 شاشة
- **عدد الخدمات**: 11 خدمة
- **عدد Cubits**: 8 state managers
- **عدد Models**: 3 نماذج بيانات
- **سطور الكود**: ~15,000 سطر

---

## 📖 كيفية استخدام التوثيق

### للمطورين:
1. ابدأ بـ **01_CORE_LAYER.md** لفهم الأساسيات
2. انتقل إلى **02_DATA_LAYER_SERVICES.md** لفهم الخدمات
3. اقرأ **03_LOGIC_LAYER_CUBITS.md** لفهم إدارة الحالة
4. راجع **04_PRESENTATION_LAYER_SCREENS.md** للشاشات
5. استكشف **05_ADVANCED_FEATURES.md** للمميزات المتقدمة

### للمستخدمين:
- اقرأ **06_USAGE_GUIDE.md** للحصول على دليل استخدام كامل

---

## 🤝 المساهمة

للمساهمة في المشروع:
1. Fork المشروع
2. أنشئ branch جديد
3. قم بالتعديلات
4. أرسل Pull Request

---

## 📞 الدعم

- 📧 البريد: support@smartnutrition.com
- 🌐 الموقع: www.smartnutrition.com
- 📱 GitHub: github.com/smartnutrition

---

## 📝 الترخيص

هذا المشروع مرخص تحت MIT License.

---

## ✨ الخلاصة

هذا التوثيق يغطي:
- ✅ جميع طبقات المشروع
- ✅ كل الأكواد مع الشرح
- ✅ أمثلة عملية
- ✅ دليل استخدام كامل
- ✅ حل المشاكل الشائعة
- ✅ أفضل الممارسات

**تم إنشاء هذا التوثيق بواسطة Kiro AI** 🤖

---

## 🎯 نظرة عامة على المشروع {#نظرة-عامة}

**Smart Nutrition App** هو تطبيق Flutter متكامل لحساب السعرات الحرارية والعناصر الغذائية باستخدام الذكاء الاصطناعي.

### المميزات الرئيسية:
- ✅ حساب BMI و BMR و TDEE
- 📸 مسح الطعام بالكاميرا باستخدام Google Gemini AI
- 🤖 توصيات غذائية مخصصة من AI
- 📊 تتبع الوجبات اليومية
- 💡 نصائح غذائية ورياضية
- 🔔 نظام إشعارات متقدم
- 📄 تصدير التقارير PDF
- 🌙 وضع داكن/فاتح
- 🌍 دعم اللغتين العربية والإنجليزية
- 🔐 نظام مصادقة كامل

### التقنيات المستخدمة:
- **Framework**: Flutter 3.x
- **State Management**: BLoC/Cubit
- **Local Database**: Hive
- **API Client**: Dio
- **AI Service**: Google Gemini API
- **Charts**: FL Chart
- **Notifications**: Flutter Local Notifications
- **PDF Generation**: PDF Package

---

## 🏗️ هيكل المشروع {#هيكل-المشروع}

```
lib/
├── core/                    # الطبقة الأساسية
│   ├── constants/
│   │   ├── colors.dart     # ألوان التطبيق والثيمات
│   │   └── dio/
│   │       └── dio_helper.dart  # إعدادات HTTP
│   └── localization/
│       └── app_localizations.dart  # الترجمة
│
├── data/                    # طبقة البيانات
│   ├── models/             # نماذج البيانات
│   │   ├── user_model.dart
│   │   └── social_media_model.dart
│   └── services/           # الخدمات
│       ├── auth_service.dart
│       ├── hive_service.dart
│       ├── meal_model.dart
│       ├── calculation_service.dart
│       ├── food_vision_service.dart
│       ├── notification_service.dart
│       ├── notification_history_service.dart
│       ├── tips_service.dart
│       ├── background_tips_service.dart
│       ├── pdf_service.dart
│       └── social_media_service.dart
│
├── logic/                   # طبقة المنطق
│   └── cubits/             # State Management
│       ├── user_cubit.dart
│       ├── settings_cubit.dart
│       ├── food_scanner_cubit.dart
│       ├── food_search_cubit.dart
│       ├── social_media_cubit.dart
│       ├── tips_cubit.dart
│       ├── tips_state.dart
│       ├── notification_history_cubit.dart
│       └── notification_history_state.dart
│
├── presentation/            # طبقة العرض
│   └── screens/            # الشاشات
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── home_screen/
│       │   ├── home_screen.dart
│       │   ├── home_content_screen.dart
│       │   └── widgets/
│       │       ├── category_card.dart
│       │       ├── category_preview.dart
│       │       ├── feature_card.dart
│       │       ├── food_categories_data.dart
│       │       ├── food_details_screen.dart
│       │       ├── food_item_card.dart
│       │       ├── my_meals_screen.dart
│       │       └── target_card.dart
│       ├── main_navigation_screen.dart
│       ├── splash_screen.dart
│       ├── input_screen.dart
│       ├── results_screen.dart
│       ├── food_scanner_screen.dart
│       ├── food_search_screen.dart
│       ├── ai_recommendations_screen.dart
│       ├── tips_screen.dart
│       ├── notifications_screen.dart
│       ├── settings_screen.dart
│       ├── pdf_viewer_screen.dart
│       ├── privacy_policy_screen.dart
│       └── terms_of_service_screen.dart
│
└── main.dart               # نقطة البداية
```

---

## 🎨 Core Layer - الطبقة الأساسية {#core-layer}

### 1. `lib/core/constants/colors.dart`

**الوصف**: يحتوي على جميع الألوان والثيمات المستخدمة في التطبيق.

**الأكواد الرئيسية**:

```dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF8BC34A);
  static const Color primaryDark = Color(0xFF388E3C);

  // Nutrient Colors
  static const Color calories = Color(0xFFFF9800);
  static const Color protein = Color(0xFFE53935);
  static const Color carbs = Color(0xFF2196F3);
  static const Color fats = Color(0xFFFFC107);
  static const Color fiber = Color(0xFF9C27B0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
```

**الاستخدام**:
- يستخدم في جميع الشاشات لتوحيد الألوان
- يوفر ثيمات فاتحة وداكنة
- يحدد ألوان خاصة لكل عنصر غذائي

---

### 2. `lib/core/constants/dio/dio_helper.dart`

**الوصف**: مساعد لإدارة طلبات HTTP باستخدام Dio.

**الأكواد الرئيسية**:

```dart
class DioHelper {
  static late Dio dio;
  static const String baseUrl = 'https://apisoapp.twingroups.com';

  // Initialize Dio
  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // Set token in headers
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Generic POST request
  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? data,
  }) async {
    return await dio.post(url, data: data);
  }
}
```

**الوظائف**:
- `init()`: تهيئة Dio مع الإعدادات الأساسية
- `setToken()`: إضافة التوكين للـ headers
- `postData()`, `getData()`, `putData()`, `deleteData()`: طلبات HTTP

**الاستخدام**:
```dart
// في main.dart
DioHelper.init();

// في أي service
final response = await DioHelper.postData(
  url: '/auth/login',
  data: {'email': email, 'password': password},
);
```

---

### 3. `lib/core/localization/app_localizations.dart`

**الوصف**: نظام الترجمة للتطبيق (عربي/إنجليزي).

**الأكواد الرئيسية**:

```dart
class AppLocalizations {
  final Locale locale;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Smart Nutrition',
      'home': 'Home',
      'scanner': 'Scanner',
      'meals': 'My Meals',
      'settings': 'Settings',
    },
    'ar': {
      'app_name': 'التغذية الذكية',
      'home': 'الرئيسية',
      'scanner': 'الماسح',
      'meals': 'وجباتي',
      'settings': 'الإعدادات',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

// Extension للاستخدام السهل
extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
```

**الاستخدام**:
```dart
Text(context.tr('home'))  // يعرض "الرئيسية" أو "Home" حسب اللغة
```

---

## 💾 Data Layer - طبقة البيانات {#data-layer}

### 1. Models - النماذج

#### `lib/data/models/user_model.dart`

**الوصف**: نموذج بيانات المستخدم ونتائج الحسابات.

**الأكواد**:

```dart
class UserModel extends Equatable {
  final String? name;
  final int age;
  final String gender;        // 'male' or 'female'
  final double height;        // in cm
  final double weight;        // in kg
  final String activityLevel;
  final String? physiologicalState;

  const UserModel({
    this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    this.physiologicalState,
  });

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'physiologicalState': physiologicalState,
    };
  }

  // إنشاء من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      activityLevel: json['activityLevel'],
      physiologicalState: json['physiologicalState'],
    );
  }
}
```

**نماذج إضافية في نفس الملف**:

```dart
// العناصر الغذائية الكبرى
class MacroNutrients extends Equatable {
  final double carbs;
  final double protein;
  final double fats;
  final double carbsCalories;
  final double proteinCalories;
  final double fatsCalories;
}

// نتائج الحسابات
class CalculationResult extends Equatable {
  final double bmi;
  final String bmiCategory;
  final double bmr;
  final double tdee;
  final MacroNutrients macros;
}

// نتائج تحليل الطعام بالـ AI
class FoodAnalysisResult extends Equatable {
  final String foodName;
  final String ingredients;
  final String portionSize;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final int fiber;
  final String healthRating;
  final String tips;
  final String detailedAnalysis;
}
```

---

#### `lib/data/models/social_media_model.dart`

**الوصف**: نماذج المستخدم والمصادقة للسوشيال ميديا.

**الأكواد**:

```dart
class SocialMediaUser {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? profilePicture;
  final String? bio;
  final DateTime? createdAt;

  factory SocialMediaUser.fromJson(Map<String, dynamic> json) {
    return SocialMediaUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}

class AuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;
  final SocialMediaUser? user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['access_token'] ?? json['data']?['access_token'],
      refreshToken: json['refresh_token'] ?? json['data']?['refresh_token'],
      user: json['user'] != null 
          ? SocialMediaUser.fromJson(json['user'])
          : null,
    );
  }
}
```

---

#### `lib/data/services/meal_model.dart`

**الوصف**: نموذج الوجبة مع Hive للتخزين المحلي.

**الأكواد**:

```dart
@HiveType(typeId: 0)
class MealModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String calories;

  @HiveField(3)
  String protein;

  @HiveField(4)
  String carbs;

  @HiveField(5)
  String fat;

  @HiveField(6)
  String categoryName;

  @HiveField(7)
  String categoryEmoji;

  @HiveField(8)
  int categoryColorValue;

  @HiveField(9)
  DateTime addedAt;

  @HiveField(10)
  String mealType;

  @HiveField(11)
  String? imageUrl;

  // حساب إجمالي العناصر الغذائية
  static Map<String, double> getTotalNutrition(List<MealModel> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var meal in meals) {
      totalCalories += double.tryParse(meal.calories) ?? 0;
      totalProtein += double.tryParse(meal.protein) ?? 0;
      totalCarbs += double.tryParse(meal.carbs) ?? 0;
      totalFat += double.tryParse(meal.fat) ?? 0;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
}
```

---

### 2. Services - الخدمات

#### `lib/data/services/auth_service.dart`

**الوصف**: خدمة المصادقة وإدارة الجلسات.

**الوظائف الرئيسية**:

```dart
class AuthService {
  static const _secureStorage = FlutterSecureStorage();

  // التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  // تسجيل الدخول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioHelper.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        await _secureStorage.write(key: 'access_token', value: accessToken);
        DioHelper.setToken(accessToken);
        
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': 'فشل تسجيل الدخول'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    await _secureStorage.deleteAll();
    DioHelper.removeToken();
  }
}
```

**الاستخدام**:
```dart
// تسجيل الدخول
final result = await AuthService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (result['success']) {
  // الانتقال للصفحة الرئيسية
}
```

---

#### `lib/data/services/hive_service.dart`

**الوصف**: خدمة قاعدة البيانات المحلية Hive.

**الوظائف**:

```dart
class HiveService {
  static Box<MealModel>? _mealsBox;

  // التهيئة
  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MealModelAdapter());
    }
    
    _mealsBox = await Hive.openBox<MealModel>('meals');
  }

  // إضافة وجبة
  static Future<void> addMeal(MealModel meal) async {
    await _mealsBox!.put(meal.id, meal);
  }

  // الحصول على وجبات اليوم
  static List<MealModel> getTodayMeals() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _mealsBox!.values.where((meal) {
      final mealDate = DateTime(
        meal.addedAt.year,
        meal.addedAt.month,
        meal.addedAt.day,
      );
      return mealDate == today;
    }).toList();
  }

  // حذف وجبة
  static Future<void> deleteMeal(String id) async {
    await _mealsBox!.delete(id);
  }
}
```

---

#### `lib/data/services/calculation_service.dart`

**الوصف**: خدمة حساب BMI, BMR, TDEE والعناصر الغذائية.

**الوظائف**:

```dart
class CalculationService {
  // حساب BMI
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

  // حساب BMR - معادلة Mifflin-St Jeor
  double calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // حساب TDEE
  double calculateTDEE(double bmr, String activityLevel, String? physiologicalState) {
    double activityMultiplier;

    switch (activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double tdee = bmr * activityMultiplier;

    // إضافة سعرات للحالات الفسيولوجية
    if (physiologicalState == 'pregnant') {
      tdee += 300;
    } else if (physiologicalState == 'breastfeeding') {
      tdee += 500;
    }

    return tdee;
  }

  // حساب توزيع العناصر الغذائية
  MacroNutrients calculateMacros(double tdee, String? physiologicalState) {
    double carbsPercent = 0.45;
    double proteinPercent = 0.25;
    double fatsPercent = 0.30;

    double carbsCalories = tdee * carbsPercent;
    double proteinCalories = tdee * proteinPercent;
    double fatsCalories = tdee * fatsPercent;

    // تحويل السعرات إلى جرامات
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
}
```

**مثال الاستخدام**:
```dart
final service = CalculationService();
final user = UserModel(
  age: 25,
  gender: 'male',
  height: 175,
  weight: 70,
  activityLevel: 'moderate',
);

final bmi = service.calculateBMI(user.weight, user.height);
final bmr = service.calculateBMR(user.weight, user.height, user.age, user.gender);
final tdee = service.calculateTDEE(bmr, user.activityLevel, null);
final macros = service.calculateMacros(tdee, null);

print('BMI: $bmi');
print('TDEE: $tdee');
print('Carbs: ${macros.carbs}g');
```

---

