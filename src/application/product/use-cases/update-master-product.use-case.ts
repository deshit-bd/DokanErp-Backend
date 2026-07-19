import { toProductResponse } from "@domain/product/product.entity";
import {
  DuplicateBarcodeError,
  DuplicateSkuError,
  InvalidPriceError,
  InvalidSuggestedPriceError,
  ProductNameRequiredError,
  ProductNotFoundError,
  SkuRequiredError,
} from "@domain/product/product.errors";

import type { ProductPictureStoragePort } from "../ports/product-picture-storage.port";
import type { ProductRepository } from "../ports/product-repository.port";

export type UpdateMasterProductCommand = {
  productId: string;
  updatedByUserId: string;
  requestOrigin: string;
  body: {
    name?: string;
    sku?: string;
    price?: number | string | null;
    barcode?: string | null;
    suggestedPrice?: number | string | null;
    categoryId?: string | null;
    brandId?: string | null;
    unitId?: string | null;
    packageSize?: string | null;
    description?: string | null;
    pictureUrl?: string | null;
  };
};

export class UpdateMasterProductUseCase {
  constructor(
    private readonly productRepository: ProductRepository,
    private readonly pictureStorage: ProductPictureStoragePort,
  ) {}

  async execute(command: UpdateMasterProductCommand) {
    const { body, productId } = command;

    const existingProduct = await this.productRepository.findMasterProductById(productId);

    if (!existingProduct) {
      throw new ProductNotFoundError();
    }

    const name = body.name?.trim();
    const sku = body.sku?.trim();
    const barcode = body.barcode?.trim() || null;
    const categoryId = body.categoryId?.trim() || null;
    const brandId = body.brandId?.trim() || null;
    const unitId = body.unitId?.trim() || null;
    const packageSize = body.packageSize?.trim() || null;
    const description = body.description?.trim() || null;
    const rawPictureUrl = body.pictureUrl?.trim() || null;
    const parsedPrice = body.price === "" || body.price == null ? null : Number(body.price);
    const parsedSuggestedPrice = body.suggestedPrice === "" || body.suggestedPrice == null ? null : Number(body.suggestedPrice);

    if (!name) throw new ProductNameRequiredError();
    if (!sku) throw new SkuRequiredError();
    if (parsedPrice != null && Number.isNaN(parsedPrice)) throw new InvalidPriceError();
    if (parsedSuggestedPrice != null && Number.isNaN(parsedSuggestedPrice)) throw new InvalidSuggestedPriceError();

    const [existingSku, existingBarcode] = await Promise.all([
      this.productRepository.findMasterProductBySku(sku, productId),
      barcode ? this.productRepository.findBarcodeRecord(barcode, productId) : Promise.resolve(null),
    ]);

    if (existingSku) throw new DuplicateSkuError();
    if (existingBarcode) throw new DuplicateBarcodeError();

    const pictureUrl = rawPictureUrl ? await this.pictureStorage.store(rawPictureUrl, command.requestOrigin) : null;

    await this.productRepository.updateMasterProduct(productId, {
      name,
      sku,
      price: parsedPrice,
      suggestedPrice: parsedSuggestedPrice,
      categoryId,
      brandId,
      unitId,
      packageSize,
      description,
      pictureUrl,
      updatedByUserId: command.updatedByUserId,
    });

    await this.productRepository.syncProductBarcodeRecord({
      barcode,
      packageSize,
      productId,
      productStatus: existingProduct.status ?? "ACTIVE",
      userId: command.updatedByUserId,
    });

    const product = await this.productRepository.loadProductById(productId);

    return toProductResponse(product);
  }
}
