import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/social_media_model.dart';
import '../../data/services/social_media_service.dart';
import '../../core/constants/dio/dio_helper.dart';

// States
abstract class SocialMediaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SocialMediaInitial extends SocialMediaState {}

class SocialMediaLoading extends SocialMediaState {}

class SocialMediaAuthenticated extends SocialMediaState {
  final SocialMediaUser? user;
  final String? accessToken;

  SocialMediaAuthenticated({this.user, this.accessToken});

  @override
  List<Object?> get props => [user, accessToken];
}

class SocialMediaError extends SocialMediaState {
  final String message;

  SocialMediaError(this.message);

  @override
  List<Object?> get props => [message];
}

class SocialMediaSuccess extends SocialMediaState {
  final String message;

  SocialMediaSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SocialMediaCubit extends Cubit<SocialMediaState> {
  static const String _tokenKey = 'social_media_token';
  static const String _refreshTokenKey = 'social_media_refresh_token';

  SocialMediaCubit() : super(SocialMediaInitial());

  // Save tokens to SharedPreferences
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
  }

  // Get saved token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear tokens
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Check if user is logged in
  Future<bool> checkAuth() async {
    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        DioHelper.setToken(token);
        emit(SocialMediaAuthenticated(accessToken: token));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Register
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      emit(SocialMediaLoading());

      final response = await SocialMediaService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.success && response.accessToken != null) {
        await _saveTokens(response.accessToken!, response.refreshToken);
        DioHelper.setToken(response.accessToken!);
        emit(SocialMediaAuthenticated(
          user: response.user,
          accessToken: response.accessToken,
        ));
      } else {
        emit(SocialMediaError(response.message ?? 'فشل التسجيل'));
      }
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(SocialMediaLoading());

      final response = await SocialMediaService.login(
        email: email,
        password: password,
      );

      if (response.success && response.accessToken != null) {
        await _saveTokens(response.accessToken!, response.refreshToken);
        DioHelper.setToken(response.accessToken!);
        emit(SocialMediaAuthenticated(
          user: response.user,
          accessToken: response.accessToken,
        ));
      } else {
        emit(SocialMediaError(response.message ?? 'فشل تسجيل الدخول'));
      }
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      emit(SocialMediaLoading());
      await SocialMediaService.logout();
      await _clearTokens();
      DioHelper.removeToken();
      emit(SocialMediaInitial());
    } catch (e) {
      await _clearTokens();
      DioHelper.removeToken();
      emit(SocialMediaInitial());
    }
  }

  // Google Login
  Future<void> googleLogin() async {
    try {
      emit(SocialMediaLoading());

      final response = await SocialMediaService.googleLogin();

      if (response.success && response.accessToken != null) {
        await _saveTokens(response.accessToken!, response.refreshToken);
        DioHelper.setToken(response.accessToken!);
        emit(SocialMediaAuthenticated(
          user: response.user,
          accessToken: response.accessToken,
        ));
      } else {
        emit(SocialMediaError(response.message ?? 'فشل تسجيل الدخول بجوجل'));
      }
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.forgotPassword(email);
      emit(SocialMediaSuccess(
        response['message'] ?? 'تم إرسال رابط إعادة تعيين كلمة المرور',
      ));
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Reset Password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      emit(SocialMediaSuccess(
        response['message'] ?? 'تم تغيير كلمة المرور بنجاح',
      ));
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Get User Profile
  Future<void> getUserProfile(int userId) async {
    try {
      emit(SocialMediaLoading());
      final user = await SocialMediaService.getUserProfile(userId);
      emit(SocialMediaAuthenticated(user: user));
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Verify 2FA
  Future<void> verify2FA(String code) async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.verify2FA(code);
      emit(SocialMediaSuccess(
        response['message'] ?? 'تم التحقق بنجاح',
      ));
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Enable 2FA
  Future<void> enable2FA() async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.enable2FA();
      emit(SocialMediaSuccess(
        response['message'] ?? 'تم تفعيل المصادقة الثنائية',
      ));
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Disable 2FA
  Future<void> disable2FA() async {
    try {
      emit(SocialMediaLoading());
      final response = await SocialMediaService.disable2FA();
      emit(SocialMediaSuccess(
        response['message'] ?? 'تم تعطيل المصادقة الثنائية',
      ));
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }

  // Refresh Token
  Future<void> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken != null) {
        final response = await SocialMediaService.refreshToken(refreshToken);
        
        if (response.success && response.accessToken != null) {
          await _saveTokens(response.accessToken!, response.refreshToken);
          DioHelper.setToken(response.accessToken!);
          emit(SocialMediaAuthenticated(
            user: response.user,
            accessToken: response.accessToken,
          ));
        }
      }
    } catch (e) {
      emit(SocialMediaError(e.toString()));
    }
  }
}
