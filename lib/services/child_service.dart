import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child_model.dart';
import '../models/vaccination_record_model.dart';
import 'auth_storage_service.dart';
import '../models/child_vaccination_summary_model.dart';

class ChildService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  final AuthStorageService _storage = AuthStorageService();

  Future<ChildVaccinationSummaryModel> getVaccinationSummary(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/vaccination-summary/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ChildVaccinationSummaryModel.fromJson(data);
    }

    throw Exception(_extractErrorMessage(data));
  }


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

  Future<List<ChildModel>> getChildren() async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List).map((item) => ChildModel.fromJson(item)).toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<ChildModel> createChild({
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    String? placeOfBirth,
    String? bloodGroup,
    String? birthWeightKg,
    String? notes,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/'),
      headers: await _headers(),
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'place_of_birth': placeOfBirth ?? '',
        'blood_group': bloodGroup ?? '',
        'birth_weight_kg': birthWeightKg?.isEmpty == true ? null : birthWeightKg,
        'notes': notes ?? '',
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return ChildModel.fromJson(data['data']);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<ChildModel> updateChild({
    required int childId,
    required String firstName,
    required String lastName,
    required String gender,
    required String dateOfBirth,
    String? placeOfBirth,
    String? bloodGroup,
    String? birthWeightKg,
    String? notes,
    bool isActive = true,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/children/$childId/'),
      headers: await _headers(),
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'place_of_birth': placeOfBirth ?? '',
        'blood_group': bloodGroup ?? '',
        'birth_weight_kg': birthWeightKg?.isEmpty == true ? null : birthWeightKg,
        'notes': notes ?? '',
        'is_active': isActive,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ChildModel.fromJson(data['data']);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<void> deleteChild(int childId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/children/$childId/'),
      headers: await _headers(),
    );

    if (response.statusCode == 204) {
      return;
    }

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<ChildModel> getChildDetail(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ChildModel.fromJson(data);
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<void> generateVaccinationPlan(int childId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/children/$childId/generate-plan/'),
      headers: await _headers(),
    );

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<VaccinationRecordModel>> getVaccinationRecords(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/children/$childId/vaccination-records/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List)
          .map((item) => VaccinationRecordModel.fromJson(item))
          .toList();
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