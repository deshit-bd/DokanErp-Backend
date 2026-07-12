class AppSettings {
  const AppSettings({
    this.localeCode = 'bn',
    this.darkMode = true,
  });

  final String localeCode;
  final bool darkMode;

  AppSettings copyWith({
    String? localeCode,
    bool? darkMode,
  }) {
    return AppSettings(
      localeCode: localeCode ?? this.localeCode,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
