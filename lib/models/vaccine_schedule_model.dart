import 'vaccine_model.dart';

class VaccineScheduleModel {
  final int id;
  final VaccineModel vaccine;
  final int doseNumber;
  final int recommendedAgeDays;
  final int? minAgeDays;
  final int? maxAgeDays;
  final String? notes;
  final bool isActive;

  VaccineScheduleModel({
    required this.id,
    required this.vaccine,
    required this.doseNumber,
    required this.recommendedAgeDays,
    required this.minAgeDays,
    required this.maxAgeDays,
    required this.notes,
    required this.isActive,
  });

  factory VaccineScheduleModel.fromJson(Map<String, dynamic> json) {
    return VaccineScheduleModel(
      id: json['id'],
      vaccine: VaccineModel.fromJson(json['vaccine']),
      doseNumber: json['dose_number'] ?? 1,
      recommendedAgeDays: json['recommended_age_days'] ?? 0,
      minAgeDays: json['min_age_days'],
      maxAgeDays: json['max_age_days'],
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
    );
  }
}