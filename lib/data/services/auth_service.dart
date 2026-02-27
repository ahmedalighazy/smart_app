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
      final response = await DioHelper.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
          await _saveTokens(accessToken, refreshToken ?? '');
          DioHelper.setToken(accessToken);
        }
        
        return {
          'success': true,
          'data': response.data,
          'message': 'تم التسجيل بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': 'فشل التسجيل',
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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال';
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الإرسال';
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاستقبال';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (error.response?.statusCode == 400) {
          return 'بيانات غير صحيحة';
        }
        return 'خطأ في الخادم: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
