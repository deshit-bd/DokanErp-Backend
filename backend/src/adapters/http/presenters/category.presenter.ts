import { toDisplayStatus, type Category } from "@domain/category/category.entity";

export function toCategoryDto(category: Category) {
  return {
    id: category.id,
    name: category.name,
    description: category.description,
    status: category.status,
    statusLabel: toDisplayStatus(category.status),
    isGlobal: category.isGlobal,
    isApproved: category.isApproved,
    shopId: category.shopId,
    products: category.productCount,
    createdAt: category.createdAt,
    updatedAt: category.updatedAt,
    createdBy: category.createdBy,
    updatedBy: category.updatedBy,
  };
}

// PATCH /:id historically omitted isGlobal/isApproved/shopId from the response;
// preserved here rather than silently widening the wire shape.
export function toCategoryUpdateDto(category: Category) {
  return {
    id: category.id,
    name: category.name,
    description: category.description,
    status: category.status,
    statusLabel: toDisplayStatus(category.status),
    products: category.productCount,
    createdAt: category.createdAt,
    updatedAt: category.updatedAt,
    createdBy: category.createdBy,
    updatedBy: category.updatedBy,
  };
}
