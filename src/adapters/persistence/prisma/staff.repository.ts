import type { StaffRepository } from "@application/staff/ports/staff-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";

const STAFF_SELECT = {
  id: true,
  createdAt: true,
  isBillable: true,
  role: true,
  user: { select: { id: true, name: true, phone: true, email: true, status: true, createdAt: true, lastLoginAt: true } },
  salesmanPermission: { select: { canSell: true, canViewStock: true, canViewReports: true, canChangePrice: true, canCollectDue: true } },
} as const;

const SALE_SELECT = {
  id: true,
  invoiceNo: true,
  saleDate: true,
  totalAmount: true,
  discountAmount: true,
  taxAmount: true,
  chargeAmount: true,
  customerId: true,
  customer: { select: { name: true } },
  items: { select: { masterProductId: true, quantity: true, totalAmount: true, masterProduct: { select: { name: true } } } },
} as const;

function identifierWhere(shopId: string, variants: { userId: string; phone: string; cleanPhone: string; alternativePhone: string }) {
  return {
    shopId,
    role: "SALESMAN" as const,
    OR: [{ userId: variants.userId }, { user: { phone: variants.phone } }, { user: { phone: variants.cleanPhone } }, { user: { phone: variants.alternativePhone } }],
  };
}

export class PrismaStaffRepository implements StaffRepository {
  async findShopById(id: string) {
    return prisma.shop.findUnique({ where: { id }, select: { id: true, shopCode: true, shopName: true, status: true, ownerUserId: true } });
  }

  async findShopUserMember(shopId: string, userId: string) {
    return prisma.shopUser.findFirst({ where: { shopId, userId }, select: STAFF_SELECT }) as any;
  }

  async findSalesInRange(shopId: string, userId: string, start: Date, end: Date) {
    return prisma.customerSale.findMany({
      where: { shopId, createdByUserId: userId, saleDate: { gte: start, lt: end }, status: "ACTIVE" },
      select: SALE_SELECT,
    }) as any;
  }

  async countSales(shopId: string, userId: string): Promise<number> {
    return prisma.customerSale.count({ where: { shopId, createdByUserId: userId, status: "ACTIVE" } });
  }

  async findSalesmenForShop(shopId: string) {
    return prisma.shopUser.findMany({
      where: { shopId, role: "SALESMAN" },
      select: STAFF_SELECT,
      orderBy: [{ user: { status: "asc" } }, { createdAt: "desc" }],
    }) as any;
  }

  async findSalesmanByIdentifier(shopId: string, variants: any) {
    return prisma.shopUser.findFirst({ where: identifierWhere(shopId, variants), select: STAFF_SELECT }) as any;
  }

  async findSalesmanByIdentifierBasic(shopId: string, variants: any) {
    return prisma.shopUser.findFirst({ where: identifierWhere(shopId, variants), select: { id: true, userId: true } });
  }

  async findSimpleSalesInRange(shopId: string, userId: string, start: Date, end: Date) {
    return prisma.customerSale.findMany({
      where: { shopId, createdByUserId: userId, saleDate: { gte: start, lt: end }, status: "ACTIVE" },
      select: { id: true, totalAmount: true },
    });
  }

  async findRecentSaleActivity(shopId: string, userId: string, start: Date, end: Date, take: number) {
    return prisma.customerSale.findMany({
      where: { shopId, createdByUserId: userId, saleDate: { gte: start, lt: end }, status: "ACTIVE" },
      select: { id: true, invoiceNo: true, saleDate: true, totalAmount: true, customer: { select: { name: true } } },
      orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
      take,
    });
  }

  async upsertSalesmanPermissions(shopUserId: string, permissions: any): Promise<void> {
    await prisma.salesmanPermission.upsert({
      where: { shopUserId },
      update: permissions,
      create: { shopUserId, ...permissions },
    });
  }

  async findShopUserById(shopUserId: string) {
    return prisma.shopUser.findUnique({ where: { id: shopUserId }, select: STAFF_SELECT }) as any;
  }

  async upsertPinReset(userId: string): Promise<void> {
    await prisma.userPin.upsert({
      where: { userId },
      update: { status: "RESET_REQUIRED", failedAttempts: 0, lockedUntil: null, lastChangedAt: new Date() },
      create: { userId, pinHash: "", status: "RESET_REQUIRED" },
    });
  }

  async updateUserStatus(userId: string, status: string) {
    return prisma.user.update({
      where: { id: userId },
      data: { status: status as any },
      select: { id: true, name: true, phone: true, email: true, status: true, createdAt: true, lastLoginAt: true },
    });
  }
}
