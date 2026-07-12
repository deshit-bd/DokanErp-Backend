enum DokanExpenseTimeFilter { today, thisWeek, thisMonth, thisYear, all }

enum DokanExpenseStatus { paid, pending }

enum DokanExpensePaymentMethod { cash, bkash, nagad, bank }

class DokanExpenseRecord {
  const DokanExpenseRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
    this.receiptLabel = '',
    this.paymentMethod = DokanExpensePaymentMethod.cash,
    this.status = DokanExpenseStatus.paid,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String note;
  final String receiptLabel;
  final DokanExpensePaymentMethod paymentMethod;
  final DokanExpenseStatus status;

  DokanExpenseRecord copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? note,
    String? receiptLabel,
    DokanExpensePaymentMethod? paymentMethod,
    DokanExpenseStatus? status,
  }) {
    return DokanExpenseRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptLabel: receiptLabel ?? this.receiptLabel,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }
}

class ExpenseSummary {
  const ExpenseSummary({
    required this.totalAmount,
    required this.transactionCount,
    required this.topCategory,
    required this.topCategoryAmount,
    required this.previousAmount,
    required this.changePercent,
  });

  final double totalAmount;
  final int transactionCount;
  final String topCategory;
  final double topCategoryAmount;
  final double previousAmount;
  final double changePercent;

  int get totalExpense => totalAmount.round();
  double get totalExpenseAmount => totalAmount;
  int get totalTransactions => transactionCount;
}

class ExpenseCategoryStat {
  const ExpenseCategoryStat({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });

  final String category;
  final double totalAmount;
  final double percentage;

  int get percent => percentage.round();
  double get percentValue => percentage;
}

class ExpenseTrendPoint {
  const ExpenseTrendPoint({required this.label, required this.amount});

  final String label;
  final double amount;

  int get value => amount.round();
  double get amountValue => amount;
}

class ExpensePaymentMethodStat {
  const ExpensePaymentMethodStat({
    required this.method,
    required this.label,
    required this.amount,
    required this.percentage,
  });

  final String method;
  final String label;
  final double amount;
  final double percentage;
}
