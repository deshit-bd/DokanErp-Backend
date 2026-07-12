import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/expense.dart';

class ExpenseLocalDataSource {
  const ExpenseLocalDataSource();

  static const String _storageKey = 'dokan_expense_records_v2';

  Future<List<DokanExpenseRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const <DokanExpenseRecord>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const <DokanExpenseRecord>[];

    final records = decoded
        .whereType<Map>()
        .map((item) => _fromJson(
              item.map((key, value) => MapEntry('$key', value)),
            ))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> save(List<DokanExpenseRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(records.map(_toJson).toList(growable: false)),
    );
  }

  Map<String, dynamic> _toJson(DokanExpenseRecord record) => {
        'id': record.id,
        'title': record.title,
        'category': record.category,
        'amount': record.amount,
        'date': record.date.toIso8601String(),
        'note': record.note,
        'receiptLabel': record.receiptLabel,
        'paymentMethod': record.paymentMethod.name,
        'status': record.status.name,
      };

  DokanExpenseRecord _fromJson(Map<String, dynamic> json) {
    return DokanExpenseRecord(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'অন্যান্য',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String? ?? '',
      receiptLabel: json['receiptLabel'] as String? ?? '',
      paymentMethod: DokanExpensePaymentMethod.values.firstWhere(
        (value) => value.name == json['paymentMethod'],
        orElse: () => DokanExpensePaymentMethod.cash,
      ),
      status: DokanExpenseStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => DokanExpenseStatus.paid,
      ),
    );
  }

  List<DokanExpenseRecord> _seedExpenses() {
    final now = DateTime.now();
    return [
      DokanExpenseRecord(
        id: 'exp-001',
        title: 'চাল ক্রয়',
        category: 'পণ্য ক্রয়',
        amount: 8200,
        date: now.subtract(const Duration(hours: 2)),
        note: 'দোকানের স্টক পূরণ',
      ),
      DokanExpenseRecord(
        id: 'exp-002',
        title: 'বিদ্যুৎ বিল পরিশোধ',
        category: 'বিদ্যুৎ বিল',
        amount: 1850,
        date: now.subtract(const Duration(days: 1, hours: 3)),
        note: 'মাসিক বিল',
        paymentMethod: DokanExpensePaymentMethod.bank,
      ),
      DokanExpenseRecord(
        id: 'exp-003',
        title: 'কর্মচারীর বেতন',
        category: 'কর্মচারীর বেতন',
        amount: 12500,
        date: now.subtract(const Duration(days: 2)),
        paymentMethod: DokanExpensePaymentMethod.bkash,
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }
}
