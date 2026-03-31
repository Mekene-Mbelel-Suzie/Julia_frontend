import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_user.dart';
import 'auth_storage_service.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  final AuthStorageService _storage = AuthStorageService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final payload = data['data'];
      final user = AppUser.fromJson(payload['user']);

      await _storage.saveSession(
        accessToken: payload['access'],
        refreshToken: payload['refresh'],
        user: user,
      );

      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<Map<String, dynamic>> parentSignup({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required int hospitalId,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/parent/signup/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'confirm_password': confirmPassword,
        'hospital_id': hospitalId,
        'address': address ?? '',
        'emergency_contact_name': emergencyContactName ?? '',
        'emergency_contact_phone': emergencyContactPhone ?? '',
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final payload = data['data'];
      final user = AppUser.fromJson(payload['user']);

      await _storage.saveSession(
        accessToken: payload['access'],
        refreshToken: payload['refresh'],
        user: user,
      );

      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<dynamic>> getHospitals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/hospitals/'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AppUser> getMe() async {
    final accessToken = await _storage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('No session found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final user = AppUser.fromJson(data);

      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _storage.saveSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );
      }

      return user;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AppUser?> getStoredUser() async {
    return _storage.getUser();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    final user = await _storage.getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  Future<void> logout() async {
    await _storage.clearSession();
  }

  String _extractErrorMessage(dynamic data) {
    if (data is String) return data;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('detail')) return data['detail'].toString();

      final firstEntry = data.entries.isNotEmpty ? data.entries.first : null;
      if (firstEntry != null) {
        final value = firstEntry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        }
        return value.toString();
      }
    }

    return 'An unexpected error occurred';
  }
}