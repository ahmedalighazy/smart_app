# إصلاح محاذاة النصوص في الصفحة الرئيسية

## المشكلة
- النصوص العربية في الصفحة الرئيسية تظهر على الشمال بدلاً من اليمين
- العناوين مثل "الخدمات" و "الفئات الغذائية" غير محاذاة بشكل صحيح

## السبب
استخدام `CrossAxisAlignment.end` بدلاً من `CrossAxisAlignment.start`

### الفرق بين end و start:
- **`CrossAxisAlignment.end`**: 
  - في LTR (إنجليزي): يحاذي لليمين
  - في RTL (عربي): يحاذي لليسار ❌
  
- **`CrossAxisAlignment.start`**: 
  - في LTR (إنجليزي): يحاذي لليسار
  - في RTL (عربي): يحاذي لليمين ✅

## الحل المطبق

### تغيير CrossAxisAlignment
```dart
// قبل
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    Text('الخدمات'),
    // ...
  ],
)

// بعد
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('الخدمات'),
    // ...
  ],
)
```

## المواضع المصلحة

### 1. قسم الخدمات
```dart
// في _buildSimpleFeatureCard section
Padding(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // ✅ تم التغيير
    children: [
      Text('الخدمات'),
      // ...
    ],
  ),
)
```

### 2. قسم الهيدر
```dart
// في Header section
FadeTransition(
  opacity: _headerFadeAnimation,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, // ✅ تم التغيير
    children: [
      Text('Smart Nutrition'),
      // ...
    ],
  ),
)
```

## كيف يعمل الآن

### في العربية (RTL):
- `CrossAxisAlignment.start` = يمين ✅
- النصوص تظهر على اليمين
- المحاذاة صحيحة

### في الإنجليزية (LTR):
- `CrossAxisAlignment.start` = شمال ✅
- النصوص تظهر على الشمال
- المحاذاة صحيحة

## النتيجة
- ✅ النصوص العربية تظهر على اليمين
- ✅ النصوص الإنجليزية تظهر على الشمال
- ✅ المحاذاة تتكيف تلقائياً مع اللغة
- ✅ لا حاجة لكود إضافي

## الملفات المعدلة
- `lib/presentation/screens/home_screen/home_screen.dart`

## اختبار الإصلاح
1. شغل التطبيق
2. تحقق من الصفحة الرئيسية في العربية
3. غير اللغة للإنجليزية من الإعدادات
4. تحقق من أن المحاذاة صحيحة في كلا اللغتين

## ملاحظة مهمة
استخدم دائماً `start` و `end` بدلاً من `left` و `right` للمحاذاة التي تحتاج للتكيف مع اتجاه اللغة:
- ✅ `CrossAxisAlignment.start` - يتكيف مع الاتجاه
- ✅ `CrossAxisAlignment.end` - يتكيف مع الاتجاه
- ❌ `CrossAxisAlignment.left` - ثابت على الشمال
- ❌ `CrossAxisAlignment.right` - ثابت على اليمين