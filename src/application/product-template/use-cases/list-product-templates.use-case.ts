import { computeProductTemplateStats, type ProductTemplate, type ProductTemplateStats } from "@domain/product-template/product-template.entity";

import type { ProductTemplateRepository } from "../ports/product-template-repository.port";

export class ListProductTemplatesUseCase {
  constructor(private readonly productTemplateRepository: ProductTemplateRepository) {}

  async execute(): Promise<{ templates: ProductTemplate[]; stats: ProductTemplateStats }> {
    const templates = await this.productTemplateRepository.findMany();
    return { templates, stats: computeProductTemplateStats(templates) };
  }
}
