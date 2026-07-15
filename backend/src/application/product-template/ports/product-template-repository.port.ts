import type { ProductTemplateStatus } from "@prisma/client";

import type { ProductTemplate } from "@domain/product-template/product-template.entity";

export type ProductTemplateInput = {
  code: string;
  name: string;
  description: string | null;
  status: ProductTemplateStatus;
};

export interface ProductTemplateRepository {
  findMany(): Promise<ProductTemplate[]>;
  findById(id: string): Promise<ProductTemplate | null>;
  findRawById(id: string): Promise<{ id: string } | null>;
  findDuplicate(code: string, name: string, excludeId?: string): Promise<{ id: string; code: string; name: string } | null>;
  create(input: ProductTemplateInput): Promise<ProductTemplate>;
  update(id: string, input: ProductTemplateInput): Promise<ProductTemplate>;
  delete(id: string): Promise<void>;
  countExistingMasterProducts(ids: string[]): Promise<number>;
  replaceProducts(templateId: string, masterProductIds: string[]): Promise<ProductTemplate>;
  removeProduct(templateId: string, masterProductId: string): Promise<ProductTemplate | null>;
}
