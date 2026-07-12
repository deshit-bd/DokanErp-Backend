import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/language_provider.dart';
import 'core/notifications/dokan_local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final langString = prefs.getString('app_language') ?? 'bangla';
  final initialLanguage =
      langString == 'english' ? AppLanguage.english : AppLanguage.bangla;
  AppStrings.activeLanguage = initialLanguage;

  // Schedule the daily habit reminders (morning sales, midday dues, evening
  // close). Fire-and-forget so it never blocks startup.
  DokanLocalNotificationService.scheduleDailyReminders();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(
    DokanErpApp(
      overrides: [
        languageProvider
            .overrideWith((ref) => LanguageNotifier(initialLanguage)),
      ],
    ),
  );
}
