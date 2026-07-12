class PurchaseSummary {
  const PurchaseSummary({
    required this.id,
    required this.supplier,
    required this.amount,
    required this.items,
    required this.date,
    required this.paid,
  });

  final String id;
  final String supplier;
  final String amount;
  final String items;
  final String date;
  final bool paid;
}
