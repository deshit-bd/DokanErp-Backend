import { toDisplayStatus, type Brand } from "@domain/brand/brand.entity";

export function toBrandDto(brand: Brand) {
  return {
    id: brand.id,
    name: brand.name,
    description: brand.description,
    logoUrl: brand.logoUrl,
    status: brand.status,
    statusLabel: toDisplayStatus(brand.status),
    categories: brand.categoryCount,
    products: brand.productCount,
    createdAt: brand.createdAt,
    updatedAt: brand.updatedAt,
    createdBy: brand.createdBy,
    updatedBy: brand.updatedBy,
  };
}
