class AdminUserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final Map<String, dynamic>? hospital;

  AdminUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.hospital,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json["id"],
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      fullName: json["full_name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"],
      role: json["role"] ?? "",
      isActive: json["is_active"] ?? true,
      hospital: json["hospital"],
    );
  }
}