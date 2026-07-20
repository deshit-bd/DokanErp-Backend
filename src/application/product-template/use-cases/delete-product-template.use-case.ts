import { ProductTemplateNotFoundError } from "@domain/product-template/product-template.errors";

import type { ProductTemplateRepository } from "../ports/product-template-repository.port";

export class DeleteProductTemplateUseCase {
  constructor(private readonly productTemplateRepository: ProductTemplateRepository) {}

  async execute(id: string): Promise<void> {
    const existing = await this.productTemplateRepository.findRawById(id);

    if (!existing) {
      throw new ProductTemplateNotFoundError();
    }

    await this.productTemplateRepository.delete(id);
  }
}
