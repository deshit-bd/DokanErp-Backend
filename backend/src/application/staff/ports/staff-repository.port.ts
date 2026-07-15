import type { SalesReportSale, StaffMemberRecord, StaffPermissions } from "@domain/staff/staff.entity";

export type SimpleSale = { id: string; totalAmount: unknown };
export type SaleActivity = { id: string; invoiceNo: string | null; saleDate: Date; totalAmount: unknown; customer: { name: string } | null };

export interface StaffRepository {
  findShopById(id: string): Promise<{ id: string; shopCode: string | null; shopName: string; status: string; ownerUserId: string | null } | null>;

  findShopUserMember(shopId: string, userId: string): Promise<(StaffMemberRecord & { role: string }) | null>;
  findSalesInRange(shopId: string, userId: string, start: Date, end: Date): Promise<SalesReportSale[]>;
  countSales(shopId: string, userId: string): Promise<number>;

  findSalesmenForShop(shopId: string): Promise<StaffMemberRecord[]>;
  findSalesmanByIdentifier(shopId: string, variants: { userId: string; phone: string; cleanPhone: string; alternativePhone: string }): Promise<(StaffMemberRecord & { isBillable?: boolean }) | null>;
  findSalesmanByIdentifierBasic(shopId: string, variants: { userId: string; phone: string; cleanPhone: string; alternativePhone: string }): Promise<{ id: string; userId: string } | null>;

  findSimpleSalesInRange(shopId: string, userId: string, start: Date, end: Date): Promise<SimpleSale[]>;
  findRecentSaleActivity(shopId: string, userId: string, start: Date, end: Date, take: number): Promise<SaleActivity[]>;

  upsertSalesmanPermissions(shopUserId: string, permissions: StaffPermissions): Promise<void>;
  findShopUserById(shopUserId: string): Promise<StaffMemberRecord | null>;

  upsertPinReset(userId: string): Promise<void>;
  updateUserStatus(userId: string, status: string): Promise<StaffMemberRecord["user"]>;
}
