import 'environment.dart';

abstract final class AppConfig {
  static const environmentName = String.fromEnvironment(
    'DOKAN_ENV',
    defaultValue: 'development',
  );
  static const apiEnabled = bool.fromEnvironment(
    'DOKAN_API_ENABLED',
    defaultValue: true,
  );
  static const apiBaseUrl = String.fromEnvironment(
    'DOKAN_API_BASE_URL',
    defaultValue: 'https://server.dokan.erp.sbmoffice.net',
  );
  static const syncRemoteDeletions = bool.fromEnvironment(
    'DOKAN_API_SYNC_DELETIONS',
    defaultValue: false,
  );
  static const seedEmptyRemoteCatalog = bool.fromEnvironment(
    'DOKAN_API_SEED_EMPTY_CATALOG',
    defaultValue: false,
  );
  static const connectTimeout = Duration(
    seconds: int.fromEnvironment(
      'DOKAN_API_CONNECT_TIMEOUT_SECONDS',
      defaultValue: 20,
    ),
  );
  static const receiveTimeout = Duration(
    seconds: int.fromEnvironment(
      'DOKAN_API_RECEIVE_TIMEOUT_SECONDS',
      defaultValue: 30,
    ),
  );

  static AppEnvironment get environment => switch (environmentName) {
        'production' => AppEnvironment.production,
        'staging' => AppEnvironment.staging,
        _ => AppEnvironment.development,
      };

  static bool get isApiConfigured =>
      apiEnabled &&
      Uri.tryParse(apiBaseUrl)?.hasScheme == true &&
      (apiBaseUrl.startsWith('https://') ||
          environment != AppEnvironment.production);
}
