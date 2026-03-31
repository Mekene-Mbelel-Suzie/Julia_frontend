class NurseDashboardRecordModel {
  final int id;
  final String childName;
  final String parentName;
  final String vaccineName;
  final String vaccineCode;
  final int doseNumber;
  final String status;
  final String dueDate;
  final String? scheduledDate;
  final String? administeredDate;
  final String hospitalName;
  final String? batchNumber;
  final String? notes;

  NurseDashboardRecordModel({
    required this.id,
    required this.childName,
    required this.parentName,
    required this.vaccineName,
    required this.vaccineCode,
    required this.doseNumber,
    required this.status,
    required this.dueDate,
    required this.scheduledDate,
    required this.administeredDate,
    required this.hospitalName,
    required this.batchNumber,
    required this.notes,
  });

  factory NurseDashboardRecordModel.fromJson(Map<String, dynamic> json) {
    return NurseDashboardRecordModel(
      id: json["id"],
      childName: json["child_name"] ?? "",
      parentName: json["parent_name"] ?? "",
      vaccineName: json["vaccine_name"] ?? "",
      vaccineCode: json["vaccine_code"] ?? "",
      doseNumber: json["dose_number"] ?? 0,
      status: json["status"] ?? "",
      dueDate: json["due_date"] ?? "",
      scheduledDate: json["scheduled_date"],
      administeredDate: json["administered_date"],
      hospitalName: json["hospital_name"] ?? "",
      batchNumber: json["batch_number"],
      notes: json["notes"],
    );
  }
}