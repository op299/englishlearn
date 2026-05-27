import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';
import '../models/auth_model.dart';

class AuthService {
  static const String sessionExpiredMessage =
      'Session expired. Please log in again.';

  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();
  static Stream<void> get sessionExpiredStream =>
      _sessionExpiredController.stream;

  final String baseUrl = ApiService.baseUrl;
  static Future<String?>? _refreshAccessTokenFuture;

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

  Future<Map<String, String>?> authenticatedHeaders() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      return _headersForAccessToken(token);
    }

    final newAccessToken = await _refreshAccessTokenOrNull();
    if (newAccessToken == null) return null;
    return _headersForAccessToken(newAccessToken);
  }

  Future<http.Response> sendAuthenticatedRequest(
    Future<http.Response> Function(Map<String, String> headers) send,
  ) async {
    final headers = await authenticatedHeaders();
    if (headers == null) {
      return _sessionExpiredResponse();
    }

    final response = await send(headers);
    if (response.statusCode != 401) {
      return response;
    }

    final newAccessToken = await _refreshAccessTokenOrNull();
    if (newAccessToken == null) {
      return _sessionExpiredResponse();
    }

    final retryResponse = await send(_headersForAccessToken(newAccessToken));
    if (retryResponse.statusCode == 401) {
      await _expireSession();
      return _sessionExpiredResponse();
    }

    return retryResponse;
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
      final response = await sendAuthenticatedRequest(
        (headers) => http.get(
          Uri.parse(ApiService.getCurrentUserEndpoint),
          headers: headers,
        ),
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
    final token = await _refreshAccessTokenOrNull();
    if (token == null) {
      throw Exception(sessionExpiredMessage);
    }
    return token;
  }

  Future<String?> _refreshAccessTokenOrNull() async {
    final inFlightRefresh = _refreshAccessTokenFuture;
    if (inFlightRefresh != null) {
      return await inFlightRefresh;
    }

    final refreshFuture = _refreshAccessToken();
    _refreshAccessTokenFuture = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_refreshAccessTokenFuture, refreshFuture)) {
        _refreshAccessTokenFuture = null;
      }
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _expireSession();
        return null;
      }

      final response = await http.post(
        Uri.parse(ApiService.refreshTokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data is Map
            ? data['access_token']?.toString()
            : null;
        if (newAccessToken == null || newAccessToken.isEmpty) {
          throw Exception('Invalid refresh token response');
        }
        await saveToken(newAccessToken, refreshToken);
        return newAccessToken;
      }

      if ([400, 401, 403].contains(response.statusCode)) {
        await _expireSession();
        return null;
      }

      throw _handleError(response);
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
      final response = await sendAuthenticatedRequest(
        (headers) => http.put(
          Uri.parse(ApiService.changePasswordEndpoint),
          headers: headers,
          body: jsonEncode({
            'old_password': currentPassword,
            'new_password': newPassword,
            'confirm_password': confirmPassword,
          }),
        ),
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

  Map<String, String> _headersForAccessToken(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _expireSession() async {
    await clearTokens();
    _sessionExpiredController.add(null);
  }

  http.Response _sessionExpiredResponse() {
    return http.Response(
      jsonEncode({'detail': sessionExpiredMessage}),
      401,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
