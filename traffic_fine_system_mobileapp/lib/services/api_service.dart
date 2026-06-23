import 'package:dio/dio.dart';


class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000', 
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Map<String, dynamic>? currentUser;
  static Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      // If the server returns 200 or 201, login is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        currentUser = response.data['user'];
        return true;
      }
      return false; // Login failed
    } catch (e) {
      print("Login Error: $e");
      return false; // Login failed
    }
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      // Replace '/user/profile' with your actual backend endpoint
      final response = await dio.get('/user/profile');
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  static Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/user/profile', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }
}