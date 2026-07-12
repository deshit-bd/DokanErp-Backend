abstract interface class ReportRepository {
  Future<Map<String, dynamic>> fetchReport(
    String type, {
    Map<String, dynamic>? filters,
  });
}
