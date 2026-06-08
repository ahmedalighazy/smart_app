# إصلاح مشكلة الاتجاهات في العربية والإنجليزية

## المشكلة
- الاتجاهات لا تتغير بشكل صحيح عند التبديل بين العربية والإنجليزية
- بعض العناصر تبقى RTL حتى في الإنجليزية
- النصوص والعناصر لا تتجه بالاتجاه الصحيح

## الأسباب
1. **Hardcoded TextDirection**: استخدام `textDirection: TextDirection.rtl` بشكل ثابت
2. **عدم إعادة البناء**: بعض الـ widgets لا تعيد البناء عند تغيير اللغة
3. **تجاهل Parent Direction**: بعض الـ widgets تتجاهل الـ `Directionality` من الـ parent

## الحلول المطبقة

### 1. إضافة Key للـ MaterialApp
```dart
// في main.dart
final appKey = ValueKey('app_${state.locale.languageCode}');

return MaterialApp(
  key: appKey, // إجبار إعادة البناء الكامل
  // ...
);
```

### 2. تحسين الـ Directionality
```dart
// في main.dart
builder: (context, child) {
  final isArabic = state.locale.languageCode == 'ar';
  debugPrint('🌐 Language changed to: ${state.locale.languageCode}');
  debugPrint('📱 Text direction: ${isArabic ? 'RTL' : 'LTR'}');
  
  return Directionality(
    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    child: child!,
  );
},
```

### 3. إضافة Logging للمتابعة
```dart
// في SettingsCubit
Future<void> setLocale(Locale locale) async {
  debugPrint('🌐 Setting locale to: ${locale.languageCode}');
  emit(state.copyWith(locale: locale));
}

Future<void> toggleLanguage() async {
  debugPrint('🔄 Toggling language from ${state.locale.languageCode} to ${newLocale.languageCode}');
  await setLocale(newLocale);
}
```

### 4. إنشاء Helper Classes (للاستخدام المستقبلي)

#### أ. DirectionHelper
```dart
// lib/core/utils/direction_helper.dart
class DirectionHelper {
  static TextDirection getTextDirection(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    return settingsState.locale.languageCode == 'ar' 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }
}

// Extension للسهولة
extension DirectionExtension on BuildContext {
  TextDirection get textDirection => DirectionHelper.getTextDirection(this);
  bool get isArabic => DirectionHelper.isArabic(this);
  TextAlign get textAlign => DirectionHelper.getTextAlign(this);
}
```

#### ب. Adaptive Widgets
```dart
// lib/core/widgets/adaptive_row.dart
class AdaptiveRow extends StatelessWidget {
  // Row يتكيف تلقائياً مع اتجاه اللغة
}

class AdaptiveText extends StatelessWidget {
  // Text يتكيف تلقائياً مع اتجاه اللغة
}

class AdaptiveTextField extends StatelessWidget {
  // TextField يتكيف تلقائياً مع اتجاه اللغة
}
```

## كيفية الاستخدام

### للمطورين (الاستخدام المستقبلي):
```dart
// بدلاً من
Row(
  textDirection: TextDirection.rtl,
  children: [...],
)

// استخدم
AdaptiveRow(
  children: [...],
)

// أو
Row(
  textDirection: context.textDirection,
  children: [...],
)
```

### للنصوص:
```dart
// بدلاً من
Text(
  'النص',
  textDirection: TextDirection.rtl,
)

// استخدم
AdaptiveText('النص')

// أو
Text(
  'النص',
  textDirection: context.textDirection,
)
```

## النتائج المتوقعة
- ✅ تغيير فوري للاتجاه عند تبديل اللغة
- ✅ جميع العناصر تتجه بالاتجاه الصحيح
- ✅ النصوص تظهر بالاتجاه المناسب للغة
- ✅ الـ UI يعيد البناء بالكامل عند تغيير اللغة

## الملفات المعدلة
1. `lib/main.dart` - إضافة key وتحسين الـ builder
2. `lib/logic/cubits/settings_cubit.dart` - إضافة logging
3. `lib/core/utils/direction_helper.dart` - helper جديد
4. `lib/core/widgets/adaptive_row.dart` - widgets متكيفة جديدة

## اختبار الإصلاح
1. شغل التطبيق
2. اذهب للإعدادات
3. غير اللغة من العربية للإنجليزية
4. تحقق من أن جميع العناصر تتجه بالاتجاه الصحيح
5. راقب الـ console للـ logs

## ملاحظات
- الحل الحالي يستخدم key لإجبار إعادة البناء الكامل
- للاستخدام المستقبلي، يُنصح باستخدام الـ helper classes
- يمكن تدريجياً استبدال الـ hardcoded directions بالـ adaptive widgets