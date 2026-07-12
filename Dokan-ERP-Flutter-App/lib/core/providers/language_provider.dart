import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier([AppLanguage initialLanguage = AppLanguage.bangla])
      : super(initialLanguage) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langString = prefs.getString('app_language') ?? 'bangla';
      final lang =
          langString == 'english' ? AppLanguage.english : AppLanguage.bangla;
      state = lang;
      AppStrings.activeLanguage = lang;
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    AppStrings.activeLanguage = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language',
          language == AppLanguage.english ? 'english' : 'bangla');
    } catch (_) {}
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
