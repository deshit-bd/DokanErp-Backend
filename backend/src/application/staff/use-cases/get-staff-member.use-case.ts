import { buildStaffIdentifierVariants, getDayRange, getMonthRange, mapStaffMember, toNumber } from "@domain/staff/staff.entity";
import { StaffMemberNotFoundError, ValidationError } from "@domain/staff/staff.errors";

import type { StaffRepository } from "../ports/staff-repository.port";

export class GetStaffMemberUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(shopId: string, rawStaffUserId: string) {
    const staffUserId = rawStaffUserId.trim();

    if (!staffUserId) {
      throw new ValidationError("Staff user id is required.");
    }

    const variants = buildStaffIdentifierVariants(staffUserId);
    const member = await this.staffRepository.findSalesmanByIdentifier(shopId, variants);

    if (!member) {
      throw new StaffMemberNotFoundError();
    }

    const now = new Date();
    const today = getDayRange(now);
    const month = getMonthRange(now);

    const [todaySales, monthSales, allSalesCount, todayActivities] = await Promise.all([
      this.staffRepository.findSimpleSalesInRange(shopId, member.user.id, today.start, today.end),
      this.staffRepository.findSimpleSalesInRange(shopId, member.user.id, month.start, month.end),
      this.staffRepository.countSales(shopId, member.user.id),
      this.staffRepository.findRecentSaleActivity(shopId, member.user.id, today.start, today.end, 10),
    ]);

    const staff = mapStaffMember(member);

    return {
      staff: { ...staff, isBillable: member.isBillable, todaySalesCount: todaySales.length, monthSalesCount: monthSales.length },
      summary: {
        todaySalesAmount: Number(todaySales.reduce((sum, sale) => sum + toNumber(sale.totalAmount), 0).toFixed(2)),
        monthSalesAmount: Number(monthSales.reduce((sum, sale) => sum + toNumber(sale.totalAmount), 0).toFixed(2)),
        totalSalesCount: allSalesCount,
      },
      todayActivities: todayActivities.map((sale) => ({
        id: sale.id,
        invoiceNo: sale.invoiceNo,
        customerName: sale.customer?.name ?? null,
        amount: toNumber(sale.totalAmount),
        soldAt: sale.saleDate,
      })),
    };
  }
}
