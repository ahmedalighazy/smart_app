import 'package:dio/dio.dart';
import '../../core/constants/dio/dio_helper.dart';
import '../models/social_media_model.dart';

class SocialMediaService {
  // Register new user
  static Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Login user
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Refresh Token
  static Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await DioHelper.postData(
        url: '/auth/refresh-token',
        data: {
          'refresh_token': refreshToken,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await DioHelper.postData(url: '/auth/logout');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Google Login
  static Future<AuthResponse> googleLogin() async {
    try {
      final response = await DioHelper.getData(url: '/auth/google-login');
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await DioHelper.postData(
        url: '/auth/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await DioHelper.postData(
        url: '/auth/reset-password',
        data: {
          'token': token,
          'new_password': newPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get User Profile
  static Future<SocialMediaUser> getUserProfile(int userId) async {
    try {
      final response = await DioHelper.getData(url: '/user/profile/$userId');
      return SocialMediaUser.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Verify 2FA
  static Future<Map<String, dynamic>> verify2FA(String code) async {
    try {
      final response = await DioHelper.postData(
        url: '/auth/verify-2fa',
        data: {'code': code},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Enable 2FA
  static Future<Map<String, dynamic>> enable2FA() async {
    try {
      final response = await DioHelper.postData(url: '/auth/enable-2fa');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Disable 2FA
  static Future<Map<String, dynamic>> disable2FA() async {
    try {
      final response = await DioHelper.postData(url: '/auth/disable-2fa');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
          return error.response?.data['message'] ?? 'بيانات غير صحيحة';
        } else if (error.response?.statusCode == 409) {
          return 'البريد الإلكتروني مستخدم بالفعل';
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
