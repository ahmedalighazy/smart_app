import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'Smart Nutrition',
      'app_description':
          'Smart Nutrition app helps you track your meals and calculate calories using artificial intelligence.',

      // Navigation
      'home': 'Home',
      'scanner': 'Scanner',
      'meals': 'My Meals',
      'settings': 'Settings',

      // Home
      'welcome': 'Welcome!',
      'subtitle': 'Track your nutrition smartly',
      'food_categories': 'Food Categories',
      'services': 'Services',
      'today_meals': 'Today\'s Meals',

      // Services
      'nutrition_calc': 'Nutrition Calculator',
      'food_scanner': 'Food Scanner',
      'ai_recommendations': 'AI Recommendations',

      // Meals
      'add_meal': 'Add Meal',
      'meal_type': 'Meal Type',
      'select_category': 'Select Category',
      'select_food': 'Select Food',
      'no_meals': 'No meals yet',

      // Meal Types
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',

      // Nutrients
      'calories': 'Calories',
      'protein': 'Protein',
      'carbs': 'Carbs',
      'fats': 'Fats',

      // Settings
      'customize_app': 'Customize your app',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',

      // About
      'about': 'About',
      'version': 'Version',
      'privacy': 'Privacy Policy',
      'terms': 'Terms of Service',

      // Auth
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'login': 'Login',
      'register': 'Register',

      // Actions
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'ok': 'OK',

      // Scanner
      'scan_food': 'Scan your food',
      'take_photo': 'Take Photo',
      'gallery': 'Gallery',
      'analyzing': 'Analyzing...',
      'scan_another': 'Scan Another',

      // Messages
      'meal_added': 'Meal added successfully',
      'meal_deleted': 'Meal deleted',
      'error': 'Error',
      'success': 'Success',
      'search_food': 'Search for food...',
      'no_results': 'No results found',
      'add': 'Add',
      'meal_added_success': 'Added successfully ✓',
      'view_meals': 'View Meals',

      // Food Categories
      'fruits': 'Fruits',
      'salads': 'Salads',
      'protein': 'Protein',
      'dairy': 'Dairy',
      'grains': 'Grains',
      'vegetables': 'Vegetables',
      'light_meals': 'Light Meals',
      'beverages': 'Beverages',
      'nuts_sweets': 'Nuts & Sweets',

      // Common Foods (Top items that appear frequently)
      'tomato': 'Tomato',
      'cucumber': 'Cucumber',
      'red_pepper': 'Red Pepper',
      'green_pepper': 'Green Pepper',
      'carrot': 'Carrot',
      'onion': 'Onion',
      'potato': 'Potato',
      'lettuce': 'Lettuce',
      'spinach': 'Spinach',
      'broccoli': 'Broccoli',
    },
    'ar': {
      // App
      'app_name': 'التغذية الذكية',
      'app_description':
          'تطبيق التغذية الذكية يساعدك على تتبع وجباتك وحساب السعرات الحرارية باستخدام الذكاء الاصطناعي.',

      // Navigation
      'home': 'الرئيسية',
      'scanner': 'الماسح',
      'meals': 'وجباتي',
      'settings': 'الإعدادات',

      // Home
      'welcome': 'مرحباً!',
      'subtitle': 'تتبع تغذيتك بذكاء',
      'food_categories': 'الفئات الغذائية',
      'services': 'الخدمات',
      'today_meals': 'وجبات اليوم',

      // Services
      'nutrition_calc': 'حاسبة التغذية',
      'food_scanner': 'ماسح الطعام',
      'ai_recommendations': 'توصيات الذكاء الاصطناعي',

      // Meals
      'add_meal': 'إضافة وجبة',
      'meal_type': 'نوع الوجبة',
      'select_category': 'اختر الفئة',
      'select_food': 'اختر الطعام',
      'no_meals': 'لا توجد وجبات',

      // Meal Types
      'breakfast': 'فطور',
      'lunch': 'غداء',
      'dinner': 'عشاء',
      'snack': 'وجبة خفيفة',

      // Nutrients
      'calories': 'السعرات',
      'protein': 'البروتين',
      'carbs': 'الكربوهيدرات',
      'fats': 'الدهون',

      // Settings
      'customize_app': 'خصص تطبيقك',
      'theme': 'المظهر',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'الإنجليزية',

      // About
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'privacy': 'سياسة الخصوصية',
      'terms': 'شروط الاستخدام',

      // Auth
      'logout': 'تسجيل الخروج',
      'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',

      // Actions
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'edit': 'تعديل',
      'ok': 'حسناً',

      // Scanner
      'scan_food': 'امسح طعامك',
      'take_photo': 'التقط صورة',
      'gallery': 'المعرض',
      'analyzing': 'جاري التحليل...',
      'scan_another': 'مسح آخر',

      // Messages
      'meal_added': 'تمت إضافة الوجبة بنجاح',
      'meal_deleted': 'تم حذف الوجبة',
      'error': 'خطأ',
      'success': 'نجاح',
      'search_food': 'ابحث عن طعام...',
      'no_results': 'لم يتم العثور على نتائج',
      'add': 'إضافة',
      'meal_added_success': 'تمت الإضافة بنجاح ✓',
      'view_meals': 'عرض الوجبات',

      // Food Categories
      'fruits': 'فواكه',
      'salads': 'سلطات',
      'protein': 'بروتين',
      'dairy': 'ألبان',
      'grains': 'حبوب',
      'vegetables': 'خضروات',
      'light_meals': 'وجبات خفيفة',
      'beverages': 'مشروبات',
      'nuts_sweets': 'مكسرات وحلويات',

      // Common Foods (Top items that appear frequently)
      'tomato': 'طماطم',
      'cucumber': 'خيار',
      'red_pepper': 'فلفل أحمر',
      'green_pepper': 'فلفل أخضر',
      'carrot': 'جزر',
      'onion': 'بصل',
      'potato': 'بطاطس',
      'lettuce': 'خس',
      'spinach': 'سبانخ',
      'broccoli': 'بروكلي',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}
