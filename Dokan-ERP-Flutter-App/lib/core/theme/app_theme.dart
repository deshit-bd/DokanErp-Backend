import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF00694C);
  static const primaryLight = Color(0xFF0C8C67);
  static const background = Color(0xFFF3F8F7);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF3D4943);
  static const border = Color(0xFFD9E6E2);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF49B1A);
  static const error = Color(0xFFB3261E);

  // Bottom Navigation & Side Menu Colors
  static const bottomNavBg = Color(0xFFEAF2F0);
  static const bottomNavBorder = Color(0xFFD7E5E0);
  static const bottomNavSelected = Color(0xFF00694C);
  static const bottomNavUnselected = Color(0xFF3D4943);
}

enum AppLanguage { bangla, english }

String tr(String bangla, String english) {
  return AppStrings.activeLanguage == AppLanguage.bangla ? bangla : english;
}

String trNum(int value) {
  if (AppStrings.activeLanguage == AppLanguage.english) {
    return value.toString();
  }
  const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return value.toString().split('').map((digit) {
    final index = int.tryParse(digit);
    return index == null ? digit : digits[index];
  }).join();
}

abstract final class AppStrings {
  static const appName = 'DokanERP';
  static const currencySymbol = '৳';

  static AppLanguage activeLanguage = AppLanguage.bangla;

  // Navigation Tabs Labels
  static String get tabHome =>
      activeLanguage == AppLanguage.bangla ? 'হোম' : 'Home';
  static String get tabSales =>
      activeLanguage == AppLanguage.bangla ? 'বিক্রয়' : 'Sales';
  static String get tabProducts =>
      activeLanguage == AppLanguage.bangla ? 'পণ্য' : 'Products';
  static String get tabReports =>
      activeLanguage == AppLanguage.bangla ? 'রিপোর্ট' : 'Reports';
  static String get tabMore =>
      activeLanguage == AppLanguage.bangla ? 'আরও' : 'More';
}

abstract final class AppSizes {
  static const sizeSplashTitle = 28.0;
  static const sizeHeader = 22.0;
  static const sizeSubHeader = 18.0;
  static const sizeBodyLarge = 16.0;
  static const sizeBodyMedium = 14.0;
  static const sizeBodySmall = 12.0;
  static const sizeCaption = 10.0;
}

extension ContextExtensions on BuildContext {
  // Theme shortcut
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  // Common Text Styles configured with context
  TextStyle get bodySmallStyle =>
      textTheme.bodySmall ?? const TextStyle(fontSize: 12);
  TextStyle get bodyMediumStyle =>
      textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
  TextStyle get bodyLargeStyle =>
      textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
  TextStyle get titleSmallStyle =>
      textTheme.titleSmall ??
      const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  TextStyle get titleMediumStyle =>
      textTheme.titleMedium ??
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  TextStyle get titleLargeStyle =>
      textTheme.titleLarge ??
      const TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  TextStyle get labelSmallStyle =>
      textTheme.labelSmall ?? const TextStyle(fontSize: 11);
  TextStyle get labelMediumStyle =>
      textTheme.labelMedium ?? const TextStyle(fontSize: 12);
  TextStyle get labelLargeStyle =>
      textTheme.labelLarge ?? const TextStyle(fontSize: 14);

  // Custom Font/Text sizes
  double get sizeSplashTitle => AppSizes.sizeSplashTitle;
  double get sizeHeader => AppSizes.sizeHeader;
  double get sizeSubHeader => AppSizes.sizeSubHeader;
  double get sizeBodyLarge => AppSizes.sizeBodyLarge;
  double get sizeBodyMedium => AppSizes.sizeBodyMedium;
  double get sizeBodySmall => AppSizes.sizeBodySmall;
  double get sizeCaption => AppSizes.sizeCaption;
}

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'HindSiliguri',
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(height: 1.45),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FB),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFE8EEFF),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'HindSiliguri',
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(height: 1.45),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        indicatorColor: Color(0xFF2C2C2C),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
