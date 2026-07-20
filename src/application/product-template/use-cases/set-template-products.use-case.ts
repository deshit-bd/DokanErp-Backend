import type { ProductTemplate } from "@domain/product-template/product-template.entity";
import { InvalidMasterProductsError, ProductTemplateNotFoundError } from "@domain/product-template/product-template.errors";

import type { ProductTemplateRepository } from "../ports/product-template-repository.port";

export class SetTemplateProductsUseCase {
  constructor(private readonly productTemplateRepository: ProductTemplateRepository) {}

  async execute(templateId: string, rawProductIds: string[] | undefined): Promise<ProductTemplate> {
    const productIds = Array.from(new Set((rawProductIds ?? []).map((value) => value.trim()).filter(Boolean)));

    const existing = await this.productTemplateRepository.findRawById(templateId);

    if (!existing) {
      throw new ProductTemplateNotFoundError();
    }

    if (productIds.length > 0) {
      const existingCount = await this.productTemplateRepository.countExistingMasterProducts(productIds);
      if (existingCount !== productIds.length) {
        throw new InvalidMasterProductsError();
      }
    }

    return this.productTemplateRepository.replaceProducts(templateId, productIds);
  }
}
