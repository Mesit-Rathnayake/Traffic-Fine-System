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
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
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
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

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
      final response = await dio.post(
        '/payments/pay',
        data: data,
        options: Options(
          // This tells Dio not to throw an error for 404 or other codes
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      // Now we manually check if it was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Server returned error status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Caught Dio error in payFine: $e');
      return false;
    }
  }

  // Add these to lib/services/api_service.dart

  static Future<Map<String, dynamic>> getAdminDashboardData() async {
    try {
      // You can fetch all required data in one go if you have a consolidated endpoint,
      // or perform multiple requests here.
      final responses = await Future.wait([
        dio.get('/admin/total-collections'),
        dio.get('/admin/district-collections'),
        dio.get('/admin/category-breakdown'),
        dio.get('/admin/users'),
        dio.get('/admin/fines'),
        dio.get('/admin/payments'),
      ]);

      return {
        'totalCollections': responses[0].data['total'],
        'districtCollections': responses[1].data,
        'categoryBreakdown': responses[2].data,
        'users': responses[3].data,
        'fines': responses[4].data,
        'payments': responses[5].data,
      };
    } catch (e) {
      print('Error fetching admin data: $e');
      throw e;
    }
  }

  static Future<Map<String, dynamic>> checkAdminAccess() async {
    final response = await dio.get('/fines/admin-only');
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    return {'message': data?.toString() ?? 'Admin route access confirmed.'};
  }
}
