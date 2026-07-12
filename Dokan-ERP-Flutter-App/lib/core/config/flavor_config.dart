import 'environment.dart';

class FlavorConfig {
  const FlavorConfig({
    required this.environment,
    required this.baseUrl,
  });

  final AppEnvironment environment;
  final String baseUrl;
}
