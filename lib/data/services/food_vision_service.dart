// 🌟 Google Gemini Service - مجاني 100% وبدون حدود صارمة

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

import '../models/user_model.dart';

class FoodVisionService {
  final String apiKey = 'AIzaSyCOTsqI0YTCuH_aAqA_d1FUUtAXpYd0q6U';

  static DateTime? _lastRequestTime;
  static const Duration _minDelayBetweenRequests = Duration(seconds: 2); // ثانيتين فقط!

  Future<void> _waitIfNeeded() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);

      if (timeSinceLastRequest < _minDelayBetweenRequests) {
        final waitTime = _minDelayBetweenRequests - timeSinceLastRequest;
        developer.log('⏳ انتظار ${waitTime.inSeconds} ثانية...',
            name: 'FoodVisionService');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  Future<String> getAIRecommendations(UserModel user, CalculationResult result) async {
    developer.log('🤖 Starting AI recommendations with Gemini', name: 'FoodVisionService');

    // التحقق من المفتاح
    if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE' || apiKey == 'ضع-مفتاحك-هنا') {
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

    final prompt = '''
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
        developer.log('🚀 Sending request to Gemini (attempt ${retryCount + 1}/$maxRetries)',
            name: 'FoodVisionService');

        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 8000, // زيادة من 2000 إلى 8000
            }
          }),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('انتهت مهلة الاتصال');
          },
        );

        developer.log('📥 Response status: ${response.statusCode}',
            name: 'FoodVisionService');

        if (response.statusCode == 200) {
          developer.log('✅ Successful response from Gemini', name: 'FoodVisionService');

          final data = jsonDecode(utf8.decode(response.bodyBytes));

          if (data['candidates'] == null || data['candidates'].isEmpty) {
            return 'خطأ: لم يتم الحصول على نتائج من Gemini';
          }

          final recommendations = data['candidates'][0]['content']['parts'][0]['text'];
          developer.log('✅ Recommendations received: ${recommendations.length} chars',
              name: 'FoodVisionService');

          return recommendations;

        } else if (response.statusCode == 429) {
          retryCount++;
          developer.log('⏱️ Rate limit hit (attempt $retryCount/$maxRetries)',
              name: 'FoodVisionService');

          if (retryCount < maxRetries) {
            developer.log('⏳ سننتظر 10 ثواني ونحاول مرة أخرى...',
                name: 'FoodVisionService');
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
          developer.log('❌ API error: ${response.statusCode}', name: 'FoodVisionService');
          return 'خطأ في الحصول على التوصيات: ${response.statusCode}';
        }

      } on SocketException catch (e) {
        developer.log('❌ Network error', name: 'FoodVisionService', error: e);
        return 'خطأ في الاتصال بالإنترنت. تحقق من اتصالك';
      } catch (e) {
        developer.log('❌ Unexpected error', name: 'FoodVisionService', error: e);

        if (retryCount < maxRetries - 1) {
          retryCount++;
          developer.log('🔄 Retrying after error (attempt $retryCount/$maxRetries)',
              name: 'FoodVisionService');
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
    developer.log('📸 Starting food analysis with Gemini Vision', name: 'FoodVisionService');

    // الانتظار إذا لزم الأمر
    await _waitIfNeeded();

    try {
      if (!await imageFile.exists()) {
        throw Exception('الصورة غير موجودة');
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
أنت خبير تغذية. حلل هذه الصورة وقدم المعلومات بهذا التنسيق بالضبط:

FOOD_NAME: [اسم الطعام بالعربية]
INGREDIENTS: [المكونات الرئيسية]
PORTION_SIZE: [صغير أو متوسط أو كبير]
CALORIES: [رقم فقط]
PROTEIN: [رقم فقط]
CARBS: [رقم فقط]
FATS: [رقم فقط]
FIBER: [رقم فقط]
HEALTH_RATING: [ممتاز أو جيد أو متوسط أو ضعيف]
TIPS: [نصيحة واحدة مختصرة]
DETAILED_ANALYSIS: [تحليل تفصيلي]
                  '''
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 4000, // زيادة من 1000 إلى 4000
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final analysisText = data['candidates'][0]['content']['parts'][0]['text'];
        return _parseAnalysis(analysisText);
      } else if (response.statusCode == 429) {
        throw Exception('تم تجاوز حد الطلبات. انتظر 10 ثواني وحاول مرة أخرى');
      } else if (response.statusCode == 403) {
        throw Exception('مفتاح API غير صحيح أو غير مفعّل');
      } else {
        throw Exception('خطأ في API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في تحليل الصورة: $e');
    }
  }

  // باقي الدوال كما هي...
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
    RegExp regex = RegExp('$field:\\s*(\\d+)');
    Match? match = regex.firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  String _getActivityLevelArabic(String level) {
    switch (level) {
      case 'sedentary': return 'قليل جداً';
      case 'light': return 'خفيف';
      case 'moderate': return 'معتدل';
      case 'active': return 'نشط';
      case 'very_active': return 'نشط جداً';
      default: return 'معتدل';
    }
  }
}
