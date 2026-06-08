# تكبير حجم الـ Logo

## التغييرات المطبقة

### 1. صفحة تسجيل الدخول (Login Screen)
```dart
// قبل
Container(
  width: isSmallScreen ? 90 : 110,
  height: isSmallScreen ? 90 : 110,
)

// بعد
Container(
  width: isSmallScreen ? 110 : 130,
  height: isSmallScreen ? 110 : 130,
)
```
**الزيادة**: +20 بكسل

### 2. صفحة التسجيل (Register Screen)
```dart
// قبل
Container(
  width: isSmallScreen ? 80 : 90,
  height: isSmallScreen ? 80 : 90,
)

// بعد
Container(
  width: isSmallScreen ? 100 : 120,
  height: isSmallScreen ? 100 : 120,
)
```
**الزيادة**: +20-30 بكسل

### 3. شاشة البداية (Splash Screen)
```dart
// قبل
Container(
  width: 150,
  height: 150,
)

// بعد
Container(
  width: 170,
  height: 170,
)
```
**الزيادة**: +20 بكسل

## الأحجام الجديدة

| الشاشة | الشاشات الصغيرة | الشاشات الكبيرة |
|--------|-----------------|-----------------|
| Login | 110×110 | 130×130 |
| Register | 100×100 | 120×120 |
| Splash | 170×170 | 170×170 |

## النتيجة
- ✅ الـ logo أكبر وأوضح
- ✅ يحافظ على التناسق في جميع الشاشات
- ✅ مناسب لجميع أحجام الشاشات

## الملفات المعدلة
1. `lib/presentation/screens/auth/login_screen.dart`
2. `lib/presentation/screens/auth/register_screen.dart`
3. `lib/presentation/screens/splash_screen.dart`