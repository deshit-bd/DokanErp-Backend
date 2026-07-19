import { selectPrimaryBarcode } from "@domain/product/product.entity";
import { BarcodeNotAssignedError, ProductNotFoundError } from "@domain/product/product.errors";

import type { ProductRepository } from "../ports/product-repository.port";

export class GetBarcodeSvgUseCase {
  constructor(private readonly productRepository: ProductRepository) {}

  async execute(productId: string) {
    const product = await this.productRepository.loadProductById(productId);

    if (!product) {
      throw new ProductNotFoundError();
    }

    const primaryBarcode = selectPrimaryBarcode(product.barcodes);

    if (!primaryBarcode?.barcode) {
      throw new BarcodeNotAssignedError();
    }

    return { sku: product.sku, barcode: primaryBarcode.barcode };
  }
}
