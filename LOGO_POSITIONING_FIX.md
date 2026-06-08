# إصلاح موضع الـ Logo في الدوائر

## المشكلة
كانت صورة الـ logo تظهر مقطوعة أو غير مضبوطة في الدوائر البيضاء في صفحات:
- تسجيل الدخول (Login Screen)
- التسجيل (Register Screen) 
- شاشة البداية (Splash Screen)

## السبب
استخدام `BoxFit.cover` يجعل الصورة تملأ الدائرة بالكامل مما قد يقطع أجزاء من الصورة.

## الحل المطبق

### 1. تغيير BoxFit
- **من**: `BoxFit.cover`
- **إلى**: `BoxFit.contain`

### 2. إضافة Padding
- إضافة `Container` مع `padding: EdgeInsets.all()` حول الصورة
- هذا يعطي مساحة داخل الدائرة لتظهر الصورة كاملة

### 3. الملفات المعدلة

#### أ. Login Screen
```dart
// قبل
child: ClipOval(
  child: Image.asset(
    'assets/images/logo_app.jpeg',
    fit: BoxFit.cover,
  ),
),

// بعد
child: ClipOval(
  child: Container(
    padding: const EdgeInsets.all(8),
    child: Image.asset(
      'assets/images/logo_app.jpeg',
      fit: BoxFit.contain,
    ),
  ),
),
```

#### ب. Register Screen
```dart
// نفس التغيير مع padding: EdgeInsets.all(8)
```

#### ج. Splash Screen
```dart
// نفس التغيير مع padding: EdgeInsets.all(12) (أكبر قليلاً)
```

## النتيجة
- ✅ الصورة تظهر كاملة داخل الدائرة
- ✅ لا يوجد قطع في أجزاء الصورة
- ✅ الصورة في وسط الدائرة بشكل مضبوط
- ✅ يحافظ على نسب الصورة الأصلية

## الملفات المعدلة
1. `lib/presentation/screens/auth/login_screen.dart`
2. `lib/presentation/screens/auth/register_screen.dart`
3. `lib/presentation/screens/splash_screen.dart`

## اختبار التغييرات
1. شغل التطبيق
2. تحقق من صفحة تسجيل الدخول
3. تحقق من صفحة التسجيل
4. تحقق من شاشة البداية
5. تأكد أن الـ logo يظهر كاملاً ومضبوطاً في وسط كل دائرة