import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;

  // Base URL للـ API
  static const String baseUrl = 'https://apisoapp.twingroups.com';

  // Initialize Dio
  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for logging (optional)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Set token in headers
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove token from headers
  static void removeToken() {
    dio.options.headers.remove('Authorization');
  }

  // Register new user
  static Future<Response> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Login user
  static Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Generic GET request
  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await dio.get(
        url,
        queryParameters: query,
      );
      return response;
    } catch (e) {
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
      final response = await dio.post(
        url,
        data: data,
        queryParameters: query,
      );
      return response;
    } catch (e) {
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
      final response = await dio.put(
        url,
        data: data,
        queryParameters: query,
      );
      return response;
    } catch (e) {
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
      final response = await dio.delete(
        url,
        data: data,
        queryParameters: query,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
