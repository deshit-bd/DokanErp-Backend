import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/presentation/providers/supplier_providers.dart';
import '../../domain/entities/purchase_summary.dart';

final purchaseSummariesProvider = Provider<List<PurchaseSummary>>((ref) {
  final suppliers = ref.watch(supplierListProvider);
  return buildPurchaseSummaries(suppliers);
});

List<PurchaseSummary> buildPurchaseSummaries(List<Supplier> suppliers) {
  if (suppliers.isEmpty) {
    return const <PurchaseSummary>[];
  }

  String supplierName(int index) => suppliers[index % suppliers.length].name;

  return <PurchaseSummary>[
    PurchaseSummary(
      id: 'PO#0045',
      supplier: supplierName(0),
      amount: 'à§³ 28,500',
      items: '12 items',
      date: '22 May 2026',
      paid: true,
    ),
    PurchaseSummary(
      id: 'PO#0044',
      supplier: supplierName(1),
      amount: 'à§³ 15,200',
      items: '8 items',
      date: '20 May 2026',
      paid: true,
    ),
    PurchaseSummary(
      id: 'PO#0043',
      supplier: supplierName(2),
      amount: 'à§³ 9,750',
      items: '5 items',
      date: '18 May 2026',
      paid: false,
    ),
    PurchaseSummary(
      id: 'PO#0042',
      supplier: supplierName(3),
      amount: 'à§³ 32,000',
      items: '18 items',
      date: '15 May 2026',
      paid: true,
    ),
    PurchaseSummary(
      id: 'PO#0041',
      supplier: supplierName(4),
      amount: 'à§³ 7,400',
      items: '4 items',
      date: '10 May 2026',
      paid: false,
    ),
  ];
}
