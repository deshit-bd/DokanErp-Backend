import type { UserStatus } from "@prisma/client";

export type StaffPermissions = {
  canSell: boolean;
  canViewStock: boolean;
  canViewReports: boolean;
  canChangePrice: boolean;
  canCollectDue: boolean;
};

export type StaffMemberRecord = {
  id: string;
  createdAt: Date;
  isBillable?: boolean;
  user: { id: string; name: string; phone: string | null; email: string | null; status: UserStatus; createdAt: Date; lastLoginAt: Date | null };
  salesmanPermission: StaffPermissions | null;
};

export type StaffMember = {
  id: string;
  shopUserId: string;
  name: string;
  mobile: string | null;
  email: string | null;
  status: UserStatus;
  isActive: boolean;
  joinedAt: Date;
  createdAt: Date;
  lastLoginAt: Date | null;
  permissions: StaffPermissions;
};

export type StaffSummary = { total: number; active: number; inactive: number; canSell: number; canCollectDue: number };

export function mapStaffMember(member: StaffMemberRecord): StaffMember {
  return {
    id: member.user.id,
    shopUserId: member.id,
    name: member.user.name,
    mobile: member.user.phone,
    email: member.user.email,
    status: member.user.status,
    isActive: member.user.status === "ACTIVE",
    joinedAt: member.createdAt,
    createdAt: member.user.createdAt,
    lastLoginAt: member.user.lastLoginAt,
    permissions: {
      canSell: member.salesmanPermission?.canSell ?? false,
      canViewStock: member.salesmanPermission?.canViewStock ?? false,
      canViewReports: member.salesmanPermission?.canViewReports ?? false,
      canChangePrice: member.salesmanPermission?.canChangePrice ?? false,
      canCollectDue: member.salesmanPermission?.canCollectDue ?? false,
    },
  };
}

export function buildStaffSummary(staff: StaffMember[]): StaffSummary {
  return {
    total: staff.length,
    active: staff.filter((item) => item.isActive).length,
    inactive: staff.filter((item) => !item.isActive).length,
    canSell: staff.filter((item) => item.permissions.canSell).length,
    canCollectDue: staff.filter((item) => item.permissions.canCollectDue).length,
  };
}

/** Matches phone-number-or-userId lookups tolerant of a "+88" country-code prefix, used across staff lookup endpoints. */
export function buildStaffIdentifierVariants(staffUserId: string): { userId: string; phone: string; cleanPhone: string; alternativePhone: string } {
  const cleanPhone = staffUserId.startsWith("+88") ? staffUserId.slice(3) : staffUserId;
  const alternativePhone = staffUserId.startsWith("+88") ? staffUserId : `+88${staffUserId}`;
  return { userId: staffUserId, phone: staffUserId, cleanPhone, alternativePhone };
}

export function getDayRange(source = new Date()): { start: Date; end: Date } {
  const start = new Date(source);
  start.setHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return { start, end };
}

export function getMonthRange(source = new Date()): { start: Date; end: Date } {
  const start = new Date(source.getFullYear(), source.getMonth(), 1);
  const end = new Date(source.getFullYear(), source.getMonth() + 1, 1);
  return { start, end };
}

export function getWeekRange(source = new Date()): { start: Date; end: Date } {
  const start = new Date(source);
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - 6);
  const nextDay = new Date(source);
  nextDay.setHours(0, 0, 0, 0);
  nextDay.setDate(nextDay.getDate() + 1);
  return { start, end: nextDay };
}

export type SalesReportSale = {
  id: string;
  invoiceNo: string | null;
  saleDate: Date;
  totalAmount: unknown;
  discountAmount: unknown;
  taxAmount: unknown;
  chargeAmount: unknown;
  customerId: string;
  customer: { name: string } | null;
  items: Array<{ masterProductId: string; quantity: unknown; totalAmount: unknown; masterProduct: { name: string } | null }>;
};

export function toNumber(value: unknown): number {
  return Number(value ?? 0);
}

export function getNetSaleAmount(sale: Pick<SalesReportSale, "totalAmount" | "discountAmount" | "taxAmount" | "chargeAmount">): number {
  return Number((toNumber(sale.totalAmount) - toNumber(sale.discountAmount) + toNumber(sale.taxAmount) + toNumber(sale.chargeAmount)).toFixed(2));
}

export function summarizeSales(sales: SalesReportSale[]) {
  const customerCount = new Set(sales.map((sale) => sale.customerId).filter(Boolean)).size;
  const totalQty = Number(
    sales.reduce((sum, sale) => sum + sale.items.reduce((itemSum, item) => itemSum + toNumber(item.quantity), 0), 0).toFixed(3),
  );
  const orderedSales = sales.slice().sort((a, b) => a.saleDate.getTime() - b.saleDate.getTime());
  const firstSaleAt = orderedSales[0]?.saleDate ?? null;
  const lastSaleAt = orderedSales[orderedSales.length - 1]?.saleDate ?? null;

  return {
    totalSalesAmount: Number(sales.reduce((sum, sale) => sum + getNetSaleAmount(sale), 0).toFixed(2)),
    salesCount: sales.length,
    totalQty,
    customerCount,
    firstSaleAt,
    lastSaleAt,
  };
}

