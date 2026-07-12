class ExpenseEntry {
  const ExpenseEntry({
    required this.title,
    required this.category,
    required this.amount,
    required this.note,
    required this.dateLabel,
  });

  final String title;
  final String category;
  final int amount;
  final String note;
  final String dateLabel;
}
