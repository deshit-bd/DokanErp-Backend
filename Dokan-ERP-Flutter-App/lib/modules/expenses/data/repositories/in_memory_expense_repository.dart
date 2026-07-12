import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class InMemoryExpenseRepository implements ExpenseRepository {
  InMemoryExpenseRepository()
      : _entries = <DokanExpenseRecord>[
          DokanExpenseRecord(
            id: 'exp-1',
            title: 'Office rent',
            category: 'Facility',
            amount: 18000,
            date: DateTime.now().subtract(const Duration(days: 2)),
            note: 'Monthly office rent',
          ),
          DokanExpenseRecord(
            id: 'exp-2',
            title: 'Electricity bill',
            category: 'Utility',
            amount: 4200,
            date: DateTime.now().subtract(const Duration(days: 1)),
            note: 'Power bill',
          ),
          DokanExpenseRecord(
            id: 'exp-3',
            title: 'Marketing ad',
            category: 'Marketing',
            amount: 7500,
            date: DateTime.now().subtract(const Duration(hours: 5)),
            note: 'Campaign spend',
          ),
        ];

  final List<DokanExpenseRecord> _entries;

  @override
  Future<List<DokanExpenseRecord>> loadExpenses() async {
    return List<DokanExpenseRecord>.unmodifiable(_entries)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<DokanExpenseRecord> createExpense(DokanExpenseRecord expense) async {
    _entries.insert(0, expense);
    return expense;
  }

  @override
  Future<DokanExpenseRecord> updateExpense(DokanExpenseRecord expense) async {
    final index = _entries.indexWhere((item) => item.id == expense.id);
    if (index >= 0) {
      _entries[index] = expense;
    }
    return expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    _entries.removeWhere((item) => item.id == id);
  }
}
