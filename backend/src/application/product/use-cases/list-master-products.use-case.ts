import { toProductResponse } from "@domain/product/product.entity";

import type { ProductRepository } from "../ports/product-repository.port";

export class ListMasterProductsUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute() {
    const [products, filters] = await Promise.all([this.productRepository.listMasterProducts(), this.productRepository.buildProductFilters()]);

    return {
      stats: {
        total: products.length,
        active: products.filter((item: any) => item.status === "ACTIVE").length,
        inactive: products.filter((item: any) => item.status === "INACTIVE").length,
        usingShops: 0,
      },
      filters,
      products: products.map(toProductResponse),
    };
  }
}
