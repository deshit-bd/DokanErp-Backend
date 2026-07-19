import type { ProductTemplateStatus } from "@prisma/client";

import type { ProductTemplate } from "@domain/product-template/product-template.entity";
import { DuplicateTemplateFieldError, ProductTemplateNotFoundError, TemplateCodeRequiredError, TemplateNameRequiredError } from "@domain/product-template/product-template.errors";

import type { ProductTemplateRepository } from "../ports/product-template-repository.port";

export type UpdateProductTemplateCommand = {
  id: string;
  code: string | undefined;
  name: string | undefined;
  description: string | null | undefined;
  status: ProductTemplateStatus | undefined;
};

export class UpdateProductTemplateUseCase {
  constructor(private readonly productTemplateRepository: ProductTemplateRepository) {}

  async execute(command: UpdateProductTemplateCommand): Promise<ProductTemplate> {
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

    const existing = await this.productTemplateRepository.findRawById(command.id);

    if (!existing) {
      throw new ProductTemplateNotFoundError();
    }

    const duplicate = await this.productTemplateRepository.findDuplicate(code, name, command.id);

    if (duplicate) {
      throw new DuplicateTemplateFieldError(duplicate.code === code ? "code" : "name");
    }

    return this.productTemplateRepository.update(command.id, { code, name, description, status });
  }
}
