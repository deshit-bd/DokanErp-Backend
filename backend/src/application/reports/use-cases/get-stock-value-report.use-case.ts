import type { ReportsRepository } from "../ports/reports-repository.port";

export class GetStockValueReportUseCase {
  constructor(private readonly reportsRepository: ReportsRepository) {}

  async execute(shopId: string) {
    const { shopProducts, latestSaleDateByMasterProductId } = await this.reportsRepository.getStockValueRawData(shopId);

    let totalStockValue = 0;
    const totalProducts = shopProducts.length;
    let lowStock = 0;
    let outOfStock = 0;

    const categoryValues: Record<string, number> = {};

    for (const p of shopProducts as any[]) {
      const stock = Number(p.openingStock ?? 0);
      const purchasePrice = Number(p.purchasePrice ?? p.salePrice ?? 0);
      const value = stock * purchasePrice;
      totalStockValue += value;

      if (stock <= 0) {
        outOfStock++;
      } else if (stock <= Number(p.lowStockLimit ?? 5)) {
        lowStock++;
      }

      const catName = p.masterProduct?.category?.name || p.localCategory || "অন্যান্য";
      categoryValues[catName] = (categoryValues[catName] || 0) + value;
    }

    const allCategoriesBreakdown = Object.entries(categoryValues)
      .map(([name, val]) => ({ name, value: Math.round(val) }))
      .sort((a, b) => b.value - a.value);

    let categoriesBreakdown: Array<{ name: string; value: number; percentage: number }> = [];
    if (allCategoriesBreakdown.length > 4) {
      const top4 = allCategoriesBreakdown.slice(0, 4);
      const rest = allCategoriesBreakdown.slice(4);
      const restValue = rest.reduce((sum, item) => sum + item.value, 0);

      categoriesBreakdown = [
        ...top4.map((c) => ({
          name: c.name,
          value: c.value,
          percentage: totalStockValue > 0 ? Math.round((c.value / totalStockValue) * 100) : 0,
        })),
        {
          name: "অন্যান্য",
          value: Math.round(restValue),
          percentage: totalStockValue > 0 ? Math.round((restValue / totalStockValue) * 100) : 0,
        },
      ];
    } else {
      categoriesBreakdown = allCategoriesBreakdown.map((c) => ({
        name: c.name,
        value: c.value,
        percentage: totalStockValue > 0 ? Math.round((c.value / totalStockValue) * 100) : 0,
      }));
    }

    if (totalStockValue > 0 && categoriesBreakdown.length > 0) {
      const sumPercentage = categoriesBreakdown.reduce((sum, c) => sum + c.percentage, 0);
      if (sumPercentage !== 100 && sumPercentage > 0) {
        let maxIndex = 0;
        for (let i = 1; i < categoriesBreakdown.length; i++) {
          if (categoriesBreakdown[i].percentage > categoriesBreakdown[maxIndex].percentage) {
            maxIndex = i;
          }
        }
        categoriesBreakdown[maxIndex].percentage += 100 - sumPercentage;
      }
    }

    if (totalStockValue === 0 && categoriesBreakdown.length > 0) {
      categoriesBreakdown[0].percentage = 100;
    }

    const topProductsList = (shopProducts as any[])
      .map((p) => {
        const stock = Number(p.openingStock ?? 0);
        const purchasePrice = Number(p.purchasePrice ?? p.salePrice ?? 0);
        const value = stock * purchasePrice;
        return {
          name: p.masterProduct?.name || p.localName || "অজানা পণ্য",
          quantity: Math.round(stock),
          value: Math.round(value),
        };
      })
      .filter((item) => item.quantity > 0)
      .sort((a, b) => b.value - a.value)
      .slice(0, 5)
      .map((item, index) => ({ rank: index + 1, ...item }));

    const now = new Date();

    const deadProductsList = (shopProducts as any[])
      .filter((p) => Number(p.openingStock ?? 0) > 0)
      .map((p) => {
        let daysInactive = 0;
        let lastSoldAt: Date | null = null;
        if (p.masterProductId && latestSaleDateByMasterProductId.has(p.masterProductId)) {
          const lastSaleDate = latestSaleDateByMasterProductId.get(p.masterProductId)!;
          lastSoldAt = lastSaleDate;
          daysInactive = Math.max(0, Math.floor((now.getTime() - lastSaleDate.getTime()) / (1000 * 60 * 60 * 24)));
        } else {
          daysInactive = Math.max(0, Math.floor((now.getTime() - p.createdAt.getTime()) / (1000 * 60 * 60 * 24)));
        }
        return {
          name: p.masterProduct?.name || p.localName || "অজানা পণ্য",
          quantity: Math.round(Number(p.openingStock ?? 0)),
          value: Math.round(Number(p.openingStock ?? 0) * Number(p.purchasePrice ?? p.salePrice ?? 0)),
          daysInactive,
          lastSoldAt,
        };
      })
      .filter((item) => item.daysInactive >= 100)
      .sort((a, b) => b.daysInactive - a.daysInactive)
      .slice(0, 5)
      .map((item, index) => ({ rank: index + 1, ...item }));

    return {
      summary: { totalStockValue: Math.round(totalStockValue), totalProducts, lowStock, outOfStock },
      categories: categoriesBreakdown,
      topProducts: topProductsList,
      deadStock: deadProductsList,
      meta: { deadStockThresholdDays: 100, generatedAt: new Date() },
    };
  }
}
