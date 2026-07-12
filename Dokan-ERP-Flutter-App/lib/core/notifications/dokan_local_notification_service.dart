import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules the daily "habit" reminders that pull a shopkeeper back into the
/// app every day: record sales in the morning, collect dues at midday, and
/// close the books in the evening. All local — no backend, no server push.
abstract final class DokanLocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'dokan_daily_reminders';

  static Future<void> initialize() async {
    if (kIsWeb || _initialized) return;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    } catch (_) {
      // Fall back to the device default timezone.
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  /// (Re)schedules the three daily reminders. Safe to call on every app start.
  static Future<void> scheduleDailyReminders() async {
    if (kIsWeb) return;
    if (!_initialized) await initialize();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'দৈনিক রিমাইন্ডার',
        channelDescription: 'বিক্রি, বকেয়া ও হিসাব বন্ধের রিমাইন্ডার',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _daily(1, 9, 0, '🌅 শুভ সকাল!',
        'আজকের বিক্রি অ্যাপে লিখে রাখুন — হিসাব সহজ থাকবে।', details);
    await _daily(2, 14, 0, '💰 বকেয়া সংগ্রহ করুন',
        'গ্রাহকের বাকি টাকা সংগ্রহের কথা মনে রাখুন।', details);
    await _daily(3, 20, 0, '🌙 আজকের হিসাব বন্ধ করুন',
        'আজ কত বিক্রি আর কত লাভ হলো — দেখে নিন।', details);
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<void> _daily(
    int id,
    int hour,
    int minute,
    String title,
    String body,
    NotificationDetails details,
  ) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOf(hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Scheduling can fail on unsupported platforms; ignore.
    }
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
