# معلومات API Key المستخدم في المشروع

## 🔑 نوع الـ API Key

**API Key:** `AIzaSyDUt3x9GaB8xiEMt9-FO_qk7PJxSnIZte4`

---

## 🤖 نوع الـ AI Model

### **Google Gemini 2.5 Flash**

**الشركة:** Google  
**المنتج:** Gemini AI  
**النموذج:** `gemini-2.5-flash`  
**النوع:** Large Language Model (LLM)

---

## 📍 الاستخدام في المشروع

### الملف:
`lib/data/services/food_vision_service.dart`

### الوظائف:

#### 1. **توصيات التغذية الذكية** (`getAIRecommendations`)
```dart
final response = await http.post(
  Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'
  ),
  // ...
);
```

**الاستخدام:**
- تحليل بيانات المستخدم (العمر، الوزن، الطول، BMI، النشاط)
- تقديم توصيات غذائية مخصصة
- اقتراح وجبات يومية
- نصائح صحية

#### 2. **تحليل صور الطعام** (`analyzeFood`)
```dart
final response = await http.post(
  Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'
  ),
  // مع إرسال الصورة كـ base64
);
```

**الاستخدام:**
- تحليل صور الطعام
- التعرف على المكونات
- حساب القيم الغذائية التقريبية
- تقييم صحة الوجبة

---

## 🌟 مميزات Gemini 2.5 Flash

### السرعة:
- ⚡ **Flash** = نموذج سريع ومحسّن
- ⚡ استجابة فورية (أقل من ثانية)
- ⚡ مناسب للتطبيقات التفاعلية

### القدرات:
- 📝 **فهم النصوص** بجميع اللغات (بما فيها العربية)
- 🖼️ **تحليل الصور** (Vision)
- 🧠 **ذكاء متقدم** في التحليل والتوصيات
- 🎯 **دقة عالية** في المعلومات الصحية

### الحدود:
- 📊 **60 طلب/دقيقة** (مجاني)
- 📊 **8,000 tokens** للإخراج (maxOutputTokens)
- 📊 **4,000 tokens** لتحليل الصور

---

## 💰 التكلفة

### الخطة المجانية:
- ✅ **مجاني 100%**
- ✅ 60 طلب/دقيقة
- ✅ 1,500 طلب/يوم
- ✅ بدون بطاقة ائتمان

### الحصول على API Key:
1. اذهب إلى: https://makersuite.google.com/app/apikey
2. سجل دخول بحساب Google
3. اضغط "Create API Key"
4. انسخ المفتاح

---

## 🔒 الأمان

### ⚠️ تحذير مهم:
**API Key الحالي مكشوف في الكود!**

```dart
// ❌ غير آمن - المفتاح مكشوف
final String apiKey = 'AIzaSyDUt3x9GaB8xiEMt9-FO_qk7PJxSnIZte4';
```

### ✅ الحل الموصى به:

#### 1. استخدام Environment Variables
```dart
// ✅ آمن - المفتاح في ملف منفصل
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
```

#### 2. إنشاء ملف `.env`
```env
GEMINI_API_KEY=AIzaSyDUt3x9GaB8xiEMt9-FO_qk7PJxSnIZte4
```

#### 3. إضافة `.env` إلى `.gitignore`
```gitignore
# API Keys
.env
*.env
```

#### 4. تحديث `pubspec.yaml`
```yaml
dependencies:
  flutter_dotenv: ^5.1.0

flutter:
  assets:
    - .env
```

---

## 📊 الاستخدام الحالي في المشروع

### معدل الطلبات:
```dart
static const Duration _minDelayBetweenRequests = Duration(seconds: 2);
```
- ⏱️ **2 ثانية** بين كل طلب
- 📊 **30 طلب/دقيقة** كحد أقصى (أقل من الحد المسموح)

### إعادة المحاولة:
```dart
int maxRetries = 3;
```
- 🔄 **3 محاولات** عند الفشل
- ⏳ **Exponential Backoff** للخطأ 503:
  - المحاولة 1: انتظار 5 ثواني
  - المحاولة 2: انتظار 15 ثانية
  - المحاولة 3: انتظار 30 ثانية

### Timeout:
```dart
.timeout(const Duration(seconds: 30))
```
- ⏱️ **30 ثانية** كحد أقصى للانتظار

---

## 🔗 الروابط المفيدة

### التوثيق الرسمي:
- 📖 **Gemini API Docs:** https://ai.google.dev/docs
- 📖 **API Reference:** https://ai.google.dev/api/rest
- 📖 **Pricing:** https://ai.google.dev/pricing

### الحصول على API Key:
- 🔑 **Google AI Studio:** https://makersuite.google.com/app/apikey
- 🔑 **Google Cloud Console:** https://console.cloud.google.com/

### الدعم:
- 💬 **Community:** https://discuss.ai.google.dev/
- 🐛 **Issue Tracker:** https://issuetracker.google.com/issues?q=componentid:1368726

---

## 📝 ملاحظات إضافية

### نقاط القوة:
- ✅ مجاني تماماً
- ✅ سريع جداً (Flash)
- ✅ دعم ممتاز للعربية
- ✅ قدرات Vision متقدمة
- ✅ دقة عالية في المعلومات الصحية

### نقاط الضعف:
- ⚠️ حد 60 طلب/دقيقة (قد لا يكفي للتطبيقات الكبيرة)
- ⚠️ يحتاج اتصال إنترنت
- ⚠️ قد يحدث خطأ 503 في أوقات الذروة

### البدائل المحتملة:
- 🔄 **Gemini Pro** (أقوى لكن أبطأ)
- 🔄 **OpenAI GPT-4** (مدفوع)
- 🔄 **Claude** (مدفوع)
- 🔄 **Llama** (مفتوح المصدر، يحتاج سيرفر)

---

## 🎯 الخلاصة

**API Key الحالي:**
- 🤖 **النوع:** Google Gemini 2.5 Flash
- 💰 **التكلفة:** مجاني
- ⚡ **السرعة:** سريع جداً
- 🎯 **الاستخدام:** توصيات تغذية + تحليل صور
- ⚠️ **الأمان:** يحتاج تحسين (نقل المفتاح لملف .env)

---

**تاريخ التحديث:** 24 أبريل 2026  
**الإصدار:** 2.0.0
