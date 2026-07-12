import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void debug(Object? message) {
    if (kDebugMode) {
      debugPrint(message?.toString());
    }
  }
}
