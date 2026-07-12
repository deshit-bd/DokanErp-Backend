abstract final class JsonValue {
  static Object? first(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key) && json[key] != null) return json[key];
    }
    return null;
  }

  static String string(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    final value = first(json, keys);
    return value == null ? fallback : '$value';
  }

  static int integer(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    final value = first(json, keys);
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? fallback;
  }

  static double decimal(
    Map<String, dynamic> json,
    List<String> keys, {
    double fallback = 0,
  }) {
    final value = first(json, keys);
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? fallback;
  }

  static bool boolean(
    Map<String, dynamic> json,
    List<String> keys, {
    bool fallback = false,
  }) {
    final value = first(json, keys);
    if (value is bool) return value;
    if (value is num) return value != 0;
    return switch ('$value'.toLowerCase()) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => fallback,
    };
  }

  static DateTime dateTime(
    Map<String, dynamic> json,
    List<String> keys, {
    DateTime? fallback,
  }) {
    final value = first(json, keys);
    if (value is num) {
      final milliseconds =
          value.abs() < 100000000000 ? value.toInt() * 1000 : value.toInt();
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }
    return DateTime.tryParse('$value') ?? fallback ?? DateTime.now();
  }

  static List<Map<String, dynamic>> objectList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = first(json, keys);
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry('$key', value)))
        .toList(growable: false);
  }
}
