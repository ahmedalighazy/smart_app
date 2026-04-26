# توثيق الميزات الجديدة - Smart Nutrition App

## 📅 التاريخ: 24 أبريل 2026

---

## ✅ الميزة الأولى: كتم الإشعارات (Notifications Mute)

### 📝 الوصف
تم إضافة خيار لكتم الإشعارات داخل التطبيق بدون الحاجة لإعدادات الهاتف. يمكن للمستخدم تفعيل أو إيقاف الإشعارات بضغطة زر واحدة.

### 🎯 الميزات
- **تبديل سريع**: زر تبديل (Switch) في شاشة الإعدادات
- **حفظ الحالة**: يتم حفظ حالة الكتم في SharedPreferences
- **تطبيق فوري**: يتم تطبيق الإعدادات فوراً على جميع الإشعارات
- **حفظ السجل**: حتى عند الكتم، يتم حفظ الإشعارات في السجل للمراجعة لاحقاً

### 📂 الملفات المُعدلة

#### 1. `lib/logic/cubits/settings_cubit.dart`
```dart
class SettingsState {
  final bool notificationsMuted; // ✅ إضافة حقل جديد
  
  Future<void> toggleNotifications() async {
    // ✅ دالة جديدة للتبديل
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.notificationsMuted;
    await prefs.setBool('notificationsMuted', newValue);
    emit(state.copyWith(notificationsMuted: newValue));
  }
}
```

#### 2. `lib/data/services/notification_service.dart`
```dart
Future<void> showMealNotification(...) async {
  // ✅ التحقق من حالة الكتم
  final prefs = await SharedPreferences.getInstance();
  final isMuted = prefs.getBool('notificationsMuted') ?? false;
  
  if (isMuted) {
    // حفظ في السجل فقط بدون عرض الإشعار
    await NotificationHistoryService.addNotification(...);
    return;
  }
  
  // عرض الإشعار بشكل طبيعي
  await _notificationsPlugin.show(...);
}
```

#### 3. `lib/presentation/screens/settings_screen.dart`
```dart
Widget _buildNotificationsSection(...) {
  // ✅ قسم جديد في الإعدادات
  return Container(
    child: Row(
      children: [
        Icon(state.notificationsMuted 
          ? Icons.notifications_off_rounded 
          : Icons.notifications_active_rounded),
        Text(state.notificationsMuted 
          ? 'الإشعارات مكتومة' 
          : 'الإشعارات مفعلة'),
        Switch(
          value: !state.notificationsMuted,
          onChanged: (value) {
            context.read<SettingsCubit>().toggleNotifications();
          },
        ),
      ],
    ),
  );
}
```

### 🎨 واجهة المستخدم
- **أيقونة ديناميكية**: 🔔 عند التفعيل، 🔕 عند الكتم
- **نص توضيحي**: يوضح الحالة الحالية
- **زر تبديل**: سهل الاستخدام ومرئي
- **ألوان مميزة**: أخضر للتفعيل، رمادي للكتم

### 📊 سلوك التطبيق

| الحالة | الإشعارات | السجل | الملاحظات |
|--------|-----------|-------|-----------|
| **مفعّل** | ✅ تظهر | ✅ يُحفظ | السلوك الافتراضي |
| **مكتوم** | ❌ لا تظهر | ✅ يُحفظ | يمكن المراجعة لاحقاً |

### 🧪 كيفية الاختبار
1. افتح شاشة الإعدادات
2. ابحث عن قسم "الإشعارات" 🔔
3. اضغط على زر التبديل لتفعيل/إيقاف الإشعارات
4. أضف وجبة جديدة أو انتظر نصيحة
5. تحقق من عدم ظهور الإشعار (عند الكتم)
6. افتح شاشة الإشعارات للتأكد من حفظ السجل

---

## ✅ الميزة الثانية: الوجبات المركبة (Composite Meals)

### 📝 الوصف
إمكانية تكوين وجبة من عدة عناصر غذائية مع أزرار للإضافة والتعديل والحذف. يمكن للمستخدم إنشاء وجبات مخصصة وحفظها لإعادة استخدامها.

### 🎯 الميزات
- **تكوين وجبة**: إضافة عدة عناصر غذائية في وجبة واحدة
- **حساب تلقائي**: حساب إجمالي القيم الغذائية تلقائياً
- **التحكم بالكمية**: تعديل كمية كل عنصر (1x, 1.5x, 2x, إلخ)
- **الحفظ والتعديل**: حفظ الوجبات المركبة وتعديلها لاحقاً
- **الحذف**: حذف الوجبات المركبة مع تأكيد
- **التصنيف**: تصنيف الوجبات (فطور، غداء، عشاء، خفيفة)
- **البحث والفلترة**: البحث في الوجبات المركبة والفلترة حسب النوع

### 📂 الملفات الجديدة

