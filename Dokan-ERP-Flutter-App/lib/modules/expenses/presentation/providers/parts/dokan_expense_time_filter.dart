part of '../expense_provider.dart';

extension DokanExpensePresentation on DokanExpenseRecord {
  String get paymentMethodLabel => switch (paymentMethod) {
        DokanExpensePaymentMethod.cash => 'নগদ',
        DokanExpensePaymentMethod.bkash => 'bKash',
        DokanExpensePaymentMethod.nagad => 'Nagad',
        DokanExpensePaymentMethod.bank => 'ব্যাংক',
      };

  String get statusLabel => switch (status) {
        DokanExpenseStatus.paid => 'পরিশোধিত',
        DokanExpenseStatus.pending => 'বাকি',
      };

  Color get statusColor => switch (status) {
        DokanExpenseStatus.paid => const Color(0xFF14855C),
        DokanExpenseStatus.pending => const Color(0xFFD97706),
      };

  Color get categoryColor => switch (category) {
        'পণ্য ক্রয়' => const Color(0xFF14855C),
        'বিদ্যুৎ বিল' => const Color(0xFF0F766E),
        'গ্যাস বিল' => const Color(0xFFB45309),
        'ইন্টারনেট বিল' => const Color(0xFF2563EB),
        'কর্মচারীর বেতন' => const Color(0xFF7C3AED),
        'পরিবহন' => const Color(0xFFEA580C),
        'ভাড়া' => const Color(0xFFDB2777),
        'ট্যাক্স' => const Color(0xFFDC2626),
        'মেরামত' => const Color(0xFF0891B2),
        _ => const Color(0xFF3B82F6),
      };

  IconData get categoryIcon => switch (category) {
        'পণ্য ক্রয়' => Icons.shopping_bag_outlined,
        'বিদ্যুৎ বিল' => Icons.bolt_outlined,
        'গ্যাস বিল' => Icons.local_fire_department_outlined,
        'ইন্টারনেট বিল' => Icons.wifi_outlined,
        'কর্মচারীর বেতন' => Icons.groups_outlined,
        'পরিবহন' => Icons.local_shipping_outlined,
        'ভাড়া' => Icons.home_outlined,
        'ট্যাক্স' => Icons.receipt_long_outlined,
        'মেরামত' => Icons.build_outlined,
        _ => Icons.attach_money_outlined,
      };

  String get dateLabel {
    final hour = date.hour % 12 == 0 ? '12' : '${date.hour % 12}';
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} • $hour:$minute $suffix';
  }
}

class DokanExpenseController extends AsyncNotifier<List<DokanExpenseRecord>> {
  ExpenseRepository get _repository => ref.read(expenseRepositoryProvider);

  @override
  Future<List<DokanExpenseRecord>> build() async {
    const local = ExpenseLocalDataSource();
    final cached = await local.load();
    if (cached.isNotEmpty) {
      _fetchRemoteInBackground();
      return cached;
    }
    return _repository.loadExpenses();
  }

  Future<void> _fetchRemoteInBackground() async {
    try {
      final remote = await _repository.loadExpenses();
      state = AsyncData(remote);
    } catch (_) {}
  }

  Future<void> addExpense(DokanExpenseRecord expense) async {
    final saved = await _repository.createExpense(expense);
    final current = List<DokanExpenseRecord>.from(
      state.asData?.value ?? const <DokanExpenseRecord>[],
    );
    final updated = <DokanExpenseRecord>[saved, ...current]
      ..sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(updated);
  }

  Future<void> updateExpense(DokanExpenseRecord expense) async {
    final saved = await _repository.updateExpense(expense);
    final current = List<DokanExpenseRecord>.from(
      state.asData?.value ?? const <DokanExpenseRecord>[],
    );
    final index = current.indexWhere((item) => item.id == expense.id);
    if (index == -1) return;
    current[index] = saved;
    current.sort((a, b) => b.date.compareTo(a.date));
    state = AsyncData(current);
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    final current = state.asData?.value ?? const <DokanExpenseRecord>[];
    final updated =
        current.where((item) => item.id != id).toList(growable: false);
    state = AsyncData(updated);
  }
}
