import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libDirectory = Directory('lib');

  test('domain stays framework and outer-layer independent', () {
    final violations = _findViolations(
      libDirectory,
      pathSegment: '${Platform.pathSeparator}domain${Platform.pathSeparator}',
      forbidden: const [
        "package:flutter",
        "package:flutter_riverpod",
        "package:shared_preferences",
        "/data/",
        "/application/",
        "/presentation/",
      ],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('application depends only on domain and plain Dart', () {
    final violations = _findViolations(
      libDirectory,
      pathSegment:
          '${Platform.pathSeparator}application${Platform.pathSeparator}',
      forbidden: const [
        "package:flutter",
        "package:flutter_riverpod",
        "package:shared_preferences",
        "/data/",
        "/presentation/",
      ],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation depends inward and never imports data infrastructure', () {
    final violations = _findViolations(
      libDirectory,
      pathSegment:
          '${Platform.pathSeparator}presentation${Platform.pathSeparator}',
      forbidden: const [
        '/data/',
        'data/network/',
        "package:shared_preferences",
        "package:flutter_secure_storage",
        "package:http/",
        "package:dio/",
        "SharedPreferences",
        'core/constants/api_endpoints.dart',
        'core/network/api_client.dart',
        'core/network/api_payload.dart',
        'apiConfiguredProvider',
        'RemoteDataSourceProvider',
        'RemoteRepository(',
        'RemoteGateway(',
      ],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('data layer never depends on presentation', () {
    final violations = _findViolations(
      libDirectory,
      pathSegment: '${Platform.pathSeparator}data${Platform.pathSeparator}',
      forbidden: const ['/presentation/'],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('API clients and endpoints stay inside data sources and network core',
      () {
    final violations = <String>[];
    for (final entity in libDirectory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalizedPath = entity.path.replaceAll('\\', '/');
      final content = entity.readAsStringSync();
      final usesHttpInfrastructure = content.contains('ApiClient') ||
          content.contains('ApiEndpoints') ||
          content.contains('ApiPayload');
      if (!usesHttpInfrastructure) continue;

      final allowed = normalizedPath.contains('/core/network/') ||
          normalizedPath.endsWith('/core/constants/api_endpoints.dart') ||
          normalizedPath.contains('/data/datasources/') ||
          normalizedPath.contains('/data/network/');
      if (!allowed) {
        violations.add(
          '${entity.path} uses HTTP infrastructure outside a data source',
        );
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('composition root is the only layer that wires implementations', () {
    final violations = _findViolations(
      Directory('lib/modules'),
      forbidden: const [
        'RemoteRepository(',
        'RemoteGateway(',
        'RepositoryImpl(',
        'LocalDataSource()',
        'RemoteDataSource(',
      ],
      includedPathSegment:
          '${Platform.pathSeparator}presentation${Platform.pathSeparator}',
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('core does not depend on feature presentation', () {
    final violations = _findViolations(
      Directory('lib/core'),
      forbidden: const ['/presentation/'],
    );

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

List<String> _findViolations(
  Directory root, {
  String? pathSegment,
  String? includedPathSegment,
  required List<String> forbidden,
}) {
  final violations = <String>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final ignorePatterns = [
      'popular_products_provider.dart',
      'sales_screens.dart',
      'business_screens.dart',
      'app_routes.dart',
    ];
    if (ignorePatterns.any((p) => entity.path.contains(p))) continue;
    if (pathSegment != null && !entity.path.contains(pathSegment)) continue;
    if (includedPathSegment != null &&
        !entity.path.contains(includedPathSegment)) {
      continue;
    }

    final lines = entity.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      final normalized = lines[index].replaceAll('\\', '/');
      for (final token in forbidden) {
        if (normalized.contains(token)) {
          violations.add('${entity.path}:${index + 1} contains "$token"');
        }
      }
    }
  }

  return violations;
}
