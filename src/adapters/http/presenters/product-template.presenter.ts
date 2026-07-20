import { toDisplayStatus, type ProductTemplate } from "@domain/product-template/product-template.entity";

export function toProductTemplateDto(template: ProductTemplate) {
  return {
    id: template.id,
    code: template.code,
    name: template.name,
    description: template.description,
    status: template.status,
    statusLabel: toDisplayStatus(template.status),
    productCount: template.products.length,
    products: template.products,
    createdAt: template.createdAt,
    updatedAt: template.updatedAt,
  };
}
