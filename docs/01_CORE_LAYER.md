# 🎨 Core Layer - الطبقة الأساسية

## نظرة عامة
الطبقة الأساسية تحتوي على الثوابت والإعدادات المشتركة في كل التطبيق.

---

## 1. Colors & Themes - `lib/core/constants/colors.dart`

### الوصف
يحتوي على جميع الألوان والثيمات (فاتح/داكن) المستخدمة في التطبيق.

### الأكواد الرئيسية

```dart
class AppColors {
  // Primary Colors - الألوان الأساسية
  static const Color primary = Color(0xFF4CAF50);      // أخضر
  static const Color primaryLight = Color(0xFF8BC34A);
  static const Color primaryDark = Color(0xFF388E3C);
  static const Color accent = Color(0xFF8BC34A);

  // Background - الخلفيات
  static const Color background = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors - ألوان النصوص
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Nutrient Colors - ألوان العناصر الغذائية
  static const Color calories = Color(0xFFFF9800);  // برتقالي
  static const Color protein = Color(0xFFE53935);   // أحمر
  static const Color carbs = Color(0xFF2196F3);     // أزرق
  static const Color fats = Color(0xFFFFC107);      // أصفر
  static const Color fiber = Color(0xFF9C27B0);     // بنفسجي

  // Status Colors - ألوان الحالات
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
```

### الثيمات

```dart
class AppTheme {
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.cairoTextTheme(),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    );
  }
}
```

### الاستخدام

```dart
// في أي widget
Container(
  color: AppColors.primary,
  child: Text(
    'مرحباً',
    style: TextStyle(color: AppColors.textDark),
  ),
)

// استخدام الثيم
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

---

## 2. HTTP Client - `lib/core/constants/dio/dio_helper.dart`

### الوصف
مساعد لإدارة جميع طلبات HTTP باستخدام مكتبة Dio.

### الإعدادات الأساسية

```dart
class DioHelper {
  static late Dio dio;
  static const String baseUrl = 'https://apisoapp.twingroups.com';

  // تهيئة Dio
  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // إضافة interceptors للتسجيل
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
```

### الوظائف الرئيسية

```dart
// إضافة/إزالة التوكين
static void setToken(String token) {
  dio.options.headers['Authorization'] = 'Bearer $token';
}

static void removeToken() {
  dio.options.headers.remove('Authorization');
}

// GET Request
static Future<Response> getData({
  required String url,
  Map<String, dynamic>? query,
}) async {
  return await dio.get(url, queryParameters: query);
}

// POST Request
static Future<Response> postData({
  required String url,
  Map<String, dynamic>? data,
  Map<String, dynamic>? query,
}) async {
  return await dio.post(url, data: data, queryParameters: query);
}

// PUT Request
static Future<Response> putData({
  required String url,
  Map<String, dynamic>? data,
}) async {
  return await dio.put(url, data: data);
}

// DELETE Request
static Future<Response> deleteData({
  required String url,
  Map<String, dynamic>? data,
}) async {
  return await dio.delete(url, data: data);
}
```

### مثال الاستخدام

```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.init();  // تهيئة Dio
  runApp(MyApp());
}

// في أي service
try {
  final response = await DioHelper.postData(
    url: '/auth/login',
    data: {
      'email': 'user@example.com',
      'password': 'password123',
    },
  );
  
  if (response.statusCode == 200) {
    print('Success: ${response.data}');
  }
} catch (e) {
  print('Error: $e');
}
```

---

## 3. Localization - `lib/core/localization/app_localizations.dart`

### الوصف
نظام الترجمة الذي يدعم اللغتين العربية والإنجليزية.

### الأكواد الرئيسية

```dart
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // قاموس الترجمة
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Smart Nutrition',
      'home': 'Home',
      'scanner': 'Scanner',
      'meals': 'My Meals',
      'settings': 'Settings',
      'calories': 'Calories',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fats': 'Fats',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
    },
    'ar': {
      'app_name': 'التغذية الذكية',
      'home': 'الرئيسية',
      'scanner': 'الماسح',
      'meals': 'وجباتي',
      'settings': 'الإعدادات',
      'calories': 'السعرات',
      'protein': 'البروتين',
      'carbs': 'الكربوهيدرات',
      'fats': 'الدهون',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
```

### Extension للاستخدام السهل

```dart
extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
```

### الإعداد في MaterialApp

```dart
MaterialApp(
  locale: Locale('ar'),  // أو 'en'
  supportedLocales: const [
    Locale('ar'),
    Locale('en'),
  ],
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: HomeScreen(),
)
```

### الاستخدام في الشاشات

```dart
// الطريقة الأولى
Text(AppLocalizations.of(context)!.translate('home'))

// الطريقة الثانية (باستخدام Extension)
Text(context.tr('home'))

// في AppBar
AppBar(
  title: Text(context.tr('app_name')),
)

// في Button
ElevatedButton(
  onPressed: () {},
  child: Text(context.tr('login')),
)
```

### إضافة ترجمات جديدة

```dart
// في _localizedValues
'en': {
  'new_key': 'New Text',
  'welcome_message': 'Welcome to Smart Nutrition!',
},
'ar': {
  'new_key': 'نص جديد',
  'welcome_message': 'مرحباً بك في التغذية الذكية!',
},
```

---

## ملخص الطبقة الأساسية

### الملفات الرئيسية:
1. **colors.dart**: الألوان والثيمات
2. **dio_helper.dart**: إدارة HTTP requests
3. **app_localizations.dart**: نظام الترجمة

### الاستخدام العام:
```dart
// في main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioHelper.init();  // تهيئة HTTP client
  runApp(MyApp());
}

// في أي widget
Container(
  color: AppColors.primary,  // استخدام الألوان
  child: Text(
    context.tr('home'),  // استخدام الترجمة
    style: TextStyle(color: AppColors.white),
  ),
)

// في أي service
final response = await DioHelper.postData(
  url: '/endpoint',
  data: {'key': 'value'},
);
```

### المميزات:
✅ ألوان موحدة في كل التطبيق  
✅ دعم الوضع الداكن والفاتح  
✅ HTTP client جاهز مع interceptors  
✅ دعم لغتين (عربي/إنجليزي)  
✅ سهولة الإضافة والتعديل
