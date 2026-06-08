# 🔑 كيفية الحصول على مفتاح Gemini API جديد

## ❌ المشكلة الحالية

```
[FoodVisionService] ❌ Error 400: API Key not found. Please pass a valid API key.
```

**السبب:** المفتاح الموجود في الكود غير صالح أو منتهي الصلاحية.

---

## ✅ الحل (5 دقائق فقط!)

### الخطوة 1️⃣: احصل على مفتاح جديد

1. **افتح هذا الرابط في المتصفح:**
   ```
   https://aistudio.google.com/app/apikey
   ```
   
   أو هذا الرابط البديل:
   ```
   https://makersuite.google.com/app/apikey
   ```

2. **سجل دخول بحساب Google:**
   - استخدم أي حساب Gmail لديك
   - إذا لم يكن لديك حساب، أنشئ واحد مجاناً

3. **اضغط على زر "Create API Key"** أو **"Get API Key"**

4. **اختر أحد الخيارات:**
   - **"Create API key in new project"** ← (موصى به للمبتدئين)
   - أو اختر مشروع موجود إذا كان لديك

5. **انسخ المفتاح:**
   - سيظهر لك مفتاح جديد بهذا الشكل:
   ```
   AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
   ```
   - **انسخه بالكامل** (اضغط على أيقونة النسخ)

---

### الخطوة 2️⃣: ضع المفتاح في الكود

1. **افتح الملف:**
   ```
   lib/data/services/food_vision_service.dart
   ```

2. **ابحث عن السطر 11:**
   ```dart
   final String apiKey = 'YOUR_NEW_API_KEY_HERE';
   ```

3. **استبدل `YOUR_NEW_API_KEY_HERE` بالمفتاح الذي نسخته:**
   ```dart
   final String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
   ```

4. **احفظ الملف** (Ctrl+S أو Cmd+S)

---

### الخطوة 3️⃣: أعد تشغيل التطبيق

1. **أوقف التطبيق الحالي:**
   - اضغط على زر Stop في VS Code
   - أو اضغط `Ctrl+C` في Terminal

2. **شغل التطبيق من جديد:**
   ```bash
   flutter run
   ```

3. **جرب تحليل صورة طعام:**
   - التقط صورة أو اختر من المعرض
   - يجب أن يعمل الآن! ✅

---

## 🎯 مثال كامل

### قبل:
```dart
final String apiKey = 'YOUR_NEW_API_KEY_HERE'; // ❌ غير صالح
```

### بعد:
```dart
final String apiKey = 'AIzaSyBkBHyNhhqKFPn9_9LL5pmXEescjUS6at0'; // ✅ صالح
```

---

## 📝 ملاحظات مهمة

### 1. المفتاح مجاني 100%
- ✅ 60 طلب في الدقيقة
- ✅ 1,500 طلب في اليوم
- ✅ لا يحتاج بطاقة ائتمان

### 2. المفتاح يدعم:
- ✅ تحليل النصوص (Gemini Text)
- ✅ تحليل الصور (Gemini Vision)
- ✅ جميع موديلات Gemini

### 3. لا تشارك المفتاح:
- ⚠️ المفتاح خاص بك فقط
- ⚠️ لا تنشره على GitHub أو مواقع عامة
- ⚠️ أي شخص يحصل عليه يمكنه استخدام حصتك

---

## 🔍 التحقق من المفتاح

### اختبار سريع:

يمكنك اختبار المفتاح قبل وضعه في الكود:

1. **افتح Terminal**

2. **نفذ هذا الأمر** (استبدل `YOUR_API_KEY` بمفتاحك):

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"مرحبا"}]}]}'
```

3. **إذا كان المفتاح صحيح:**
   - ستحصل على رد يحتوي على `"candidates"`
   - ✅ المفتاح يعمل!

4. **إذا كان المفتاح خاطئ:**
   - ستحصل على خطأ `"API key not valid"`
   - ❌ جرب مفتاح آخر

---

## 🆘 إذا واجهت مشاكل

### المشكلة: "API key not valid"
**الحل:**
1. تأكد من نسخ المفتاح بالكامل (بدون مسافات)
2. تأكد من عدم وجود علامات اقتباس إضافية
3. جرب إنشاء مفتاح جديد

### المشكلة: "Quota exceeded"
**الحل:**
1. انتظر دقيقة واحدة
2. تجاوزت حد 60 طلب/دقيقة
3. جرب مرة أخرى

### المشكلة: "Service unavailable (503)"
**الحل:**
1. خوادم Google مشغولة مؤقتاً
2. انتظر دقيقة وحاول مرة أخرى
3. هذا خطأ مؤقت وسيتم حله تلقائياً

---

## 🎓 فيديو توضيحي

إذا كنت تفضل مشاهدة فيديو، ابحث على YouTube عن:
```
"How to get Gemini API key"
```

أو:
```
"كيفية الحصول على مفتاح Gemini API"
```

---

## 🔗 روابط مفيدة

| الرابط | الوصف |
|--------|-------|
| [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) | إنشاء مفتاح API |
| [ai.google.dev/docs](https://ai.google.dev/docs) | التوثيق الرسمي |
| [console.cloud.google.com](https://console.cloud.google.com) | إدارة المشاريع |

---

## ✅ الخلاصة

1. **اذهب إلى:** https://aistudio.google.com/app/apikey
2. **اضغط:** "Create API Key"
3. **انسخ المفتاح**
4. **ضعه في:** `lib/data/services/food_vision_service.dart` (السطر 11)
5. **احفظ وأعد التشغيل**
6. **جرب تحليل صورة** ✅

---

## 🎉 بعد الحل

بعد وضع المفتاح الجديد، ستتمكن من:
- ✅ تحليل صور الطعام
- ✅ الحصول على القيم الغذائية
- ✅ الحصول على توصيات غذائية مخصصة
- ✅ استخدام جميع ميزات الذكاء الاصطناعي في التطبيق

---

**تاريخ الإنشاء:** 3 مايو 2026
**آخر تحديث:** 3 مايو 2026

**ملاحظة:** هذا الحل مضمون 100% ومجرب ✅
