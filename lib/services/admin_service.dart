import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/admin_dashboard_stats_model.dart';
import '../models/admin_hospital_model.dart';
import '../models/admin_user_model.dart';
import '../models/vaccine_model.dart';
import '../models/vaccine_schedule_model.dart';
import 'auth_storage_service.dart';

class AdminService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final AuthStorageService _storage = AuthStorageService();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No access token found');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<AdminDashboardStatsModel> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AdminDashboardStatsModel.fromJson(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<AdminHospitalModel>> getHospitals({String? search}) async {
    final uri = Uri.parse('$baseUrl/admin/hospitals/').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );

    final response = await http.get(uri, headers: await _headers());
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List).map((e) => AdminHospitalModel.fromJson(e)).toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AdminHospitalModel> createHospital({
    required String name,
    String? address,
    String? city,
    String? phone,
    String? email,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/hospitals/'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'address': address ?? '',
        'city': city ?? '',
        'phone': phone ?? '',
        'email': email ?? '',
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return AdminHospitalModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AdminHospitalModel> updateHospital({
    required int hospitalId,
    required String name,
    String? address,
    String? city,
    String? phone,
    String? email,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/hospitals/$hospitalId/'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'address': address ?? '',
        'city': city ?? '',
        'phone': phone ?? '',
        'email': email ?? '',
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AdminHospitalModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<AdminUserModel>> getUsers({
    String? search,
    String? role,
    int? hospitalId,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/users/').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (role != null && role.isNotEmpty) 'role': role,
        if (hospitalId != null) 'hospital_id': hospitalId.toString(),
      },
    );

    final response = await http.get(uri, headers: await _headers());
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List).map((e) => AdminUserModel.fromJson(e)).toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AdminUserModel> createUser({
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    required String role,
    int? hospitalId,
    required String password,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users/'),
      headers: await _headers(),
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone ?? '',
        'role': role,
        'hospital_id': hospitalId,
        'password': password,
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return AdminUserModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<AdminUserModel> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    String? phone,
    required String role,
    int? hospitalId,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/users/$userId/'),
      headers: await _headers(),
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone ?? '',
        'role': role,
        'hospital_id': hospitalId,
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AdminUserModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<VaccineModel>> getVaccines() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/vaccines/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List).map((e) => VaccineModel.fromJson(e)).toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<VaccineModel> createVaccine({
    required String name,
    required String code,
    String? description,
    String? diseasePrevented,
    required String category,
    required int numberOfDoses,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/vaccines/'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'code': code,
        'description': description ?? '',
        'disease_prevented': diseasePrevented ?? '',
        'category': category,
        'number_of_doses': numberOfDoses,
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return VaccineModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<VaccineModel> updateVaccine({
    required int vaccineId,
    required String name,
    required String code,
    String? description,
    String? diseasePrevented,
    required String category,
    required int numberOfDoses,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/vaccines/$vaccineId/'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'code': code,
        'description': description ?? '',
        'disease_prevented': diseasePrevented ?? '',
        'category': category,
        'number_of_doses': numberOfDoses,
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return VaccineModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<VaccineScheduleModel>> getSchedules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/schedules/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List)
          .map((e) => VaccineScheduleModel.fromJson(e))
          .toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<VaccineScheduleModel> createSchedule({
    required int vaccineId,
    required int doseNumber,
    required int recommendedAgeDays,
    int? minAgeDays,
    int? maxAgeDays,
    String? notes,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/schedules/'),
      headers: await _headers(),
      body: jsonEncode({
        'vaccine_id': vaccineId,
        'dose_number': doseNumber,
        'recommended_age_days': recommendedAgeDays,
        'min_age_days': minAgeDays,
        'max_age_days': maxAgeDays,
        'notes': notes ?? '',
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return VaccineScheduleModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<VaccineScheduleModel> updateSchedule({
    required int scheduleId,
    required int vaccineId,
    required int doseNumber,
    required int recommendedAgeDays,
    int? minAgeDays,
    int? maxAgeDays,
    String? notes,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/schedules/$scheduleId/'),
      headers: await _headers(),
      body: jsonEncode({
        'vaccine_id': vaccineId,
        'dose_number': doseNumber,
        'recommended_age_days': recommendedAgeDays,
        'min_age_days': minAgeDays,
        'max_age_days': maxAgeDays,
        'notes': notes ?? '',
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return VaccineScheduleModel.fromJson(data["data"]);
    }

    throw Exception(_extractErrorMessage(data));
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