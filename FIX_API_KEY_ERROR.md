# حل مشكلة: مفتاح API غير صحيح أو غير مفعّل

## 🔴 المشكلة

```
Exception: مفتاح API غير صحيح أو غير مفعّل
```

**الظهور:** عند محاولة تحليل صورة الطعام

**السبب:** الـ API Key الحالي غير مفعّل أو منتهي الصلاحية

---

## ✅ الحلول (اختر واحد)

### الحل 1️⃣: تفعيل Gemini API (موصى به) ⭐

#### الخطوات:

1. **افتح Google Cloud Console:**
   ```
   https://console.cloud.google.com/
   ```

2. **سجل دخول بحساب Google المرتبط بالمفتاح**

3. **اذهب إلى APIs & Services:**
   - من القائمة الجانبية → "APIs & Services" → "Library"

4. **ابحث عن Generative Language API:**
   ```
   Generative Language API
   ```
   أو اذهب مباشرة:
   ```
   https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com
   ```

5. **اضغط "Enable" أو "تفعيل"**

6. **انتظر دقيقة واحدة** حتى يتم التفعيل

7. **جرب التطبيق مرة أخرى** ✅

---

### الحل 2️⃣: إنشاء API Key جديد

#### الخطوات:

1. **اذهب إلى Google AI Studio:**
   ```
   https://makersuite.google.com/app/apikey
   ```
   أو
   ```
   https://aistudio.google.com/app/apikey
   ```

2. **سجل دخول بحساب Google**

3. **اضغط "Create API Key"**

4. **اختر مشروع موجود أو أنشئ مشروع جديد**

5. **انسخ المفتاح الجديد** (سيكون بهذا الشكل):
   ```
   AIzaSy...
   ```

6. **استبدل المفتاح في الكود:**

   **الملف:** `lib/data/services/food_vision_service.dart`
   
   **السطر 11:**
   ```dart
   // ❌ القديم
   final String apiKey = 'AIzaSyAF5HEy30c2e7ivH7crZJc8ZJfoWkhmqvk';
   
   // ✅ الجديد
   final String apiKey = 'YOUR_NEW_API_KEY_HERE';
   ```

7. **احفظ الملف وأعد تشغيل التطبيق**

---

### الحل 3️⃣: التحقق من Quota (الحد المسموح)

إذا كان المفتاح مفعّل ولكن المشكلة مستمرة:

1. **اذهب إلى:**
   ```
   https://console.cloud.google.com/apis/api/generativelanguage.googleapis.com/quotas
   ```

2. **تحقق من:**
   - ✅ Requests per minute: 60 (مجاني)
   - ✅ Requests per day: 1,500 (مجاني)

3. **إذا تجاوزت الحد:**
   - انتظر حتى يتم إعادة تعيين الحد (يومياً)
   - أو قم بالترقية للخطة المدفوعة

---

## 🔍 التحقق من المشكلة

### اختبار المفتاح:

يمكنك اختبار المفتاح مباشرة باستخدام `curl`:

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Hello"}]
    }]
  }'
```

**إذا كان المفتاح صحيح:**
```json
{
  "candidates": [...]
}
```

**إذا كان المفتاح خاطئ:**
```json
{
  "error": {
    "code": 403,
    "message": "API key not valid..."
  }
}
```

---

## 📝 ملاحظات مهمة

### 1. الصلاحيات المطلوبة:
المفتاح يحتاج صلاحية:
```
generativelanguage.googleapis.com
```

### 2. الخدمات المطلوبة:
- ✅ Generative Language API (للنصوص)
- ✅ Gemini Vision (لتحليل الصور)

### 3. الحدود المجانية:
- 📊 60 طلب/دقيقة
- 📊 1,500 طلب/يوم
- 📊 مجاني 100%

---

## 🔒 نصيحة أمنية

### ⚠️ لا تشارك المفتاح علناً!

**المفتاح الحالي في الكود:**
```dart
final String apiKey = 'AIzaSyAF5HEy30c2e7ivH7crZJc8ZJfoWkhmqvk';
```

**هذا المفتاح مكشوف!** أي شخص يمكنه استخدامه.

### ✅ الحل الآمن:

1. **استخدم ملف `.env`:**
   ```env
   GEMINI_API_KEY=AIzaSy...
   ```

2. **أضف `.env` إلى `.gitignore`:**
   ```gitignore
   .env
   *.env
   ```

3. **استخدم `flutter_dotenv`:**
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
   ```

---

## 🆘 إذا استمرت المشكلة

### جرب هذه الخطوات:

1. **تأكد من الاتصال بالإنترنت** 📶

2. **تحقق من Firewall/VPN:**
   - بعض الشبكات تحجب Google APIs

3. **جرب مفتاح مختلف:**
   - أنشئ مفتاح جديد من حساب Google آخر

4. **تحقق من اللوج الكامل:**
   ```bash
   flutter run --verbose
   ```

5. **اتصل بدعم Google:**
   ```
   https://support.google.com/googleapi/
   ```

---

## 📞 الدعم

### روابط مفيدة:
- 📖 **التوثيق:** https://ai.google.dev/docs
- 🔑 **إدارة المفاتيح:** https://makersuite.google.com/app/apikey
- 💬 **المجتمع:** https://discuss.ai.google.dev/
- 🐛 **الإبلاغ عن مشاكل:** https://issuetracker.google.com/

---

## ✅ الخلاصة

**المشكلة:** مفتاح API غير مفعّل

**الحل السريع:**
1. اذهب إلى: https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com
2. اضغط "Enable"
3. انتظر دقيقة
4. جرب التطبيق مرة أخرى ✅

**أو:**
1. أنشئ مفتاح جديد من: https://makersuite.google.com/app/apikey
2. استبدله في الكود
3. أعد تشغيل التطبيق ✅

---

**تاريخ التحديث:** 24 أبريل 2026
