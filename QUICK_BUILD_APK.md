# ⚡ بناء APK - الطريقة السريعة

## 🎯 الأمر الواحد

افتحي Terminal ونفذي:

```bash
flutter build apk --release
```

**انتظري 5-10 دقائق** ⏱️

---

## 📍 مكان الملف

بعد الانتهاء، الملف سيكون في:
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## 🚀 أسرع طريقة (APK مقسم)

```bash
flutter build apk --split-per-abi --release
```

سينتج 3 ملفات أصغر حجماً:
- `app-arm64-v8a-release.apk` ← **استخدمي هذا** (للأجهزة الحديثة)
- `app-armeabi-v7a-release.apk` (للأجهزة القديمة)
- `app-x86_64-release.apk` (للمحاكيات)

---

## ✅ التحقق من النجاح

بعد انتهاء البناء، ستري:
```
✓ Built build\app\outputs\flutter-apk\app-release.apk (XX.XMB)
```

---

## 📱 التثبيت على الهاتف

### الطريقة 1: مباشرة
```bash
flutter install --release
```

### الطريقة 2: يدوياً
1. انسخي الملف من المجلد
2. انقليه للهاتف
3. افتحيه واضغطي "تثبيت"

---

## 🆘 إذا حدث خطأ

```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

**الوقت المتوقع:** 5-10 دقائق
**الحجم المتوقع:** 40-60 MB
