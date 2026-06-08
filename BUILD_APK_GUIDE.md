# 📦 دليل بناء APK Release

## 🚀 الخطوات الكاملة

### الخطوة 1️⃣: تنظيف المشروع
```bash
flutter clean
```

### الخطوة 2️⃣: تحديث الحزم
```bash
flutter pub get
```

### الخطوة 3️⃣: بناء APK Release
```bash
flutter build apk --release
```

**ملاحظة:** هذه الخطوة تأخذ **5-10 دقائق** حسب سرعة الجهاز!

---

## 📍 مكان الملف

بعد اكتمال البناء، ستجدين الملف في:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📊 حجم الملف المتوقع

- **الحجم:** حوالي 40-60 MB
- **الإصدار:** 1.0.0+1

---

## 🎯 بدائل أسرع

### البديل 1: بناء APK مقسم (أصغر حجماً)
```bash
flutter build apk --split-per-abi
```

سينتج 3 ملفات:
- `app-armeabi-v7a-release.apk` (للأجهزة القديمة)
- `app-arm64-v8a-release.apk` (للأجهزة الحديثة) ← **استخدمي هذا**
- `app-x86_64-release.apk` (للمحاكيات)

**الفائدة:** كل ملف أصغر حجماً (~20-30 MB)

---

### البديل 2: بناء App Bundle (للنشر على Google Play)
```bash
flutter build appbundle --release
```

الملف سيكون في:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## ⚙️ إعدادات إضافية (اختيارية)

### تصغير الكود (Obfuscation)
لحماية الكود من الهندسة العكسية:
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### تحسين الحجم
```bash
flutter build apk --release --shrink
```

---

## 🔍 التحقق من البناء

### 1. تحقق من وجود الملف:
```bash
ls build/app/outputs/flutter-apk/
```

### 2. تحقق من حجم الملف:
```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 تثبيت APK على الهاتف

### الطريقة 1: عبر USB
```bash
flutter install --release
```

### الطريقة 2: نقل الملف يدوياً
1. انسخي الملف `app-release.apk`
2. انقليه إلى الهاتف
3. افتحي الملف من الهاتف
4. اضغطي "تثبيت"

---

## 🆘 حل المشاكل الشائعة

### المشكلة: البناء يأخذ وقت طويل
**الحل:**
- انتظري 5-10 دقائق
- تأكدي من اتصال الإنترنت (لتحميل المكتبات)
- أغلقي البرامج الأخرى لتسريع البناء

### المشكلة: خطأ في البناء
**الحل:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### المشكلة: الملف كبير جداً
**الحل:**
استخدمي:
```bash
flutter build apk --split-per-abi --release
```

---

## 📋 قائمة التحقق قبل البناء

- [x] تم تحديث API Key
- [x] تم إخفاء الأيقونات
- [x] تم إضافة صفحة المصادر والمراجع
- [x] تم اختبار التطبيق
- [ ] تم بناء APK Release
- [ ] تم اختبار APK على الهاتف

---

## 🎉 بعد البناء

### 1. اختبري APK:
- ثبتيه على الهاتف
- جربي جميع الميزات
- تأكدي من عمل تحليل الصور

### 2. شاركي APK:
- يمكنك مشاركة الملف مباشرة
- أو رفعه على Google Drive
- أو نشره على Google Play Store

---

## 📝 معلومات التطبيق

**الاسم:** Smart Nutrition
**الإصدار:** 1.0.0
**رقم البناء:** 1
**الحجم المتوقع:** 40-60 MB
**الحد الأدنى لـ Android:** API 21 (Android 5.0)

---

## 🔐 للنشر على Google Play

### 1. أنشئي Keystore:
```bash
keytool -genkey -v -keystore smart-nutrition-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias smart-nutrition
```

### 2. أضيفي في `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=smart-nutrition
storeFile=<path-to-keystore>
```

### 3. ابني App Bundle:
```bash
flutter build appbundle --release
```

---

**تاريخ الإنشاء:** 3 مايو 2026
**الحالة:** ✅ جاهز للبناء