export function buildRecentSales(sales: SalesReportSale[], limit = 3) {
  return sales
    .slice()
    .sort((a, b) => b.saleDate.getTime() - a.saleDate.getTime())
    .slice(0, limit)
    .map((sale) => ({ id: sale.id, invoiceNo: sale.invoiceNo, customerName: sale.customer?.name ?? null, amount: getNetSaleAmount(sale), soldAt: sale.saleDate }));
}

export function buildTopProducts(sales: SalesReportSale[], limit = 3) {
  const productMap = new Map<string, { productId: string; name: string; quantity: number; value: number }>();

  sales.forEach((sale) => {
    sale.items.forEach((item) => {
      const current = productMap.get(item.masterProductId) ?? { productId: item.masterProductId, name: item.masterProduct?.name ?? "Unknown", quantity: 0, value: 0 };
      current.quantity += toNumber(item.quantity);
      current.value += toNumber(item.totalAmount);
      productMap.set(item.masterProductId, current);
    });
  });

  return Array.from(productMap.values())
    .sort((a, b) => (b.quantity === a.quantity ? b.value - a.value : b.quantity - a.quantity))
    .slice(0, limit)
    .map((item, index) => ({ rank: index + 1, productId: item.productId, name: item.name, quantity: Number(item.quantity.toFixed(3)), value: Number(item.value.toFixed(2)) }));
}

export function buildTodayTrend(sales: SalesReportSale[]) {
  const buckets = [
    { key: "morning", label: "সকাল", startHour: 6, endHour: 12, value: 0 },
    { key: "noon", label: "দুপুর", startHour: 12, endHour: 16, value: 0 },
    { key: "evening", label: "বিকাল", startHour: 16, endHour: 20, value: 0 },
    { key: "night", label: "রাত", startHour: 20, endHour: 24, value: 0 },
  ];

  sales.forEach((sale) => {
    const saleHour = sale.saleDate.getHours();
    const bucket = buckets.find((item) => saleHour >= item.startHour && saleHour < item.endHour) ?? buckets[0];
    bucket.value += getNetSaleAmount(sale);
  });

  return buckets.map((bucket) => ({ key: bucket.key, label: bucket.label, value: Number(bucket.value.toFixed(2)) }));
}

export function buildWeekTrend(sales: SalesReportSale[], rangeStart: Date) {
  return Array.from({ length: 7 }, (_, index) => {
    const bucketDate = new Date(rangeStart);
    bucketDate.setDate(rangeStart.getDate() + index);
    const bucketDay = bucketDate.toDateString();
    const value = sales.filter((sale) => sale.saleDate.toDateString() === bucketDay).reduce((sum, sale) => sum + getNetSaleAmount(sale), 0);
    return { key: bucketDate.toISOString(), label: bucketDate.toLocaleDateString("bn-BD", { weekday: "short" }), value: Number(value.toFixed(2)) };
  });
}

export function buildMonthTrend(sales: SalesReportSale[], source = new Date()) {
  const daysInMonth = new Date(source.getFullYear(), source.getMonth() + 1, 0).getDate();
  return Array.from({ length: 4 }, (_, index) => {
    const startDay = index * 7 + 1;
    const endDay = index === 3 ? daysInMonth : Math.min(daysInMonth, startDay + 6);
    const value = sales.filter((sale) => sale.saleDate.getDate() >= startDay && sale.saleDate.getDate() <= endDay).reduce((sum, sale) => sum + getNetSaleAmount(sale), 0);
    return { key: `month-week-${index + 1}`, label: `${startDay}-${endDay}`, value: Number(value.toFixed(2)) };
  });
}

export function buildSalesmanReportPayload(todaySales: SalesReportSale[], weekSales: SalesReportSale[], monthSales: SalesReportSale[], source = new Date()) {
  const weekRange = getWeekRange(source);

  return {
    today: { summary: summarizeSales(todaySales), trend: buildTodayTrend(todaySales), recentSales: buildRecentSales(todaySales), topProducts: buildTopProducts(todaySales) },
    week: { summary: summarizeSales(weekSales), trend: buildWeekTrend(weekSales, weekRange.start), recentSales: buildRecentSales(weekSales), topProducts: buildTopProducts(weekSales) },
    month: { summary: summarizeSales(monthSales), trend: buildMonthTrend(monthSales, source), recentSales: buildRecentSales(monthSales), topProducts: buildTopProducts(monthSales) },
  };
}
