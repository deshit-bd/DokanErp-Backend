import { CategoryLogAction, type CategoryStatus } from "@prisma/client";

import type { Category } from "@domain/category/category.entity";
import type {
  CategoryListScope,
  CategoryRepository,
  CreateCategoryInput,
  ImportCategoryRow,
  UpdateCategoryInput,
} from "@application/category/ports/category-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const CATEGORY_INCLUDE = {
  _count: { select: { masterProducts: true } },
  createdBy: { select: { id: true, name: true } },
  updatedBy: { select: { id: true, name: true } },
} as const;

type PrismaCategoryWithMeta = {
  id: string;
  name: string;
  description: string | null;
  status: CategoryStatus;
  isGlobal: boolean;
  isApproved: boolean;
  shopId: string | null;
  createdAt: Date;
  updatedAt: Date;
  _count: { masterProducts: number };
  createdBy: { id: string; name: string } | null;
  updatedBy: { id: string; name: string } | null;
};

function toCategory(record: PrismaCategoryWithMeta): Category {
  return {
    id: record.id,
    name: record.name,
    description: record.description,
    status: record.status,
    isGlobal: record.isGlobal,
    isApproved: record.isApproved,
    shopId: record.shopId,
    productCount: record._count.masterProducts,
    createdAt: record.createdAt,
    updatedAt: record.updatedAt,
    createdBy: record.createdBy,
    updatedBy: record.updatedBy,
  };
}

export class PrismaCategoryRepository implements CategoryRepository {
  async findMany(scope: CategoryListScope): Promise<Category[]> {
    const records = await prisma.productCategory.findMany({
      where: scope.isAdmin
        ? {}
        : {
            OR: [{ isGlobal: true }, { shopId: scope.shopId }],
          },
      orderBy: { createdAt: "desc" },
      include: CATEGORY_INCLUDE,
    });

    return records.map(toCategory);
  }

  async findByNameInScope(name: string, scope: CategoryListScope): Promise<{ id: string } | null> {
    return prisma.productCategory.findFirst({
      where: {
        name,
        OR: scope.isAdmin ? [{ isGlobal: true }] : [{ isGlobal: true }, { shopId: scope.shopId }],
      },
      select: { id: true },
    });
  }

  async findByNameAnywhereExcept(name: string, excludeId: string): Promise<{ id: string } | null> {
    return prisma.productCategory.findFirst({
      where: { name, id: { not: excludeId } },
      select: { id: true },
    });
  }

  async findRawById(id: string) {
    return prisma.productCategory.findUnique({
      where: { id },
      select: { id: true, name: true, description: true, status: true },
    });
  }

  async findByIdWithProductCount(id: string) {
    const record = await prisma.productCategory.findUnique({
      where: { id },
      include: { _count: { select: { masterProducts: true } } },
    });

    if (!record) {
      return null;
    }

    return {
      id: record.id,
      name: record.name,
      status: record.status,
      productCount: record._count.masterProducts,
    };
  }

  async create(input: CreateCategoryInput, performedById: string): Promise<Category> {
    const record = await prisma.productCategory.create({
      data: {
        name: input.name,
        description: input.description,
        status: input.status,
        shopId: input.shopId,
        isGlobal: input.isGlobal,
        isApproved: input.isApproved,
        createdByUserId: input.createdByUserId,
        updatedByUserId: input.createdByUserId,
        logs: {
          create: {
            action: CategoryLogAction.CREATED,
            newData: {
              name: input.name,
              description: input.description,
              status: input.status,
              shopId: input.shopId,
              isGlobal: input.isGlobal,
              isApproved: input.isApproved,
            },
            performedById,
          },
        },
      },
      include: CATEGORY_INCLUDE,
    });

    return toCategory(record);
  }

  async update(
    id: string,
    previous: { name: string; description: string | null; status: CategoryStatus },
    input: UpdateCategoryInput,
  ): Promise<Category> {
    const action =
      previous.status !== input.status
        ? input.status === "ARCHIVED"
          ? CategoryLogAction.ARCHIVED
          : CategoryLogAction.STATUS_CHANGED
        : CategoryLogAction.UPDATED;

    const record = await prisma.productCategory.update({
      where: { id },
      data: {
        name: input.name,
        description: input.description,
        status: input.status,
        updatedByUserId: input.updatedByUserId,
        logs: {
          create: {
            action,
            oldData: {
              name: previous.name,
              description: previous.description,
              status: previous.status,
            },
            newData: {
              name: input.name,
              description: input.description,
              status: input.status,
            },
            performedById: input.updatedByUserId,
          },
        },
      },
      include: CATEGORY_INCLUDE,
    });

    return toCategory(record);
  }

  async archiveDueToExistingProducts(
    id: string,
    status: CategoryStatus,
    productCount: number,
    updatedByUserId: string,
  ): Promise<void> {
    await prisma.productCategory.update({
      where: { id },
      data: {
        status: "ARCHIVED",
        updatedByUserId,
        logs: {
          create: {
            action: CategoryLogAction.DELETE_BLOCKED,
            oldData: { status, productCount },
            newData: { status: "ARCHIVED", productCount },
            performedById: updatedByUserId,
          },
        },
      },
    });
  }

  async deleteWithLog(id: string, name: string, status: CategoryStatus, performedById: string): Promise<void> {
    // Matches the original route's behavior exactly: the log row is created
    // first, then the category is deleted. Because CategoryLog.category has
    // onDelete: Cascade, deleting the category also cascades away the log
    // entry just created here (a pre-existing quirk, not introduced by this
    // migration — preserved as-is rather than silently fixed).
    await prisma.categoryLog.create({
      data: {
        categoryId: id,
        action: CategoryLogAction.ARCHIVED,
        oldData: { name, status },
        newData: { deleted: true },
        performedById,
      },
    });

    await prisma.productCategory.delete({ where: { id } });
  }

  async approve(id: string, updatedByUserId: string): Promise<Category> {
    const record = await prisma.productCategory.update({
      where: { id },
      data: {
        isGlobal: true,
        isApproved: true,
        shopId: null,
        updatedByUserId,
      },
      include: CATEGORY_INCLUDE,
    });

    return toCategory(record);
  }

  async findExistingGlobalNames(): Promise<Set<string>> {
    const records = await prisma.productCategory.findMany({
      where: { isGlobal: true },
      select: { name: true },
    });

    return new Set(records.map((item) => item.name.toLocaleLowerCase("en-US")));
  }

  async bulkCreateGlobal(rows: ImportCategoryRow[], performedById: string): Promise<number> {
    const created = await prisma.$transaction(
      rows.map((row) =>
        prisma.productCategory.create({
          data: {
            name: row.name,
            description: row.description,
            status: row.status,
            shopId: null,
            isGlobal: true,
            isApproved: true,
            createdByUserId: performedById,
            updatedByUserId: performedById,
            logs: {
              create: {
                action: CategoryLogAction.CREATED,
                newData: {
                  name: row.name,
                  description: row.description,
                  status: row.status,
                  shopId: null,
                  isGlobal: true,
                  isApproved: true,
                  source: "excel-import",
                },
                performedById,
              },
            },
          },
        }),
      ),
    );

    return created.length;
  }
}
