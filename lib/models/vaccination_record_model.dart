class VaccinationRecordModel {
  final int id;
  final String vaccineName;
  final String vaccineCode;
  final int doseNumber;
  final String status;
  final String dueDate;
  final String? scheduledDate;
  final String? administeredDate;
  final String? batchNumber;
  final String? notes;

  VaccinationRecordModel({
    required this.id,
    required this.vaccineName,
    required this.vaccineCode,
    required this.doseNumber,
    required this.status,
    required this.dueDate,
    required this.scheduledDate,
    required this.administeredDate,
    required this.batchNumber,
    required this.notes,
  });

  factory VaccinationRecordModel.fromJson(Map<String, dynamic> json) {
    final vaccine = json["vaccine"] ?? {};
    return VaccinationRecordModel(
      id: json["id"],
      vaccineName: vaccine["name"] ?? "",
      vaccineCode: vaccine["code"] ?? "",
      doseNumber: json["dose_number"] ?? 0,
      status: json["status"] ?? "",
      dueDate: json["due_date"] ?? "",
      scheduledDate: json["scheduled_date"],
      administeredDate: json["administered_date"],
      batchNumber: json["batch_number"],
      notes: json["notes"],
    );
  }
}