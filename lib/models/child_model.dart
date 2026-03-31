class ChildModel {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String gender;
  final String dateOfBirth;
  final String? placeOfBirth;
  final String? bloodGroup;
  final String? birthWeightKg;
  final String? notes;
  final bool isActive;

  ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.bloodGroup,
    required this.birthWeightKg,
    required this.notes,
    required this.isActive,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json["id"],
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      fullName: json["full_name"] ?? "",
      gender: json["gender"] ?? "",
      dateOfBirth: json["date_of_birth"] ?? "",
      placeOfBirth: json["place_of_birth"],
      bloodGroup: json["blood_group"],
      birthWeightKg: json["birth_weight_kg"]?.toString(),
      notes: json["notes"],
      isActive: json["is_active"] ?? true,
    );
  }
}