#### 1. `lib/data/models/composite_meal_model.dart`
```dart
@HiveType(typeId: 3)
class CompositeMealModel extends HiveObject {
  final String id;
  final String name;
  final List<CompositeMealItem> items;
  final String mealType;
  final DateTime createdAt;
  final String? notes;
  
  // حساب إجمالي القيم الغذائية
  Map<String, double> get totalNutrition { ... }
}

@HiveType(typeId: 4)
class CompositeMealItem {
  final String foodName;
  final String calories;
  final String protein;
  final String carbs;
  final String fat;
  final double quantity; // الكمية
  
  // نسخة معدلة مع كمية مختلفة
  CompositeMealItem copyWith({double? quantity}) { ... }
}
```

#### 2. `lib/data/services/composite_meal_service.dart`
```dart
class CompositeMealService {
  // إضافة وجبة مركبة
  static Future<void> addCompositeMeal(CompositeMealModel meal);
  
  // تحديث وجبة مركبة
  static Future<void> updateCompositeMeal(CompositeMealModel meal);
  
  // حذف وجبة مركبة
  static Future<void> deleteCompositeMeal(String id);
  
  // الحصول على جميع الوجبات
  static List<CompositeMealModel> getAllCompositeMeals();
  
  // الحصول حسب النوع
  static List<CompositeMealModel> getCompositeMealsByType(String type);
  
  // البحث
  static List<CompositeMealModel> searchCompositeMeals(String query);
}
```

#### 3. `lib/presentation/screens/composite_meals_screen.dart`
شاشة عرض الوجبات المركبة مع:
- **قائمة الوجبات**: عرض جميع الوجبات المركبة
- **فلاتر**: تصفية حسب نوع الوجبة
- **أزرار الإجراءات**: تعديل وحذف لكل وجبة
- **زر الإضافة**: FAB لإنشاء وجبة جديدة

#### 4. `lib/presentation/screens/composite_meal_builder_screen.dart` (سيتم إنشاؤه)
شاشة بناء الوجبة المركبة مع:
- **اختيار الاسم**: إدخال اسم الوجبة
- **اختيار النوع**: فطور، غداء، عشاء، خفيفة
- **إضافة عناصر**: اختيار عناصر غذائية من الفئات
- **تعديل الكمية**: تغيير كمية كل عنصر
- **حذف عناصر**: إزالة عناصر من الوجبة
- **معاينة القيم**: عرض إجمالي القيم الغذائية
- **حفظ**: حفظ الوجبة المركبة

### 🎨 واجهة المستخدم

#### شاشة الوجبات المركبة
```
┌─────────────────────────────────┐
│  🍽️ الوجبات المركبة            │
│  كوّن وجباتك الخاصة             │
└─────────────────────────────────┘

[الكل] [فطور] [غداء] [عشاء] [خفيفة]

┌─────────────────────────────────┐
│ وجبة الإفطار الصحية      ✏️ 🗑️ │
│ 4 عناصر                         │
├─────────────────────────────────┤
│ 🥚 بيض مسلوق                    │
│ 🍞 خبز أسمر                     │
│ 🥛 حليب قليل الدسم              │
│ 🍌 موز                          │
├─────────────────────────────────┤
│ 🔥 450  💪 25g  🌾 55g  💧 12g  │
└─────────────────────────────────┘

         [➕ تكوين وجبة]
```

#### شاشة بناء الوجبة
```
┌─────────────────────────────────┐
│  ✨ تكوين وجبة جديدة            │
└─────────────────────────────────┘

📝 اسم الوجبة: [____________]

🕐 نوع الوجبة:
[🌅 فطور] [☀️ غداء] [🌙 عشاء] [🍪 خفيفة]

🍽️ العناصر المضافة:
┌─────────────────────────────────┐
│ 🥚 بيض مسلوق        x1.0  ❌   │
│ 🍞 خبز أسمر         x2.0  ❌   │
│ 🥛 حليب             x1.0  ❌   │
└─────────────────────────────────┘

[➕ إضافة عنصر]

📊 إجمالي القيم الغذائية:
🔥 450  💪 25g  🌾 55g  💧 12g

         [💾 حفظ الوجبة]
```

### 🔄 سير العمل (Workflow)

#### إنشاء وجبة مركبة جديدة:
1. اضغط على زر "تكوين وجبة" ➕
2. أدخل اسم الوجبة
3. اختر نوع الوجبة (فطور، غداء، إلخ)
4. اضغط "إضافة عنصر"
5. اختر الفئة ثم العنصر الغذائي
6. عدّل الكمية إذا لزم الأمر
7. كرر الخطوات 4-6 لإضافة المزيد
8. راجع إجمالي القيم الغذائية
9. اضغط "حفظ الوجبة" 💾

