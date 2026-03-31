class AppUser {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final Map<String, dynamic>? hospital;
  final Map<String, dynamic>? parentProfile;
  final Map<String, dynamic>? nurseProfile;
  final Map<String, dynamic>? hospitalAdminProfile;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.hospital,
    required this.parentProfile,
    required this.nurseProfile,
    required this.hospitalAdminProfile,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
      hospital: json['hospital'] != null
          ? Map<String, dynamic>.from(json['hospital'])
          : null,
      parentProfile: json['parent_profile'] != null
          ? Map<String, dynamic>.from(json['parent_profile'])
          : null,
      nurseProfile: json['nurse_profile'] != null
          ? Map<String, dynamic>.from(json['nurse_profile'])
          : null,
      hospitalAdminProfile: json['hospital_admin_profile'] != null
          ? Map<String, dynamic>.from(json['hospital_admin_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'hospital': hospital,
      'parent_profile': parentProfile,
      'nurse_profile': nurseProfile,
      'hospital_admin_profile': hospitalAdminProfile,
    };
  }
}