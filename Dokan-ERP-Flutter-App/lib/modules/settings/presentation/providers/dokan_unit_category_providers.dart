import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dokan_erp/data/data.dart';
import 'package:dokan_erp/core/core.dart';

class DokanCategory {
  final String id;
  final String name;
  final String? description;

  DokanCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory DokanCategory.fromJson(Map<String, dynamic> json) {
    return DokanCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class DokanUnit {
  final String id;
  final String name;
  final String shortName;
  final String type;
  final String? description;

  DokanUnit({
    required this.id,
    required this.name,
    required this.shortName,
    required this.type,
    this.description,
  });

  factory DokanUnit.fromJson(Map<String, dynamic> json) {
    return DokanUnit(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shortName:
          json['shortName'] as String? ?? json['short_name'] as String? ?? '',
      type: json['type'] as String? ?? 'WEIGHT',
      description: json['description'] as String?,
    );
  }
}

class DokanCategoryListNotifier
    extends AutoDisposeAsyncNotifier<List<DokanCategory>> {
  @override
  FutureOr<List<DokanCategory>> build() async {
    return _fetch();
  }

  Future<List<DokanCategory>> _fetch() async {
    final client = ref.read(apiClientProvider);
    final response = await client.get(ApiEndpoints.categories);
    final data = response.data;
    if (data is Map) {
      final list = data['categories'] as List? ?? [];
      return list
          .map(
              (item) => DokanCategory.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  Future<void> addCategory(String name, String? description) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.categories, body: {
        'name': name,
        if (description != null) 'description': description,
      });
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCategory(
      String id, String name, String? description) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.patch(ApiEndpoints.category(id), body: {
        'name': name,
        'description': description,
      });
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.delete(ApiEndpoints.category(id));
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dokanCategoryListProvider = AsyncNotifierProvider.autoDispose<
    DokanCategoryListNotifier, List<DokanCategory>>(
  DokanCategoryListNotifier.new,
);

class DokanUnitListNotifier extends AutoDisposeAsyncNotifier<List<DokanUnit>> {
  @override
  FutureOr<List<DokanUnit>> build() async {
    return _fetch();
  }

  Future<List<DokanUnit>> _fetch() async {
    final client = ref.read(apiClientProvider);
    final response = await client.get(ApiEndpoints.units);
    final data = response.data;
    if (data is Map) {
      final list = data['units'] as List? ?? [];
      return list
          .map((item) => DokanUnit.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  Future<void> addUnit(
      String name, String shortName, String type, String? description) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.units, body: {
        'name': name,
        'shortName': shortName,
        'type': type,
        if (description != null) 'description': description,
      });
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUnit(String id, String name, String shortName, String type,
      String? description) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.patch('${ApiEndpoints.units}/$id', body: {
        'name': name,
        'shortName': shortName,
        'type': type,
        'description': description,
      });
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUnit(String id) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(apiClientProvider);
      await client.delete('${ApiEndpoints.units}/$id');
      state = AsyncValue.data(await _fetch());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final dokanUnitListProvider =
    AsyncNotifierProvider.autoDispose<DokanUnitListNotifier, List<DokanUnit>>(
  DokanUnitListNotifier.new,
);
