import type { InventoryRepository } from "../ports/inventory-repository.port";

export class GetGeneralStoreUseCase {
  constructor(private readonly inventoryRepository: InventoryRepository) {}

  async execute(shopId: string) {
    const products = await this.inventoryRepository.listGeneralStoreProducts(shopId);

    const mappedProducts = products.map((item) => {
      const stock = Number(item.openingStock ?? 0);
      const status = stock <= 0 ? "OUT" : stock <= 5 ? "LOW" : "IN_STOCK";

      return {
        id: item.id,
        masterProductId: item.masterProductId,
        name: item.masterProduct?.name,
        sku: item.masterProduct?.sku,
        packageSize: item.masterProduct?.packageSize ?? item.masterProduct?.sku,
        stock,
        salePrice: Number(item.salePrice ?? item.masterProduct?.suggestedPrice ?? item.masterProduct?.price ?? 0),
        status,
      };
    });

    return {
      store: { id: "main-store", name: "Main Store", mode: "GENERAL" },
      summary: {
        totalProducts: mappedProducts.length,
        lowStockProducts: mappedProducts.filter((item) => item.status === "LOW").length,
        outOfStockProducts: mappedProducts.filter((item) => item.status === "OUT").length,
      },
      products: mappedProducts,
    };
  }
}
