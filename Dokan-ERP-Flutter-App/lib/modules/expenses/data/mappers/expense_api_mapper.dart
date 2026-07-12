import '../../../../core/network/json_value.dart';
import '../../domain/entities/expense.dart';

abstract final class ExpenseApiMapper {
  static DokanExpenseRecord fromJson(Map<String, dynamic> json) {
    final rawDesc =
        JsonValue.string(json, const ['description', 'title', 'name']);
    final parts = rawDesc.split(' | ');
    final titleVal = parts.isNotEmpty ? parts[0] : '';
    final noteVal = parts.length > 1 ? parts.sublist(1).join(' | ') : '';
    final categoryVal =
        JsonValue.string(json, const ['category_name', 'category']);

    return DokanExpenseRecord(
      id: JsonValue.string(json, const ['id', 'uuid', 'client_id']),
      title: titleVal.trim().isNotEmpty ? titleVal : categoryVal,
      category: categoryVal,
      amount: JsonValue.decimal(json, const ['amount', 'total']),
      date: JsonValue.dateTime(
        json,
        const [
          'date',
          'expenseDate',
          'expense_date',
          'createdAt',
          'created_at'
        ],
      ),
      note: noteVal.isNotEmpty
          ? noteVal
          : JsonValue.string(json, const ['note', 'notes']),
      receiptLabel:
          JsonValue.string(json, const ['receipt_url', 'receiptLabel']),
      paymentMethod: _paymentMethod(
        JsonValue.string(json, const ['payment_method', 'paymentMethod']),
      ),
      status: JsonValue.string(json, const ['status']) == 'pending'
          ? DokanExpenseStatus.pending
          : DokanExpenseStatus.paid,
    );
  }

  static Map<String, dynamic> toJson(DokanExpenseRecord expense) {
    return {
      'client_id': expense.id,
      'title': expense.title,
      'category': expense.category,
      'amount': expense.amount,
      'date': expense.date.toUtc().toIso8601String(),
      'note': expense.note,
      if (expense.receiptLabel.isNotEmpty) 'receipt_url': expense.receiptLabel,
      'payment_method': expense.paymentMethod.name,
      'status': expense.status.name,
    };
  }

  static DokanExpensePaymentMethod _paymentMethod(String value) {
    return switch (value.toLowerCase()) {
      'bkash' => DokanExpensePaymentMethod.bkash,
      'nagad' => DokanExpensePaymentMethod.nagad,
      'bank' => DokanExpensePaymentMethod.bank,
      _ => DokanExpensePaymentMethod.cash,
    };
  }
}
