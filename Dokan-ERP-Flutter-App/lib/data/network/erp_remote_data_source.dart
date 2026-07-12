import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_payload.dart';

class ErpRemoteDataSource {
  const ErpRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> dashboard() async {
    return ApiPayload.object(
      await _client.get(
        ApiEndpoints.dashboard,
        query: const {'range': 'today'},
      ),
    );
  }

  Future<Map<String, dynamic>> salesmanDashboard() async {
    return ApiPayload.object(
      await _client.get('${ApiEndpoints.dashboard}/salesman'),
    );
  }

  Future<List<Map<String, dynamic>>> dashboardActivity() async {
    return ApiPayload.list(
      await _client.get('${ApiEndpoints.dashboard}/activity'),
    );
  }

  Future<List<Map<String, dynamic>>> customers({String? search}) async {
    return ApiPayload.list(await _client.get(
      ApiEndpoints.customers,
      query: {if (search != null && search.isNotEmpty) 'search': search},
    ));
  }

  Future<List<Map<String, dynamic>>> staff() async {
    return ApiPayload.list(await _client.get(ApiEndpoints.staff));
  }

  Future<Map<String, dynamic>> report(
    String reportName, {
    Map<String, dynamic>? filters,
  }) async {
    return ApiPayload.object(
      await _client.get(
        _resolveReportPath(reportName),
        query: filters,
      ),
    );
  }

  Future<List<Map<String, dynamic>>> notifications() async {
    return ApiPayload.list(await _client.get(ApiEndpoints.notifications));
  }

  String _resolveReportPath(String reportName) {
    final normalized = reportName.trim().toLowerCase().replaceAll('_', '-');

    return switch (normalized) {
      'dashboard' => '${ApiEndpoints.reports}/dashboard',
      'sales-daily' || 'sales/daily' => '${ApiEndpoints.reports}/sales/daily',
      'purchases-summary' ||
      'purchases/summary' =>
        '${ApiEndpoints.reports}/purchases/summary',
      'dues-summary' ||
      'dues/summary' =>
        '${ApiEndpoints.reports}/dues/summary',
      'expenses-summary' ||
      'expenses/summary' =>
        '${ApiEndpoints.expenses}/summary',
      'profit-loss' || 'profit/loss' => '${ApiEndpoints.reports}/profit-loss',
      'stock-value' || 'stock/value' => '${ApiEndpoints.reports}/stock-value',
      'stock' => '${ApiEndpoints.reports}/stock',
      'receivables' || 'receivable' => '${ApiEndpoints.reports}/receivables',
      _ => '${ApiEndpoints.reports}/dashboard',
    };
  }
}
