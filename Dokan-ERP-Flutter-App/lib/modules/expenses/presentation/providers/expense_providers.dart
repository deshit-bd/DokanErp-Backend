import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense_entry.dart';
import 'expense_provider.dart';

final expenseEntriesProvider = Provider<List<ExpenseEntry>>(
  (ref) =>
      ref
          .watch(expenseReportControllerProvider)
          .valueOrNull
          ?.map(_toExpenseEntry)
          .toList(growable: false) ??
      const <ExpenseEntry>[],
);

final monthlyExpenseTotalProvider = Provider<int>(
  (ref) =>
      ref
          .watch(expenseReportControllerProvider)
          .valueOrNull
          ?.fold<int>(0, (sum, entry) => sum + entry.amount.round()) ??
      0,
);

ExpenseEntry _toExpenseEntry(DokanExpenseRecord expense) {
  return ExpenseEntry(
    title: expense.title,
    category: expense.category,
    amount: expense.amount.round(),
    note: expense.note,
    dateLabel: expense.dateLabel,
  );
}
