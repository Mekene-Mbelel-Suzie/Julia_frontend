import 'admin_hospital_model.dart';
import 'admin_user_model.dart';

class AdminDashboardStatsModel {
  final int hospitalsCount;
  final int hospitalAdminsCount;
  final int nursesCount;
  final int parentsCount;
  final int childrenCount;
  final int vaccinesCount;
  final List<AdminHospitalModel> recentHospitals;
  final List<AdminUserModel> recentUsers;

  AdminDashboardStatsModel({
    required this.hospitalsCount,
    required this.hospitalAdminsCount,
    required this.nursesCount,
    required this.parentsCount,
    required this.childrenCount,
    required this.vaccinesCount,
    required this.recentHospitals,
    required this.recentUsers,
  });

  factory AdminDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStatsModel(
      hospitalsCount: json["hospitals_count"] ?? 0,
      hospitalAdminsCount: json["hospital_admins_count"] ?? 0,
      nursesCount: json["nurses_count"] ?? 0,
      parentsCount: json["parents_count"] ?? 0,
      childrenCount: json["children_count"] ?? 0,
      vaccinesCount: json["vaccines_count"] ?? 0,
      recentHospitals: (json["recent_hospitals"] as List? ?? [])
          .map((e) => AdminHospitalModel.fromJson(e))
          .toList(),
      recentUsers: (json["recent_users"] as List? ?? [])
          .map((e) => AdminUserModel.fromJson(e))
          .toList(),
    );
  }
}