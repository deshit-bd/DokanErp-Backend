import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared legacy data and state folders are not used from lib', () {
    final libDirectory = Directory('lib');
    final violations = <String>[];

    for (final entity in libDirectory.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final path = entity.path.replaceAll('\\', '/');
      if (path.contains('/shared/data/') || path.contains('/shared/state/')) {
        violations.add(path);
      }

      final content = entity.readAsStringSync();
      if (content.contains('shared/data/supplier_store.dart') ||
          content.contains('shared/state/app_providers.dart')) {
        violations.add(path);
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('core feature modules expose clean architecture folders', () {
    const expectedFiles = <String>[
      'lib/modules/products/domain/entities/product.dart',
      'lib/modules/products/domain/repositories/product_repository.dart',
      'lib/modules/products/data/repositories/in_memory_product_repository.dart',
      'lib/modules/products/presentation/providers/product_providers.dart',
      'lib/modules/expenses/domain/entities/expense_entry.dart',
      'lib/modules/expenses/domain/repositories/expense_repository.dart',
      'lib/modules/expenses/data/repositories/in_memory_expense_repository.dart',
      'lib/modules/expenses/presentation/providers/expense_providers.dart',
      'lib/modules/salesman/domain/entities/salesman.dart',
      'lib/modules/salesman/domain/repositories/salesman_repository.dart',
      'lib/modules/salesman/data/repositories/in_memory_salesman_repository.dart',
      'lib/modules/salesman/presentation/providers/salesman_providers.dart',
      'lib/modules/sales/domain/entities/cart_line.dart',
      'lib/modules/sales/presentation/providers/sales_providers.dart',
    ];

    final missingFiles = expectedFiles
        .where((path) => !File(path).existsSync())
        .toList(growable: false);

    expect(missingFiles, isEmpty, reason: missingFiles.join('\n'));
  });
}
