import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    return 'http://10.0.2.2:3000';
  }

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static Map<String, dynamic>? currentUser;
  static String? accessToken;

  static void setAuthToken(String? token) {
    accessToken = token;
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentUser = response.data['user'];
        final token = response.data['access_token']?.toString();
        if (token != null && token.isNotEmpty) {
          setAuthToken(token);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await dio.get('/users/profile');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
    return null;
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/users/profile', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchFine(String referenceNumber) async {
    try {
      final response = await dio.get('/fines/$referenceNumber');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Error fetching fine: $e');
    }
    return null;
  }

  static Future<bool> payFine(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/payments/pay', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error paying fine: $e');
      return false;
    }
  }
}