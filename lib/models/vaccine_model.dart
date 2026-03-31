class VaccineModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? diseasePrevented;
  final String category;
  final int numberOfDoses;
  final bool isActive;

  VaccineModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.diseasePrevented,
    required this.category,
    required this.numberOfDoses,
    required this.isActive,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      diseasePrevented: json['disease_prevented'],
      category: json['category'] ?? 'routine',
      numberOfDoses: json['number_of_doses'] ?? 1,
      isActive: json['is_active'] ?? true,
    );
  }
}