import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_dependencies.dart';

class DokanCategoryNotifier extends Notifier<List<String>> {
  static const String uncategorized = 'অজানা';

  @override
  List<String> build() {
    final initial = <String>[
      'চাল-ডাল',
      'তেল-মসলা',
      'সাবান',
      'পানীয়',
      'বিস্কুট',
      uncategorized,
    ];
    Future.microtask(() async {
      try {
        final saved =
            await ref.read(productSettingsRepositoryProvider).loadCategories();
        if (saved != null && saved.isNotEmpty) state = saved;
        ref.read(productSyncErrorProvider.notifier).state = null;
      } catch (error) {
        ref.read(productSyncErrorProvider.notifier).state = error.toString();
      }
    });
    return initial;
  }

  void _persist() {
    unawaited(_saveCategories());
  }

  Future<void> _saveCategories() async {
    try {
      await ref.read(productSettingsRepositoryProvider).saveCategories(state);
      ref.read(productSyncErrorProvider.notifier).state = null;
    } catch (error) {
      ref.read(productSyncErrorProvider.notifier).state = error.toString();
    }
  }

  void addCategory(String category) {
    final value = category.trim();
    if (value.isEmpty) return;
    if (state.contains(value)) return;
    state = <String>[
      ...state.where((item) => item != uncategorized),
      value,
      uncategorized
    ];
    _persist();
  }

  void deleteCategory(String category) {
    if (category == uncategorized) return;
    state = state.where((item) => item != category).toList(growable: false);
    if (!state.contains(uncategorized)) {
      state = <String>[...state, uncategorized];
    }
    _persist();
  }

  void updateCategory(String oldCategory, String newCategory) {
    final value = newCategory.trim();
    if (value.isEmpty || oldCategory == uncategorized || oldCategory == value) {
      return;
    }
    if (state.contains(value)) return;
    final updated =
        state.map((item) => item == oldCategory ? value : item).toList();
    if (!updated.contains(uncategorized)) {
      updated.add(uncategorized);
    }
    state = updated;
    _persist();
  }
}

class DokanStockThresholdNotifier extends Notifier<int> {
  @override
  int build() {
    Future.microtask(() async {
      try {
        final saved = await ref
            .read(productSettingsRepositoryProvider)
            .loadStockThreshold();
        if (saved != null) state = saved.clamp(1, 99);
        ref.read(productSyncErrorProvider.notifier).state = null;
      } catch (error) {
        ref.read(productSyncErrorProvider.notifier).state = error.toString();
      }
    });
    return 5;
  }

  void setThreshold(int value) {
    state = value < 1
        ? 1
        : value > 99
            ? 99
            : value;
    unawaited(_saveThreshold());
  }

  Future<void> _saveThreshold() async {
    try {
      await ref
          .read(productSettingsRepositoryProvider)
          .saveStockThreshold(state);
      ref.read(productSyncErrorProvider.notifier).state = null;
    } catch (error) {
      ref.read(productSyncErrorProvider.notifier).state = error.toString();
    }
  }
}

final categoryProvider = NotifierProvider<DokanCategoryNotifier, List<String>>(
    DokanCategoryNotifier.new);
final stockThresholdProvider =
    NotifierProvider<DokanStockThresholdNotifier, int>(
        DokanStockThresholdNotifier.new);
