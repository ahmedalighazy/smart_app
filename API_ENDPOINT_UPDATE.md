# تحديث API Endpoint والـ Logging

## التغييرات المطبقة

### 1. تغيير الـ API Endpoint
- **من**: `https://apisoapp.twingroups.com`
- **إلى**: `https://apisoapp.twintech-it.com`

### 2. إضافة Logging محسن

#### أ. Custom Logging Interceptor
- إضافة `InterceptorsWrapper` مخصص
- تسجيل تفصيلي لكل request/response/error
- استخدام emojis للتمييز السريع

#### ب. Enhanced Method Logging
- تسجيل محسن في كل method:
  - `register()` - تسجيل محاولات التسجيل
  - `login()` - تسجيل محاولات تسجيل الدخول
  - `getData()` - تسجيل طلبات GET
  - `postData()` - تسجيل طلبات POST
  - `putData()` - تسجيل طلبات PUT
  - `deleteData()` - تسجيل طلبات DELETE
  - `setToken()` - تسجيل تعيين الـ token
  - `removeToken()` - تسجيل إزالة الـ token

#### ج. Initialization Logging
- تسجيل تهيئة Dio مع الـ API الجديد
- عرض الـ Base URL المستخدم
- timestamp لكل عملية

### 3. أنواع الـ Logs

#### 🚀 Request Logs
```
🚀 API REQUEST:
📍 URL: https://apisoapp.twintech-it.com/auth/login
🔧 Method: POST
📋 Headers: {Content-Type: application/json, Authorization: Bearer ...}
📦 Data: {email: user@example.com, password: ***}
⏰ Timestamp: 2026-05-30 ...
```

#### ✅ Response Logs
```
✅ API RESPONSE:
📍 URL: https://apisoapp.twintech-it.com/auth/login
📊 Status: 200 OK
📦 Data: {success: true, token: ...}
⏰ Timestamp: 2026-05-30 ...
```

#### ❌ Error Logs
```
❌ API ERROR:
📍 URL: https://apisoapp.twintech-it.com/auth/login
🔧 Method: POST
⚠️ Type: DioExceptionType.badResponse
💬 Message: Http status error [401]
📊 Status: 401
📦 Response Data: {error: invalid_credentials}
⏰ Timestamp: 2026-05-30 ...
```

### 4. الملفات المعدلة
- `lib/core/constants/dio/dio_helper.dart`

### 5. المميزات الجديدة
- **Debug Mode Only**: الـ detailed logging يعمل فقط في debug mode
- **Security**: الـ token يظهر مقطوع (أول 20 حرف فقط)
- **Visual Separation**: خطوط فاصلة بين الـ logs
- **Timestamps**: وقت دقيق لكل عملية
- **Emoji Icons**: للتمييز السريع بين أنواع الـ logs

### 6. كيفية المتابعة
1. شغل التطبيق في debug mode
2. راقب الـ console للـ logs
3. ستظهر كل العمليات مع الـ API الجديد
4. يمكن متابعة نجاح/فشل كل طلب

### 7. الـ Endpoints المتاحة
- `/auth/register` - تسجيل مستخدم جديد
- `/auth/login` - تسجيل دخول
- `/auth/logout` - تسجيل خروج
- `/auth/refresh-token` - تحديث الـ token
- `/auth/forgot-password` - نسيان كلمة المرور
- `/auth/reset-password` - إعادة تعيين كلمة المرور
- `/auth/google-login` - تسجيل دخول بـ Google
- `/auth/verify-2fa` - التحقق الثنائي
- `/auth/enable-2fa` - تفعيل التحقق الثنائي
- `/auth/disable-2fa` - إلغاء التحقق الثنائي
- `/user/profile/{userId}` - بيانات المستخدم

## الخطوات التالية
1. اختبار الـ API الجديد
2. التأكد من عمل جميع الـ endpoints
3. مراقبة الـ logs للتأكد من صحة الاتصال
4. بناء APK جديد إذا كان كل شيء يعمل بشكل صحيح