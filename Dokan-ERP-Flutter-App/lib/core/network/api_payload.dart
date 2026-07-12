import 'api_response.dart';

abstract final class ApiPayload {
  static Map<String, dynamic> object(
      ApiResponse<Map<String, dynamic>> response) {
    if (response.data['queued'] == true) return const {};
    final nested = response.data['data'];
    return nested is Map ? _stringMap(nested) : response.data;
  }

  static List<Map<String, dynamic>> list(
    ApiResponse<Map<String, dynamic>> response,
  ) {
    final value = _listValue(response.data);
    if (value is! List) return const [];
    return value.whereType<Map>().map(_stringMap).toList(growable: false);
  }

  static Object? _listValue(Map<String, dynamic> payload) {
    const listKeys = [
      'items',
      'results',
      'products',
      'orders',
      'sales',
      'expenses',
      'customers',
      'suppliers',
      'staff',
      'salesmen',
      'notifications',
      'zones',
      'racks',
      'shelves',
      'bins',
      'invoices',
      'payments',
    ];

    final data = payload['data'];
    if (data is List) return data;
    if (data is Map) {
      final nested = _stringMap(data);
      for (final key in listKeys) {
        final value = nested[key];
        if (value is List) return value;
      }
    }
    for (final key in listKeys) {
      final value = payload[key];
      if (value is List) return value;
    }
    return null;
  }

  static Map<String, dynamic> _stringMap(Map<dynamic, dynamic> value) {
    return value.map((key, item) => MapEntry('$key', item));
  }
}
