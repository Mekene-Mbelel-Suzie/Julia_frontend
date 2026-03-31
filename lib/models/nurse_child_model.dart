class NurseChildModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final String dateOfBirth;
  final bool isActive;
  final String? parentName;

  NurseChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.isActive,
    required this.parentName,
  });

  factory NurseChildModel.fromJson(Map<String, dynamic> json) {
    return NurseChildModel(
      id: json["id"],
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      fullName: json["full_name"] ?? "",
      gender: json["gender"] ?? "",
      dateOfBirth: json["date_of_birth"] ?? "",
      isActive: json["is_active"] ?? true,
      parentName: json["parent_name"],
    );
  }
}