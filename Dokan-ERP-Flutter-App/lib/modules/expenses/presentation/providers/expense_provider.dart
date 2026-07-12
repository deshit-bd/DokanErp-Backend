import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

export '../../domain/entities/expense.dart';

part 'parts/dokan_expense_time_filter.dart';
part 'parts/expense_time_filter_notifier.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (_) => throw UnimplementedError('Override expenseRepositoryProvider'),
);
