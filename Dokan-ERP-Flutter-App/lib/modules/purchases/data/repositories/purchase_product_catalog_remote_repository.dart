import '../../../../data/network/remote_data_sources.dart';
import '../../../products/data/mappers/product_api_mapper.dart';
import '../../../products/domain/entities/dokan_catalog_product.dart';
import '../../domain/repositories/purchase_product_catalog_repository.dart';

class PurchaseProductCatalogRemoteRepository
    implements PurchaseProductCatalogRepository {
  const PurchaseProductCatalogRemoteRepository(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<List<DokanCatalogProduct>> loadProducts() async {
    final payload = await _remote.shopCatalog();
    return payload
        .map(ProductApiMapper.fromJson)
        .where((product) => product.name.trim().isNotEmpty)
        .toList(growable: false);
  }
}
