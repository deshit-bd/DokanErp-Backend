import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<List<DokanExpenseRecord>> loadExpenses();
  Future<DokanExpenseRecord> createExpense(DokanExpenseRecord expense);
  Future<DokanExpenseRecord> updateExpense(DokanExpenseRecord expense);
  Future<void> deleteExpense(String id);
}
