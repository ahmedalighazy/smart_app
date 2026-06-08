# 🔄 تعليمات إعادة تشغيل التطبيق

## ⚠️ مهم جداً!

التغييرات التي تمت لن تعمل مع Hot Reload (`r`) - يجب إعادة تشغيل كامل!

---

## 🛑 الخطوة 1: أوقف التطبيق

### في Terminal:
اضغط `Ctrl+C` لإيقاف التطبيق

أو في VS Code:
- اضغط على زر **Stop** (المربع الأحمر)

---

## 🚀 الخطوة 2: أعد التشغيل

```bash
flutter run
```

---

## ✅ ما تم تغييره

### 1. API Key الجديد:
```dart
final String apiKey = 'AIzaSyDfXadTDQpFnCd0MK4iSCoxApNvE49jN3o';
```

### 2. تصحيح URL:
من:
```
/v1/models/gemini-1.5-flash
```

إلى:
```
/v1beta/models/gemini-1.5-pro
```

### 3. تغيير الموديل:
- `gemini-1.5-flash` → `gemini-1.5-pro`
- الموديل الجديد أكثر استقراراً ودقة

---

## 🎯 بعد إعادة التشغيل

1. افتح التطبيق
2. اذهب إلى تحليل الصورة
3. التقط صورة طعام أو اختر من المعرض
4. **يجب أن يعمل الآن!** ✅

---

## 🆘 إذا استمر الخطأ 404

جرب هذه الخطوات:

### الحل 1: تحقق من الموديل المتاح
قد يكون المفتاح لا يدعم `gemini-1.5-pro`. جرب:
```dart
'gemini-pro-vision' // الموديل القديم
```

### الحل 2: اختبر المفتاح
افتح Terminal ونفذ:
```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=AIzaSyDfXadTDQpFnCd0MK4iSCoxApNvE49jN3o" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [
        {"text": "Hello"},
        {
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": "/9j/4AAQSkZJRg=="
          }
        }
      ]
    }]
  }'
```

إذا حصلت على خطأ 404، جرب:
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=AIzaSyDfXadTDQpFnCd0MK4iSCoxApNvE49jN3o"
```

هذا سيعرض لك قائمة الموديلات المتاحة لمفتاحك.

---

## 📝 الموديلات المتاحة

| الموديل | الوصف | الحالة |
|---------|-------|--------|
| `gemini-1.5-pro` | الأحدث والأقوى | ✅ جرب هذا أولاً |
| `gemini-1.5-flash` | أسرع وأخف | ⚠️ قد لا يعمل |
| `gemini-pro-vision` | القديم | ✅ بديل مضمون |
| `gemini-pro` | نصوص فقط | ❌ لا يدعم الصور |

---

**تاريخ التحديث:** 3 مايو 2026
