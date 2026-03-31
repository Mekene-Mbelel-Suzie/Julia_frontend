import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nurse_child_model.dart';
import '../models/vaccination_record_model.dart';
import '../services/auth_storage_service.dart';

class NurseService {
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

  Future<List<NurseChildModel>> getHospitalChildren() async {
    final response = await http.get(
      Uri.parse('$baseUrl/nurse/children/'),
      headers: await _headers(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (data as List).map((item) => NurseChildModel.fromJson(item)).toList();
    }

    throw Exception(_extractErrorMessage(data));
  }

  Future<List<VaccinationRecordModel>> getChildVaccinationRecords(int childId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/nurse/children/$childId/vaccination-records/'),
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

  Future<void> updateVaccinationRecord({
    required int recordId,
    required String status,
    String? scheduledDate,
    String? administeredDate,
    String? batchNumber,
    String? notes,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/nurse/vaccination-records/$recordId/'),
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        'scheduled_date': scheduledDate,
        'administered_date': administeredDate,
        'batch_number': batchNumber ?? '',
        'notes': notes ?? '',
      }),
    );

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (response.statusCode == 200) {
      return;
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