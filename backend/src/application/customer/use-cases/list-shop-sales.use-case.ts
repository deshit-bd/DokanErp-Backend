import { toCustomerSaleSummary } from "@domain/customer/customer.entity";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class ListShopSalesUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(shop: ShopScope, query: { date?: unknown; status?: unknown }) {
    const date = typeof query.date === "string" ? query.date.trim() : "";
    const status = typeof query.status === "string" ? query.status.trim().toUpperCase() : "";
    const startDate = date ? new Date(`${date}T00:00:00.000Z`) : null;
    const endDate = date ? new Date(`${date}T23:59:59.999Z`) : null;

    const sales = await this.customerRepository.listShopSales(shop.id, { status, startDate, endDate });
    const mappedSales = sales.map(toCustomerSaleSummary);

    return {
      shop,
      summary: {
        totalSales: mappedSales.length,
        activeSales: mappedSales.filter((sale) => sale.status === "ACTIVE").length,
        cancelledSales: mappedSales.filter((sale) => sale.status === "CANCELLED").length,
        totalAmount: Number(mappedSales.reduce((sum, sale) => sum + sale.totalAmount, 0).toFixed(2)),
        totalPaid: Number(mappedSales.reduce((sum, sale) => sum + sale.paidAmount, 0).toFixed(2)),
        totalDue: Number(mappedSales.reduce((sum, sale) => sum + sale.dueAmount, 0).toFixed(2)),
      },
      sales: mappedSales,
    };
  }
}
