import { buildBatchGroups, normalizeBatchOrder, toShopProductListItem } from "@domain/product/product.entity";

import type { ProductRepository } from "../ports/product-repository.port";

export class ListShopProductsUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(shopId: string, query: { page?: unknown; per_page?: unknown; search?: unknown; category?: unknown }) {
    const page = Number(query.page || 1);
    const perPage = Number(query.per_page || 500);
    const search = typeof query.search === "string" ? query.search.trim() : "";
    const category = typeof query.category === "string" ? query.category.trim() : "";

    const stockMethodRaw = await this.productRepository.findShopInventoryStockMethod(shopId);
    const stockMethod = normalizeBatchOrder(stockMethodRaw);

    const shopProducts = await this.productRepository.findShopProductsWithFilters(shopId, { page, perPage, search, category });

    const masterProductIds = shopProducts.map((item: any) => item.masterProductId).filter((value: string | null | undefined): value is string => Boolean(value));

    const inventoryBinItems = await this.productRepository.findInventoryBinItemsForProducts(shopId, masterProductIds);

    const batchesByProduct = new Map<string, ReturnType<typeof buildBatchGroups>>();
    for (const masterProductId of masterProductIds) {
      batchesByProduct.set(
        masterProductId,
        buildBatchGroups(
          inventoryBinItems.filter((item: any) => item.masterProductId === masterProductId),
          stockMethod,
        ),
      );
    }

    const mappedProducts = shopProducts.map((item: any) => {
      const batches = item.masterProductId ? (batchesByProduct.get(item.masterProductId) ?? []) : [];
      return toShopProductListItem(item, batches);
    });

    return { products: mappedProducts };
  }
}
