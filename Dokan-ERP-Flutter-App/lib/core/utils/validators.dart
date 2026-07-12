abstract final class Validators {
  static String? required(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? phone(String? value) {
    final normalized = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (normalized.length != 11) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
