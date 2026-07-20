import { buildSalesmanReportPayload, getDayRange, getMonthRange, getWeekRange, mapStaffMember } from "@domain/staff/staff.entity";
import { ShopIdNotAssociatedError, StaffMemberNotFoundError } from "@domain/staff/staff.errors";

import type { StaffRepository } from "../ports/staff-repository.port";

export class GetSalesmanOwnPerformanceUseCase {
  constructor(private readonly staffRepository: StaffRepository) {}

  async execute(shopId: string | undefined, userId: string) {
    if (!shopId) {
      throw new ShopIdNotAssociatedError();
    }

    const member = await this.staffRepository.findShopUserMember(shopId, userId);

    if (!member) {
      throw new StaffMemberNotFoundError("Staff user not found in this shop.");
    }

    const now = new Date();
    const today = getDayRange(now);
    const week = getWeekRange(now);
    const month = getMonthRange(now);

    const [todaySales, weekSales, monthSales, allSalesCount] = await Promise.all([
      this.staffRepository.findSalesInRange(shopId, userId, today.start, today.end),
      this.staffRepository.findSalesInRange(shopId, userId, week.start, week.end),
      this.staffRepository.findSalesInRange(shopId, userId, month.start, month.end),
      this.staffRepository.countSales(shopId, userId),
    ]);

    const staff = mapStaffMember(member);
    const report = buildSalesmanReportPayload(todaySales, weekSales, monthSales, now);
    const todaySummary = report.today.summary;
    const monthSummary = report.month.summary;

    return {
      staff: { ...staff, isBillable: member.isBillable, todaySalesCount: todaySummary.salesCount, monthSalesCount: monthSummary.salesCount },
      summary: { todaySalesAmount: todaySummary.totalSalesAmount, monthSalesAmount: monthSummary.totalSalesAmount, totalSalesCount: allSalesCount },
      todayActivities: report.today.recentSales,
      report,
    };
  }
}
