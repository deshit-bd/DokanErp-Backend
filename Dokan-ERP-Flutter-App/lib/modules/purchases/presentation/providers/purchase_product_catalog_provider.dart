import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/domain/entities/dokan_catalog_product.dart';

final purchaseProductCatalogProvider =
    FutureProvider.autoDispose<List<DokanCatalogProduct>>(
  (_) => throw UnimplementedError('Override purchaseProductCatalogProvider'),
);
