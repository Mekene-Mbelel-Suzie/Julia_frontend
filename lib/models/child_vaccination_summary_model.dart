class ChildVaccinationSummaryModel {
  final int total;
  final int pending;
  final int scheduled;
  final int given;
  final int missed;
  final int cancelled;
  final int overdue;

  ChildVaccinationSummaryModel({
    required this.total,
    required this.pending,
    required this.scheduled,
    required this.given,
    required this.missed,
    required this.cancelled,
    required this.overdue,
  });

  factory ChildVaccinationSummaryModel.fromJson(Map<String, dynamic> json) {
    return ChildVaccinationSummaryModel(
      total: json["total"] ?? 0,
      pending: json["pending"] ?? 0,
      scheduled: json["scheduled"] ?? 0,
      given: json["given"] ?? 0,
      missed: json["missed"] ?? 0,
      cancelled: json["cancelled"] ?? 0,
      overdue: json["overdue"] ?? 0,
    );
  }
}