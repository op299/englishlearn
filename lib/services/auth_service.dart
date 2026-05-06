import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import '../models/auth_model.dart';

class AuthService {
  final String baseUrl = ApiService.baseUrl;

  // Lưu token
  Future<void> saveToken(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  // Lấy access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // Lấy refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // Xóa tokens
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Đăng ký
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    String currentLevel = 'A1',
    int dailyGoalMinutes = 10,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        fullName: fullName,
        currentLevel: currentLevel,
        dailyGoalMinutes: dailyGoalMinutes,
      );

      final response = await http.post(
        Uri.parse(ApiService.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final data = AuthResponse.fromJson(jsonDecode(response.body));
        await saveToken(data.accessToken, data.refreshToken);
        return data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Đăng nhập
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequest(email: email, password: password);

      final response = await http.post(
        Uri.parse(ApiService.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = AuthResponse.fromJson(jsonDecode(response.body));
        await saveToken(data.accessToken, data.refreshToken);
        return data;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Lấy thông tin user hiện tại
  Future<User> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse(ApiService.getCurrentUserEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Làm mới token
  Future<String> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await http.post(
        Uri.parse(ApiService.refreshTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        await saveToken(newAccessToken, refreshToken);
        return newAccessToken;
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Quên mật khẩu
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.forgotPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Đặt lại mật khẩu
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.resetPasswordEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'new_password': newPassword}),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.put(
        Uri.parse(ApiService.changePasswordEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'old_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Xử lý lỗi
  Exception _handleError(http.Response response) {
    try {
      final errorBody = jsonDecode(response.body);
      if (errorBody is Map && errorBody.containsKey('detail')) {
        return Exception(errorBody['detail'].toString());
      }
    } catch (_) {}
    return Exception('Error: ${response.statusCode}');
  }
}
