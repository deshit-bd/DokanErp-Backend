import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';

class ExpenseOfflineFirstRepository implements ExpenseRepository {
  const ExpenseOfflineFirstRepository(this._remote, this._local);

  final ExpenseRepository _remote;
  final ExpenseLocalDataSource _local;

  @override
  Future<List<DokanExpenseRecord>> loadExpenses() async {
    try {
      final values = await _remote.loadExpenses();
      await _local.save(values);
      return values;
    } catch (_) {
      return _local.load();
    }
  }

  @override
  Future<DokanExpenseRecord> createExpense(DokanExpenseRecord expense) async {
    final saved = await _remote.createExpense(expense);
    final current = await _local.load();
    await _local.save([
      saved,
      ...current.where((item) => item.id != saved.id),
    ]);
    return saved;
  }

  @override
  Future<DokanExpenseRecord> updateExpense(DokanExpenseRecord expense) async {
    final saved = await _remote.updateExpense(expense);
    final current = await _local.load();
    final index = current.indexWhere((item) => item.id == saved.id);
    if (index >= 0) {
      current[index] = saved;
    } else {
      current.insert(0, saved);
    }
    await _local.save(current);
    return saved;
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _remote.deleteExpense(id);
    final current = await _local.load();
    await _local.save(
      current.where((item) => item.id != id).toList(growable: false),
    );
  }
}
