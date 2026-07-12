import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_data_source.dart';
import '../mappers/expense_api_mapper.dart';

class ExpenseRemoteRepository implements ExpenseRepository {
  const ExpenseRemoteRepository(this._remote);

  final ExpenseRemoteDataSource _remote;

  @override
  Future<List<DokanExpenseRecord>> loadExpenses() async {
    final payload = await _remote.list(perPage: 100);
    return payload.map(ExpenseApiMapper.fromJson).toList(growable: false);
  }

  @override
  Future<DokanExpenseRecord> createExpense(
    DokanExpenseRecord expense,
  ) async {
    final payload = await _remote.create(ExpenseApiMapper.toJson(expense));
    return payload.isEmpty ? expense : ExpenseApiMapper.fromJson(payload);
  }

  @override
  Future<DokanExpenseRecord> updateExpense(
    DokanExpenseRecord expense,
  ) async {
    final payload = await _remote.update(
      expense.id,
      ExpenseApiMapper.toJson(expense),
    );
    return payload.isEmpty ? expense : ExpenseApiMapper.fromJson(payload);
  }

  @override
  Future<void> deleteExpense(String id) => _remote.delete(id);
}
