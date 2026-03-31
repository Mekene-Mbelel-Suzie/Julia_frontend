class AdminHospitalModel {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final bool isActive;
  final int usersCount;

  AdminHospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    required this.isActive,
    required this.usersCount,
  });

  factory AdminHospitalModel.fromJson(Map<String, dynamic> json) {
    return AdminHospitalModel(
      id: json["id"],
      name: json["name"] ?? "",
      address: json["address"],
      city: json["city"],
      phone: json["phone"],
      email: json["email"],
      isActive: json["is_active"] ?? true,
      usersCount: json["users_count"] ?? 0,
    );
  }
}