#### تعديل وجبة مركبة:
1. اضغط على زر التعديل ✏️ في بطاقة الوجبة
2. عدّل الاسم أو النوع
3. أضف أو احذف عناصر
4. عدّل الكميات
5. اضغط "حفظ التعديلات"

#### حذف وجبة مركبة:
1. اضغط على زر الحذف 🗑️ في بطاقة الوجبة
2. أكّد الحذف في نافذة التأكيد
3. سيتم حذف الوجبة نهائياً

### 📊 هيكل البيانات

```
CompositeMealModel
├── id: String (معرف فريد)
├── name: String (اسم الوجبة)
├── items: List<CompositeMealItem> (العناصر)
│   ├── CompositeMealItem
│   │   ├── foodName: String
│   │   ├── calories: String
│   │   ├── protein: String
│   │   ├── carbs: String
│   │   ├── fat: String
│   │   ├── quantity: double (الكمية)
│   │   └── category info
│   └── ...
├── mealType: String (breakfast/lunch/dinner/snack)
├── createdAt: DateTime
└── notes: String? (ملاحظات اختيارية)
```

### 🧪 كيفية الاختبار

#### اختبار الإنشاء:
1. افتح شاشة الوجبات المركبة
2. اضغط "تكوين وجبة"
3. أدخل "وجبة الإفطار الصحية"
4. اختر "فطور"
5. أضف: بيض (x2), خبز (x1), حليب (x1)
6. تحقق من حساب القيم الغذائية
7. احفظ الوجبة
8. تحقق من ظهورها في القائمة

#### اختبار التعديل:
1. اضغط ✏️ على وجبة موجودة
2. غيّر الاسم إلى "إفطار محسّن"
3. أضف عنصر جديد (موز)
4. غيّر كمية البيض إلى x3
5. احفظ التعديلات
6. تحقق من التحديثات

#### اختبار الحذف:
1. اضغط 🗑️ على وجبة
2. أكّد الحذف
3. تحقق من اختفاء الوجبة
4. تحقق من ظهور رسالة النجاح

#### اختبار الفلترة:
1. أنشئ وجبات من أنواع مختلفة
2. اضغط على فلتر "فطور"
3. تحقق من ظهور وجبات الفطور فقط
4. جرّب الفلاتر الأخرى

### 💾 التخزين
- **Hive Database**: يتم حفظ الوجبات المركبة في Hive
- **TypeId 3**: CompositeMealModel
- **TypeId 4**: CompositeMealItem
- **Box Name**: 'composite_meals'

### 🔗 التكامل مع الميزات الأخرى
- **إضافة للوجبات اليومية**: يمكن إضافة الوجبة المركبة كاملة للوجبات اليومية
- **الإشعارات**: إشعار عند إضافة وجبة مركبة
- **التقارير**: تضمين الوجبات المركبة في التقارير
- **الإحصائيات**: حساب القيم الغذائية في الإحصائيات

---

## 📝 ملاحظات التطوير

### المتطلبات:
- ✅ Flutter SDK
- ✅ Hive & Hive Flutter
- ✅ SharedPreferences
- ✅ BLoC/Cubit

### الخطوات التالية:
1. ⏳ إنشاء `composite_meal_builder_screen.dart`
2. ⏳ إنشاء ملفات Hive Adapter (`.g.dart`)
3. ⏳ تسجيل Adapters في `main.dart`
4. ⏳ إضافة رابط للوجبات المركبة في الشاشة الرئيسية
5. ⏳ إضافة إمكانية إضافة الوجبة المركبة للوجبات اليومية
6. ⏳ اختبار شامل للميزات

### الأوامر المطلوبة:
```bash
# توليد Hive Adapters
flutter packages pub run build_runner build

# أو في حالة وجود ملفات قديمة
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ الخلاصة

تم تنفيذ ميزتين رئيسيتين:

### 1. كتم الإشعارات ✅
- ✅ إضافة خيار في الإعدادات
- ✅ حفظ الحالة في SharedPreferences
- ✅ تطبيق على جميع أنواع الإشعارات
- ✅ حفظ السجل حتى عند الكتم
- ✅ واجهة مستخدم واضحة

### 2. الوجبات المركبة 🚧 (جاري العمل)
- ✅ نموذج البيانات (CompositeMealModel)
- ✅ خدمة الإدارة (CompositeMealService)
- ✅ شاشة العرض (CompositeMealsScreen)
- ⏳ شاشة البناء (CompositeMealBuilderScreen)
- ⏳ تسجيل Hive Adapters
- ⏳ التكامل مع الميزات الأخرى

---

## 📞 الدعم والمساعدة

للأسئلة أو المشاكل، يرجى مراجعة:
- 📖 التوثيق الكامل في `docs/`
- 🐛 تقارير الأخطاء في Issues
- 💬 المناقشات في Discussions

---

**تاريخ التحديث**: 24 أبريل 2026  
**الإصدار**: 2.0.0  
**الحالة**: قيد التطوير 🚧
