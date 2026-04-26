import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/dio/dio_helper.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const _secureStorage = FlutterSecureStorage();

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get saved token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Save tokens
  static Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: _tokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  // Clear all auth data
  static Future<void> _clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Auto login - restore session
  static Future<Map<String, dynamic>> autoLogin() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      
      if (token != null && token.isNotEmpty) {
        DioHelper.setToken(token);
        return {
          'success': true,
          'message': 'تم استعادة الجلسة',
        };
      }
      return {
        'success': false,
        'message': 'لا توجد جلسة محفوظة',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في استعادة الجلسة',
      };
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('🔵 Starting registration...');
      print('📧 Email: $email');
      print('👤 Username: $username');
      print('📝 Full Name: $fullName');

      final response = await DioHelper.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // التحقق من وجود الـ token في الاستجابة
        final data = response.data;
        String? accessToken;
        String? refreshToken;

        // محاولة الحصول على الـ token من أماكن مختلفة في الاستجابة
        if (data is Map) {
          // Check nested data object
          if (data['data'] != null && data['data'] is Map) {
            accessToken = data['data']['access_token'];
            refreshToken = data['data']['refresh_token'];
          }
          // Check direct token fields
          else if (data['access_token'] != null) {
            accessToken = data['access_token'];
            refreshToken = data['refresh_token'];
          }
          // Check for 'token' field
          else if (data['token'] != null) {
            accessToken = data['token'];
          }
          // Check for 'tokens' object
          else if (data['tokens'] != null && data['tokens'] is Map) {
            accessToken = data['tokens']['access_token'];
            refreshToken = data['tokens']['refresh_token'];
          }
        }

        if (accessToken != null && accessToken.isNotEmpty) {
          print('✅ Token found: ${accessToken.substring(0, 20)}...');
          await _saveTokens(accessToken, refreshToken ?? '');
          DioHelper.setToken(accessToken);
        } else {
          print('⚠️ No token in response, but registration might be successful');
        }
        
        return {
          'success': true,
          'data': response.data,
          'message': 'تم التسجيل بنجاح',
        };
      } else {
        print('❌ Registration failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'فشل التسجيل',
        };
      }
    } on DioException catch (e) {
      print('❌ DioException during registration:');
      print('Type: ${e.type}');
      print('Message: ${e.message}');
      print('Response: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
      
      String errorMessage = _handleError(e);
      
      // Handle specific error cases
      if (e.response?.statusCode == 409 || e.response?.statusCode == 422) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        } else {
          errorMessage = 'البريد الإلكتروني أو اسم المستخدم مستخدم بالفعل';
        }
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Unexpected error during registration: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioHelper.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        // التحقق من وجود الـ token في الاستجابة
        final data = response.data;
        String? accessToken;
        String? refreshToken;

        // محاولة الحصول على الـ token من أماكن مختلفة في الاستجابة
        if (data['data'] != null && data['data']['access_token'] != null) {
          accessToken = data['data']['access_token'];
          refreshToken = data['data']['refresh_token'] ?? '';
        } else if (data['access_token'] != null) {
          accessToken = data['access_token'];
          refreshToken = data['refresh_token'] ?? '';
        } else if (data['token'] != null) {
          accessToken = data['token'];
          refreshToken = '';
        }

        if (accessToken != null) {
          // حفظ الـ tokens في Secure Storage
          await _saveTokens(accessToken, refreshToken ?? '');
          
          // تعيين الـ token في الـ headers
          DioHelper.setToken(accessToken);

          return {
            'success': true,
            'data': response.data,
            'accessToken': accessToken,
            'refreshToken': refreshToken,
            'message': 'تم تسجيل الدخول بنجاح',
          };
        } else {
          return {
            'success': false,
            'message': 'لم يتم العثور على الـ token في الاستجابة',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'فشل تسجيل الدخول',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع: $e',
      };
    }
  }

  // Logout user
  static Future<void> logout() async {
    await _clearAuthData();
    DioHelper.removeToken();
  }

  // Handle Dio errors
  static String _handleError(DioException error) {
    print('🔍 Handling error type: ${error.type}');
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال. تحقق من اتصالك بالإنترنت';
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الإرسال. حاول مرة أخرى';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاستقبال. حاول مرة أخرى';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        print('📊 Status Code: $statusCode');
        print('📦 Response Data: $responseData');
        
        // Try to get error message from response
        if (responseData is Map) {
          // Check for 'message' field
          if (responseData['message'] != null) {
            return responseData['message'];
          }
          
          // Check for 'error' field and provide custom messages
          if (responseData['error'] != null) {
            final errorCode = responseData['error'];
            
            if (errorCode == 'invalid_full_name') {
              return 'الاسم الكامل غير صحيح. يجب أن يحتوي على اسم أول واسم أخير\nمثال: أحمد محمد';
            } else if (errorCode == 'email_exists' || errorCode == 'username_exists') {
              return 'البريد الإلكتروني أو اسم المستخدم مستخدم بالفعل';
            } else if (errorCode == 'invalid_email') {
              return 'البريد الإلكتروني غير صحيح';
            } else if (errorCode == 'weak_password') {
              return 'كلمة المرور ضعيفة. يجب أن تكون 6 أحرف على الأقل';
            }
            
            return errorCode.toString();
          }
        }
        
        // Handle specific status codes
        if (statusCode == 401) {
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (statusCode == 400) {
          return 'بيانات غير صحيحة. تحقق من المعلومات المدخلة';
        } else if (statusCode == 409) {
          return 'البريد الإلكتروني أو اسم المستخدم مستخدم بالفعل';
        } else if (statusCode == 422) {
          return 'البيانات المدخلة غير صالحة';
        } else if (statusCode == 500) {
          return 'خطأ في الخادم. حاول مرة أخرى لاحقاً';
        }
        return 'خطأ في الخادم: $statusCode';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك';
      default:
        return 'حدث خطأ غير متوقع. حاول مرة أخرى';
    }
  }
}
