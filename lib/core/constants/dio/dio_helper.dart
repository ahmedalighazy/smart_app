import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioHelper {
  static Dio? _dio;
  static Dio get dio {
    if (_dio == null) {
      debugPrint('⚠️ DIO NOT INITIALIZED - Auto-initializing...');
      init();
    }
    return _dio!;
  }

  // Base URL للـ API
  static const String baseUrl = 'https://apisoapp.twintech-it.com';

  // Initialize Dio
  static void init() {
    debugPrint('🌐 INITIALIZING DIO WITH NEW API:');
    debugPrint('🔗 Base URL: $baseUrl');
    debugPrint('⏰ Timestamp: ${DateTime.now()}');
    debugPrint('─' * 50);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add custom logging interceptor
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
          handler.next(error);
        },
      ),
    );

    // Add default interceptor for detailed logging (only in debug mode)
    if (kDebugMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('🌐 DIO: $obj'),
        ),
      );
    }

    debugPrint('✅ DIO INITIALIZED SUCCESSFULLY');
  }

  // Custom logging methods
  static void _logRequest(RequestOptions options) {
    debugPrint('🚀 API REQUEST:');
    debugPrint('📍 URL: ${options.baseUrl}${options.path}');
    debugPrint('🔧 Method: ${options.method}');
    debugPrint('📋 Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('📦 Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔍 Query: ${options.queryParameters}');
    }
    debugPrint('⏰ Timestamp: ${DateTime.now()}');
    debugPrint('─' * 50);
  }

  static void _logResponse(Response response) {
    debugPrint('✅ API RESPONSE:');
    debugPrint(
      '📍 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    debugPrint('📊 Status: ${response.statusCode} ${response.statusMessage}');
    debugPrint('📦 Data: ${response.data}');
    debugPrint('⏰ Timestamp: ${DateTime.now()}');
    debugPrint('─' * 50);
  }

  static void _logError(DioException error) {
    debugPrint('❌ API ERROR:');
    debugPrint(
      '📍 URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
    );
    debugPrint('🔧 Method: ${error.requestOptions.method}');
    debugPrint('⚠️ Type: ${error.type}');
    debugPrint('💬 Message: ${error.message}');
    if (error.response != null) {
      debugPrint('📊 Status: ${error.response?.statusCode}');
      debugPrint('📦 Response Data: ${error.response?.data}');
    }
    debugPrint('⏰ Timestamp: ${DateTime.now()}');
    debugPrint('─' * 50);
  }

  // Set token in headers
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint('🔑 TOKEN SET: ${token.substring(0, 20)}...');
  }

  // Remove token from headers
  static void removeToken() {
    dio.options.headers.remove('Authorization');
    debugPrint('🔓 TOKEN REMOVED');
  }

  // Register new user
  static Future<Response> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      debugPrint('🔐 REGISTER ATTEMPT:');
      debugPrint('📧 Email: $email');
      debugPrint('👤 Username: $username');
      debugPrint('📝 Full Name: $fullName');

      final response = await dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );

      debugPrint('✅ REGISTER SUCCESS: Status ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ REGISTER FAILED: $e');
      rethrow;
    }
  }

  // Login user
  static Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 LOGIN ATTEMPT:');
      debugPrint('📧 Email: $email');

      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      debugPrint('✅ LOGIN SUCCESS: Status ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ LOGIN FAILED: $e');
      rethrow;
    }
  }

  // Generic GET request
  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('📥 GET REQUEST: $url');
      final response = await dio.get(url, queryParameters: query);
      debugPrint('✅ GET SUCCESS: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ GET FAILED: $url - $e');
      rethrow;
    }
  }

  // Generic POST request
  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('📤 POST REQUEST: $url');
      final response = await dio.post(url, data: data, queryParameters: query);
      debugPrint('✅ POST SUCCESS: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ POST FAILED: $url - $e');
      rethrow;
    }
  }

  // Generic PUT request
  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('🔄 PUT REQUEST: $url');
      final response = await dio.put(url, data: data, queryParameters: query);
      debugPrint('✅ PUT SUCCESS: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ PUT FAILED: $url - $e');
      rethrow;
    }
  }

  // Generic DELETE request
  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      debugPrint('🗑️ DELETE REQUEST: $url');
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: query,
      );
      debugPrint('✅ DELETE SUCCESS: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('❌ DELETE FAILED: $url - $e');
      rethrow;
    }
  }
}
