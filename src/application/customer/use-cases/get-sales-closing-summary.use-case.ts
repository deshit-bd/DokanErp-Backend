import { toCustomerSaleSummary } from "@domain/customer/customer.entity";

import type { CustomerRepository, ShopScope } from "../ports/customer-repository.port";

export class GetSalesClosingSummaryUseCase {
  constructor(private readonly customerRepository: CustomerRepository) {}

  async execute(shop: ShopScope, query: { date?: unknown }) {
    const date = typeof query.date === "string" && query.date.trim() ? query.date.trim() : new Date().toISOString().slice(0, 10);
    const startDate = new Date(`${date}T00:00:00.000Z`);
    const endDate = new Date(`${date}T23:59:59.999Z`);

    const sales = await this.customerRepository.getSalesClosingSummaryData(shop.id, startDate, endDate);

    const summary = {
      totalSalesAmount: Number(sales.reduce((sum: number, sale: any) => sum + Number(sale.totalAmount ?? 0), 0).toFixed(2)),
      totalPaidAmount: Number(sales.reduce((sum: number, sale: any) => sum + Number(sale.paidAmount ?? 0), 0).toFixed(2)),
      totalDueAmount: Number(sales.reduce((sum: number, sale: any) => sum + Number(sale.dueAmount ?? 0), 0).toFixed(2)),
      salesCount: sales.length,
    };

    const paymentBreakdown = ["CASH", "BKASH", "NAGAD", "CARD", "DUE"].map((method) => ({
      method,
      amount: Number(
        sales
          .filter((sale: any) => (sale.paymentMethod ?? "DUE") === method)
          .reduce((sum: number, sale: any) => sum + (method === "DUE" ? Number(sale.dueAmount ?? 0) : Number(sale.paidAmount ?? 0)), 0)
          .toFixed(2),
      ),
    }));

    const productMap = new Map<string, { masterProductId: string; name: string; quantity: number }>();
    sales.forEach((sale: any) => {
      sale.items.forEach((item: any) => {
        const key = item.masterProductId;
        const existing = productMap.get(key);
        if (existing) {
          existing.quantity += Number(item.quantity ?? 0);
        } else {
          productMap.set(key, { masterProductId: key, name: item.masterProduct?.name ?? "Unknown", quantity: Number(item.quantity ?? 0) });
        }
      });
    });

    const topProducts = Array.from(productMap.values())
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 5)
      .map((item) => ({ ...item, quantity: Number(item.quantity.toFixed(3)) }));

    return { shop, date, summary, paymentBreakdown, topProducts, sales: sales.map(toCustomerSaleSummary) };
  }
}
