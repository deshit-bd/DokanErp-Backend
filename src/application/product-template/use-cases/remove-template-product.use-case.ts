import type { ProductTemplate } from "@domain/product-template/product-template.entity";
import { ProductTemplateNotFoundError } from "@domain/product-template/product-template.errors";

import type { ProductTemplateRepository } from "../ports/product-template-repository.port";

export class RemoveTemplateProductUseCase {
  constructor(private readonly productTemplateRepository: ProductTemplateRepository) {}

  async execute(templateId: string, masterProductId: string): Promise<ProductTemplate> {
    const updated = await this.productTemplateRepository.removeProduct(templateId, masterProductId);

    if (!updated) {
      throw new ProductTemplateNotFoundError();
    }

    return updated;
  }
}
