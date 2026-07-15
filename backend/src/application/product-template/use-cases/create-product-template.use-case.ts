import type { ProductTemplateStatus } from "@prisma/client";

import type { ProductTemplate } from "@domain/product-template/product-template.entity";
import { DuplicateTemplateFieldError, TemplateCodeRequiredError, TemplateNameRequiredError } from "@domain/product-template/product-template.errors";

import type { ProductTemplateRepository } from "../ports/product-template-repository.port";

export type CreateProductTemplateCommand = {
  code: string | undefined;
  name: string | undefined;
  description: string | null | undefined;
  status: ProductTemplateStatus | undefined;
};

export class CreateProductTemplateUseCase {
  constructor(private readonly productTemplateRepository: ProductTemplateRepository) {}

  async execute(command: CreateProductTemplateCommand): Promise<ProductTemplate> {
    const code = command.code?.trim();
    const name = command.name?.trim();
    const description = command.description?.trim() || null;
    const status: ProductTemplateStatus = command.status ?? "ACTIVE";

    if (!code) {
      throw new TemplateCodeRequiredError();
    }
    if (!name) {
      throw new TemplateNameRequiredError();
    }

    const existing = await this.productTemplateRepository.findDuplicate(code, name);

    if (existing) {
      throw new DuplicateTemplateFieldError(existing.code === code ? "code" : "name");
    }

    return this.productTemplateRepository.create({ code, name, description, status });
  }
}
