import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000"; // change if needed

  // ======================
  // SIGNUP
  // ======================
  Future<http.Response> signup({
    required String fullName,
    required String phoneNumber,
    required String address,
    required String email,
    required String password,
    required String hospitalName,
  }) async {
    final url = Uri.parse("$baseUrl/accounts/signup/");

    final body = jsonEncode({
      "full_name": fullName,
      "phone_number": phoneNumber,
      "address": address,
      "email": email,
      "password": password,
      "hospital_name": hospitalName,
    });

    // ignore: avoid_print
    print("👉 SIGNUP URL: $url"); // debug print

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
  }

  // ======================
  // LOGIN
  // ======================
  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/accounts/login/");

    final body = jsonEncode({
      "email": email,
      "password": password,
    });

    // ignore: avoid_print
    print("👉 LOGIN URL: $url"); // debug print

    return await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
  }

  // ======================
  // PARENT DASHBOARD
  // ======================
  Future<Map<String, dynamic>> getParentDashboard() async {
    final url = Uri.parse("$baseUrl/accounts/dashboard/parent/");
    // ignore: avoid_print
    print("👉 PARENT DASHBOARD URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load parent dashboard");
    }
  }

  // ======================
  // HEALTHCARE DASHBOARD
  // ======================
  Future<Map<String, dynamic>> getHealthCareDashboard() async {
    final url = Uri.parse("$baseUrl/accounts/dashboard/healthcare/");
    // ignore: avoid_print
    print("👉 HEALTHCARE DASHBOARD URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load healthcare dashboard");
    }
  }

  // ======================
  // HOSPITAL DASHBOARD
  // ======================
  Future<Map<String, dynamic>> getHospitalDashboard() async {
    final url = Uri.parse("$baseUrl/accounts/dashboard/hospital/");
    // ignore: avoid_print
    print("👉 HOSPITAL DASHBOARD URL: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load hospital dashboard");
    }
  }
}