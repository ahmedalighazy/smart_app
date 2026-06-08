# حل مؤقت لخطأ 400 - تعطيل ميزة تحليل الصور

## 🔴 المشكلة المستمرة

خطأ 400 يستمر في الظهور عند محاولة تحليل صور الطعام.

## 🔍 الأسباب المحتملة

1. **API Key لا يدعم Vision:**
   - بعض مفاتيح Gemini لا تدعم تحليل الصور
   - يحتاج تفعيل خاص لـ Vision API

2. **النموذج غير متاح:**
   - `gemini-1.5-flash` قد لا يكون متاحاً في منطقتك
   - أو يحتاج اشتراك مدفوع

3. **تنسيق الطلب:**
   - قد يكون هناك مشكلة في تنسيق الـ JSON

## ✅ الحل المؤقت: تعطيل الميزة

حتى يتم حل المشكلة، يمكنك تعطيل ميزة تحليل الصور مؤقتاً:

### الخطوة 1: تعديل الكود

في ملف `lib/data/services/food_vision_service.dart`، استبدل دالة `analyzeFood`:

```dart
Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
  developer.log(
    '📸 Food analysis temporarily disabled',
    name: 'FoodVisionService',
  );
  
  // رسالة مؤقتة للمستخدم
  throw Exception(
    'ميزة تحليل الصور معطلة مؤقتاً. '
    'يمكنك إضافة الوجبات يدوياً من قائمة الطعام.'
  );
}
```

### الخطوة 2: إخفاء زر الكاميرا (اختياري)

يمكنك إخفاء زر الكاميرا من الشاشة الرئيسية حتى يتم حل المشكلة.

## 🔧 الحل الدائم: تفعيل Vision API

### الطريقة الصحيحة:

1. **اذهب إلى Google Cloud Console:**
   ```
   https://console.cloud.google.com/
   ```

2. **فعّل Vertex AI API:**
   ```
   https://console.cloud.google.com/apis/library/aiplatform.googleapis.com
   ```

3. **أنشئ Service Account:**
   - اذهب إلى IAM & Admin → Service Accounts
   - أنشئ حساب خدمة جديد
   - أعطه صلاحية "Vertex AI User"

4. **استخدم Vertex AI بدلاً من Gemini API:**

```dart
// بدلاً من:
'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent'

// استخدم:
'https://us-central1-aiplatform.googleapis.com/v1/projects/YOUR_PROJECT_ID/locations/us-central1/publishers/google/models/gemini-1.5-flash:generateContent'
```

## 🎯 حل بديل: استخدام Gemini Pro Vision

جرب استخدام نموذج مختلف:

```dart
// في analyzeFood method
Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$apiKey',
)
```

## 📝 اختبار المفتاح

لاختبار إذا كان المفتاح يدعم Vision:

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [
        {"text": "What is in this image?"},
        {
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": "BASE64_IMAGE_DATA"
          }
        }
      ]
    }]
  }'
```

## 🆘 إذا استمرت المشكلة

### الخيارات المتاحة:

1. **استخدم API مختلف:**
   - OpenAI Vision API (مدفوع)
   - Claude Vision (مدفوع)
   - Azure Computer Vision (مدفوع)

2. **استخدم خدمة مجانية:**
   - Hugging Face Inference API
   - Replicate API

3. **اعتمد على الإدخال اليدوي:**
   - المستخدم يختار الطعام من القائمة
   - لا حاجة لتحليل الصور

## 💡 نصيحة

**الميزة الأساسية للتطبيق (حساب السعرات والتوصيات) تعمل بشكل ممتاز!**

ميزة تحليل الصور هي ميزة إضافية فقط. التطبيق يعمل بكفاءة بدونها.

---

**تاريخ التحديث:** 24 أبريل 2026
