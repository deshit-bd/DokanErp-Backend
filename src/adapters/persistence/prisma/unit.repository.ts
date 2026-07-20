import type { Unit } from "@domain/unit/unit.entity";
import type {
  CreateUnitInput,
  UnitListScope,
  UnitRepository,
  UpdateUnitInput,
} from "@application/unit/ports/unit-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

export class PrismaUnitRepository implements UnitRepository {
  async findMany(scope: UnitListScope): Promise<Unit[]> {
    return prisma.unit.findMany({
      where: scope.isAdmin ? {} : { OR: [{ isGlobal: true }, { shopId: scope.shopId }] },
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
    });
  }

  async findById(id: string): Promise<Unit | null> {
    return prisma.unit.findUnique({ where: { id } });
  }

  async findByIdWithProductCount(id: string) {
    const record = await prisma.unit.findUnique({
      where: { id },
      include: { _count: { select: { masterProducts: true } } },
    });

    if (!record) {
      return null;
    }

    return { id: record.id, productCount: record._count.masterProducts };
  }

  async findDuplicateForCreate(name: string, shortName: string, scope: UnitListScope) {
    return prisma.unit.findFirst({
      where: {
        OR: scope.isAdmin
          ? [{ name, isGlobal: true }, { shortName, isGlobal: true }]
          : [
              { name, isGlobal: true },
              { name, shopId: scope.shopId },
              { shortName, isGlobal: true },
              { shortName, shopId: scope.shopId },
            ],
      },
      select: { id: true, name: true, shortName: true },
    });
  }

  async findDuplicateForUpdate(name: string, shortName: string, excludeId: string, scope: UnitListScope) {
    return prisma.unit.findFirst({
      where: {
        id: { not: excludeId },
        OR: scope.isAdmin
          ? [{ name, isGlobal: true }, { shortName, isGlobal: true }]
          : [
              { name, isGlobal: true },
              { name, shopId: scope.shopId },
              { shortName, isGlobal: true },
              { shortName, shopId: scope.shopId },
            ],
      },
      select: { id: true },
    });
  }

  async create(input: CreateUnitInput): Promise<Unit> {
    return prisma.unit.create({ data: input });
  }

  async update(id: string, input: UpdateUnitInput): Promise<Unit> {
    return prisma.unit.update({
      where: { id },
      data: {
        name: input.name,
        shortName: input.shortName,
        type: input.type,
        description: input.description,
        status: input.status,
      },
    });
  }

  async delete(id: string): Promise<void> {
    await prisma.unit.delete({ where: { id } });
  }

  async approve(id: string): Promise<Unit> {
    return prisma.unit.update({
      where: { id },
      data: { isGlobal: true, isApproved: true, shopId: null },
    });
  }
}
