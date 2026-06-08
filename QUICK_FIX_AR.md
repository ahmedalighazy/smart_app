# ⚡ حل سريع - 5 دقائق فقط!

## ❌ المشكلة
```
API Key not found. Please pass a valid API key.
```

---

## ✅ الحل (3 خطوات)

### 1️⃣ احصل على مفتاح جديد
افتح هذا الرابط:
```
https://aistudio.google.com/app/apikey
```

- سجل دخول بحساب Gmail
- اضغط **"Create API Key"**
- انسخ المفتاح (يبدأ بـ `AIzaSy...`)

---

### 2️⃣ ضع المفتاح في الكود

افتح الملف:
```
lib/data/services/food_vision_service.dart
```

ابحث عن السطر 11:
```dart
final String apiKey = 'YOUR_NEW_API_KEY_HERE';
```

استبدله بالمفتاح الجديد:
```dart
final String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

احفظ الملف (Ctrl+S)

---

### 3️⃣ أعد تشغيل التطبيق

```bash
flutter run
```

**جرب تحليل صورة طعام - يجب أن يعمل الآن!** ✅

---

## 🎉 انتهى!

**هذا كل شيء!** لا يوجد بديل أفضل من Gemini - مجاني وقوي ويدعم العربية.

---

## 📞 إذا واجهت مشاكل

اقرأ الملفات التفصيلية:
- `GET_NEW_API_KEY.md` - شرح مفصل
- `ALTERNATIVE_SOLUTIONS.md` - بدائل أخرى (إذا أردت)

---

**ملاحظة:** المفتاح مجاني 100% ولا يحتاج بطاقة ائتمان! 🎁
