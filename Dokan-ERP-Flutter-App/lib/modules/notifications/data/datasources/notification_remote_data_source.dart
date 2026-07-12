import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_payload.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> list({
    String? category,
    bool? unread,
  }) {
    return _client.get(
      ApiEndpoints.notifications,
      query: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (unread != null) 'unread': unread,
      },
    ).then(ApiPayload.list);
  }

  Future<int> unreadCount() async {
    final payload = ApiPayload.object(
      await _client.get('${ApiEndpoints.notifications}/unread-count'),
    );
    final value =
        payload['count'] ?? payload['unreadCount'] ?? payload['unread_count'];
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _client.patch('${ApiEndpoints.notification(id)}/read');
  }

  Future<void> markAllAsRead() async {
    await _client.post('${ApiEndpoints.notifications}/read-all');
  }

  Future<void> delete(String id) async {
    await _client.delete(ApiEndpoints.notification(id));
  }

  Future<Map<String, dynamic>> loadPreferences() async {
    final payload = await _client.get(ApiEndpoints.notificationPreferences);
    final data = ApiPayload.object(payload);
    final settings = data['settings'] is Map ? data['settings'] as Map<String, dynamic> : data;
    return {
      'events': {
        'low_stock': settings['lowStock'] ?? settings['low_stock'],
        'new_sale': settings['newSale'] ?? settings['new_sale'],
        'new_customer': settings['newCustomer'] ?? settings['new_customer'],
        'payment_received': settings['newSale'] ?? settings['new_sale'],
        'daily_report': settings['dailyReport'] ?? settings['daily_report'],
        'weekly_report': settings['weeklyReport'] ?? settings['weekly_report'],
        'staff_activity': true,
        'system_update': true,
      },
      'channels': {
        'push': settings['quietHours'] == false || settings['quiet_hours'] == false,
        'email': false,
        'sms': false,
        'sound': true,
        'vibration': true,
      }
    };
  }

  Future<Map<String, dynamic>> savePreferences(Map<String, dynamic> input) async {
    final events = input['events'] as Map<String, dynamic>? ?? {};
    final channels = input['channels'] as Map<String, dynamic>? ?? {};
    
    final payload = {
      'lowStock': events['low_stock'] ?? events['lowStockAlert'],
      'newSale': events['new_sale'],
      'newCustomer': events['new_customer'],
      'dailyReport': events['daily_report'],
      'weeklyReport': events['weekly_report'],
      'quietHours': channels['push'] == false,
    };

    final res = await _client.put(ApiEndpoints.notificationPreferences, body: payload);
    return ApiPayload.object(res);
  }

  Future<void> create({
    required String type,
    required String title,
    required String message,
  }) async {
    await _client.post(
      ApiEndpoints.notifications,
      body: {
        'type': type,
        'title': title,
        'message': message,
      },
    );
  }
}
