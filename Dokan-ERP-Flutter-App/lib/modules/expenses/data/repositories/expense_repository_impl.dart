import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._localDataSource);

  final ExpenseLocalDataSource _localDataSource;

  @override
  Future<List<DokanExpenseRecord>> loadExpenses() => _localDataSource.load();

  @override
  Future<DokanExpenseRecord> createExpense(DokanExpenseRecord expense) async {
    final current = await _localDataSource.load();
    await _localDataSource.save([expense, ...current]);
    return expense;
  }

  @override
  Future<DokanExpenseRecord> updateExpense(DokanExpenseRecord expense) async {
    final current = await _localDataSource.load();
    final index = current.indexWhere((item) => item.id == expense.id);
    if (index >= 0) current[index] = expense;
    await _localDataSource.save(current);
    return expense;
  }

  @override
  Future<void> deleteExpense(String id) async {
    final current = await _localDataSource.load();
    await _localDataSource.save(
      current.where((item) => item.id != id).toList(growable: false),
    );
  }
}
