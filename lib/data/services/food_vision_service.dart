import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../models/user_model.dart';

class FoodVisionService {
  final String apiKey = 'AIzaSyDfXadTDQpFnCd0MK4iSCoxApNvE49jN3o';

  static DateTime? _lastRequestTime;
  static const Duration _minDelayBetweenRequests = Duration(
    seconds: 2,
  ); // ثانيتين فقط!

  Future<void> _waitIfNeeded() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);

      if (timeSinceLastRequest < _minDelayBetweenRequests) {
        final waitTime = _minDelayBetweenRequests - timeSinceLastRequest;
        developer.log(
          '⏳ انتظار ${waitTime.inSeconds} ثانية...',
          name: 'FoodVisionService',
        );
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  Future<String> getAIRecommendations(
    UserModel user,
    CalculationResult result,
  ) async {
    developer.log(
      '🤖 Starting AI recommendations with Gemini',
      name: 'FoodVisionService',
    );

    // التحقق من المفتاح
    if (apiKey.isEmpty ||
        apiKey == 'YOUR_GEMINI_API_KEY_HERE' ||
        apiKey == 'ضع-مفتاحك-هنا') {
      return '''
⚠️ مفتاح Gemini API غير مُعرّف

📝 للحصول على مفتاح مجاني:
1. اذهب إلى: https://makersuite.google.com/app/apikey
2. سجل دخول بحساب Google
3. اضغط "Create API Key"
4. انسخ المفتاح وضعه في food_vision_service.dart

✅ مجاني تماماً - 60 طلب/دقيقة!
      ''';
    }

    // الانتظار إذا لزم الأمر
    await _waitIfNeeded();

    final prompt =
        '''
أنت أخصائي تغذية خبير. قدم توصيات غذائية مخصصة للشخص التالي:

📊 البيانات:
- العمر: ${user.age} سنة
- الجنس: ${user.gender == 'male' ? 'ذكر' : 'أنثى'}
- الوزن: ${user.weight} كجم
- الطول: ${user.height} سم
- BMI: ${result.bmi.toStringAsFixed(1)} (${result.bmiCategory})
- السعرات اليومية المطلوبة: ${result.tdee.toStringAsFixed(0)} سعرة
- مستوى النشاط: ${_getActivityLevelArabic(user.activityLevel)}
- الحالة الخاصة: ${user.physiologicalState ?? 'عادي'}

📝 المطلوب (بالعربية):
1. تقييم الحالة الصحية
2. 5 نصائح غذائية محددة
3. مثال على وجبات يومية (إفطار، غداء، عشاء)
4. أطعمة يُنصح بها
5. أطعمة يُنصح بتجنبها

اجعل الإجابة واضحة ومنظمة باستخدام الإيموجي.
    ''';

    int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        developer.log(
          '🚀 Sending request to Gemini (attempt ${retryCount + 1}/$maxRetries)',
          name: 'FoodVisionService',
        );

        final response = await http
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
              ),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.7,
                  'maxOutputTokens': 8000, // زيادة من 2000 إلى 8000
                },
              }),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('انتهت مهلة الاتصال');
              },
            );

        developer.log(
          '📥 Response status: ${response.statusCode}',
          name: 'FoodVisionService',
        );

        if (response.statusCode == 200) {
          developer.log(
            '✅ Successful response from Gemini',
            name: 'FoodVisionService',
          );

          final data = jsonDecode(utf8.decode(response.bodyBytes));

          if (data['candidates'] == null || data['candidates'].isEmpty) {
            return 'خطأ: لم يتم الحصول على نتائج من Gemini';
          }

          final recommendations =
              data['candidates'][0]['content']['parts'][0]['text'];
          developer.log(
            '✅ Recommendations received: ${recommendations.length} chars',
            name: 'FoodVisionService',
          );

          return recommendations;
        } else if (response.statusCode == 429) {
          retryCount++;
          developer.log(
            '⏱️ Rate limit hit (attempt $retryCount/$maxRetries)',
            name: 'FoodVisionService',
          );

          if (retryCount < maxRetries) {
            developer.log(
              '⏳ سننتظر 10 ثواني ونحاول مرة أخرى...',
              name: 'FoodVisionService',
            );
            await Future.delayed(const Duration(seconds: 10));
            continue;
          } else {
            return '''
⏱️ تم تجاوز حد الطلبات مؤقتاً

✅ الحل:
انتظر 10 ثواني وحاول مرة أخرى

💡 Gemini مجاني ويسمح بـ 60 طلب/دقيقة
            ''';
          }
        } else if (response.statusCode == 503) {
          retryCount++;
          // Exponential backoff: 5s, 15s, 30s
          final waitTime = retryCount == 1 ? 5 : (retryCount == 2 ? 15 : 30);

          developer.log(
            '🔧 Service unavailable (503) - attempt $retryCount/$maxRetries',
            name: 'FoodVisionService',
          );

          if (retryCount < maxRetries) {
            developer.log(
              '⏳ الخدمة مشغولة، سننتظر $waitTime ثانية ونحاول مرة أخرى...',
              name: 'FoodVisionService',
            );
            await Future.delayed(Duration(seconds: waitTime));
            continue;
          } else {
            return '''
🔧 الخدمة غير متاحة مؤقتاً (503)

📝 الأسباب المحتملة:
• خوادم Gemini مشغولة حالياً
• صيانة مؤقتة على الخدمة
• ضغط كبير على الخوادم

✅ الحل:
انتظر دقيقة واحدة وحاول مرة أخرى

💡 هذا خطأ مؤقت من Google وسيتم حله تلقائياً
            ''';
          }
        } else if (response.statusCode == 400) {
          final errorData = jsonDecode(response.body);
          return 'خطأ في الطلب: ${errorData['error']['message'] ?? 'غير معروف'}';
        } else if (response.statusCode == 403) {
          return '''
🔑 مفتاح API غير صحيح أو غير مفعّل

✅ الحل:
1. تأكد من المفتاح في food_vision_service.dart
2. فعّل Gemini API من: https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com
          ''';
        } else {
          developer.log(
            '❌ API error: ${response.statusCode}',
            name: 'FoodVisionService',
          );
          return 'خطأ في الحصول على التوصيات: ${response.statusCode}';
        }
      } on SocketException catch (e) {
        developer.log('❌ Network error', name: 'FoodVisionService', error: e);
        return 'خطأ في الاتصال بالإنترنت. تحقق من اتصالك';
      } catch (e) {
        developer.log(
          '❌ Unexpected error',
          name: 'FoodVisionService',
          error: e,
        );

        if (retryCount < maxRetries - 1) {
          retryCount++;
          developer.log(
            '🔄 Retrying after error (attempt $retryCount/$maxRetries)',
            name: 'FoodVisionService',
          );
          await Future.delayed(const Duration(seconds: 5));
          continue;
        }

        return 'خطأ غير متوقع: $e';
      }
    }

    return 'فشل الحصول على التوصيات بعد عدة محاولات';
  }

  // تحليل صورة الطعام باستخدام Gemini Vision
  Future<FoodAnalysisResult> analyzeFood(File imageFile) async {
    developer.log(
      '📸 Starting food analysis with Gemini Vision',
      name: 'FoodVisionService',
    );

    // التحقق من المفتاح
    if (apiKey.isEmpty ||
        apiKey == 'YOUR_GEMINI_API_KEY_HERE' ||
        apiKey == 'ضع-مفتاحك-هنا') {
      throw Exception(
        '⚠️ مفتاح Gemini API غير مُعرّف\n\n'
        '📝 للحصول على مفتاح مجاني:\n'
        '1. اذهب إلى: https://aistudio.google.com/app/apikey\n'
        '2. سجل دخول بحساب Google\n'
        '3. اضغط "Create API Key"\n'
        '4. انسخ المفتاح وضعه في food_vision_service.dart',
      );
    }

    // الانتظار إذا لزم الأمر
    await _waitIfNeeded();

    try {
      // قراءة الصورة وتحويلها إلى base64
      final imageBytes = await imageFile.readAsBytes();
      final imageSizeInMB = imageBytes.length / (1024 * 1024);

      developer.log(
        '📊 Image size: ${imageSizeInMB.toStringAsFixed(2)} MB',
        name: 'FoodVisionService',
      );

      // التحقق من حجم الصورة (الحد الأقصى 4MB)
      if (imageSizeInMB > 4) {
        throw Exception(
          'حجم الصورة كبير جداً (${imageSizeInMB.toStringAsFixed(1)} MB)\n'
          'الحد الأقصى: 4 MB\n\n'
          'جرب التقاط صورة بجودة أقل',
        );
      }

      final base64Image = base64Encode(imageBytes);

      // Prompt بسيط وواضح جداً
      final prompt = '''
أنت خبير تغذية. حلل هذه الصورة وأعطني المعلومات بالتنسيق التالي بالضبط (بدون أي نص إضافي):

FOOD_NAME: [اسم الطعام بالعربية]
INGREDIENTS: [المكونات الرئيسية مفصولة بفواصل]
PORTION_SIZE: [حجم الحصة المقدر مثل: طبق متوسط، 200 جرام]
CALORIES: [رقم فقط - السعرات الحرارية]
PROTEIN: [رقم فقط - البروتين بالجرام]
CARBS: [رقم فقط - الكربوهيدرات بالجرام]
FATS: [رقم فقط - الدهون بالجرام]
FIBER: [رقم فقط - الألياف بالجرام]
HEALTH_RATING: [رقم من 1 إلى 10]
TIPS: [نصيحة غذائية قصيرة بالعربية]
DETAILED_ANALYSIS: [تحليل تفصيلي للقيمة الغذائية بالعربية]

مهم جداً:
- استخدم أرقام واقعية بناءً على حجم الحصة في الصورة
- لا تضع أي نص قبل أو بعد التنسيق المطلوب
- الأرقام يجب أن تكون أرقام فقط بدون كلمات (مثال: 450 وليس 450 سعرة)
''';

      developer.log(
        '🚀 Sending request to Gemini Vision API',
        name: 'FoodVisionService',
      );

      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                    {
                      'inline_data': {
                        'mime_type': 'image/jpeg',
                        'data': base64Image,
                      },
                    },
                  ],
                },
              ],
              'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 2048},
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('انتهت مهلة الاتصال (30 ثانية)');
            },
          );

      developer.log(
        '📥 Response status: ${response.statusCode}',
        name: 'FoodVisionService',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('لم يتم الحصول على نتائج من Gemini');
        }

        final analysisText =
            data['candidates'][0]['content']['parts'][0]['text'];

        developer.log(
          '✅ Analysis received: ${analysisText.length} chars',
          name: 'FoodVisionService',
        );

        // طباعة النص الكامل للتحقق من التنسيق
        developer.log(
          '📄 Full response text:\n$analysisText',
          name: 'FoodVisionService',
        );

        return _parseAnalysis(analysisText);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']['message'] ?? 'غير معروف';

        developer.log(
          '❌ Error 400 Response: ${response.body}',
          name: 'FoodVisionService',
        );
        developer.log(
          '❌ Error message: $errorMessage',
          name: 'FoodVisionService',
        );

        throw Exception(
          '❌ خطأ في تحليل الصورة (400)\n\n'
          'السبب المحتمل:\n'
          '• API Key لا يدعم Vision API\n'
          '• الصورة غير صالحة\n\n'
          '✅ الحل:\n'
          '1. احصل على API Key جديد من:\n'
          '   https://aistudio.google.com/app/apikey\n'
          '2. تأكد من تفعيل Generative Language API\n'
          '3. استبدل المفتاح في food_vision_service.dart\n\n'
          'التفاصيل: $errorMessage',
        );
      } else if (response.statusCode == 403) {
        throw Exception(
          '🔑 مفتاح API غير صحيح أو غير مفعّل\n\n'
          '✅ الحل:\n'
          '1. تأكد من المفتاح في food_vision_service.dart\n'
          '2. فعّل Gemini API من:\n'
          '   https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com',
        );
      } else if (response.statusCode == 429) {
        throw Exception(
          '⏱️ تم تجاوز حد الطلبات\n\n'
          'انتظر 10 ثواني وحاول مرة أخرى',
        );
      } else if (response.statusCode == 503) {
        throw Exception(
          '🔧 الخدمة غير متاحة مؤقتاً (503)\n\n'
          'انتظر دقيقة واحدة وحاول مرة أخرى',
        );
      } else {
        throw Exception('خطأ في الحصول على التحليل: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      developer.log('❌ Network error', name: 'FoodVisionService', error: e);
      throw Exception('خطأ في الاتصال بالإنترنت. تحقق من اتصالك');
    } catch (e) {
      developer.log('❌ Could not parse error: $e', name: 'FoodVisionService');
      rethrow;
    }
  }

  // تحليل النص المُرجع من Gemini
  FoodAnalysisResult _parseAnalysis(String text) {
    try {
      return FoodAnalysisResult(
        foodName: _extractField(text, 'FOOD_NAME'),
        ingredients: _extractField(text, 'INGREDIENTS'),
        portionSize: _extractField(text, 'PORTION_SIZE'),
        calories: _extractNumber(text, 'CALORIES'),
        protein: _extractNumber(text, 'PROTEIN'),
        carbs: _extractNumber(text, 'CARBS'),
        fats: _extractNumber(text, 'FATS'),
        fiber: _extractNumber(text, 'FIBER'),
        healthRating: _extractField(text, 'HEALTH_RATING'),
        tips: _extractField(text, 'TIPS'),
        detailedAnalysis: _extractField(text, 'DETAILED_ANALYSIS'),
      );
    } catch (e) {
      throw Exception('خطأ في تحليل النتيجة: $e');
    }
  }

  String _extractField(String text, String field) {
    RegExp regex = RegExp(
      '$field:\\s*(.+?)(?=\\n[A-Z_]+:|\\n\$|\$)',
      multiLine: true,
      dotAll: true,
    );
    Match? match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? 'غير متوفر';
  }

  int _extractNumber(String text, String field) {
    // محاولة 1: البحث عن النمط الأساسي (FIELD: 123)
    RegExp regex1 = RegExp('$field:\\s*(\\d+)', caseSensitive: false);
    Match? match1 = regex1.firstMatch(text);
    if (match1 != null) {
      developer.log(
        '✅ Found $field: ${match1.group(1)}',
        name: 'FoodVisionService',
      );
      return int.parse(match1.group(1)!);
    }

    // محاولة 2: البحث عن أرقام مع كلمات عربية (123 سعرة، 45 جرام)
    RegExp regex2 = RegExp(
      '$field[:\\s]*(\\d+)\\s*(?:سعرة|جرام|غرام|g)?',
      caseSensitive: false,
    );
    Match? match2 = regex2.firstMatch(text);
    if (match2 != null) {
      developer.log(
        '✅ Found $field (Arabic): ${match2.group(1)}',
        name: 'FoodVisionService',
      );
      return int.parse(match2.group(1)!);
    }

    // محاولة 3: البحث في السطر الكامل
    List<String> lines = text.split('\n');
    for (String line in lines) {
      if (line.toUpperCase().contains(field.toUpperCase())) {
        RegExp numRegex = RegExp(r'(\d+)');
        Match? numMatch = numRegex.firstMatch(line);
        if (numMatch != null) {
          developer.log(
            '✅ Found $field (line): ${numMatch.group(1)}',
            name: 'FoodVisionService',
          );
          return int.parse(numMatch.group(1)!);
        }
      }
    }

    developer.log(
      '⚠️ Could not find $field, returning 0',
      name: 'FoodVisionService',
    );
    return 0;
  }

  String _getActivityLevelArabic(String level) {
    switch (level) {
      case 'sedentary':
        return 'قليل جداً';
      case 'light':
        return 'خفيف';
      case 'moderate':
        return 'معتدل';
      case 'active':
        return 'نشط';
      case 'very_active':
        return 'نشط جداً';
      default:
        return 'معتدل';
    }
  }
}
