import { prisma } from "../../../config/prisma";

export class GetInventorySettingsUseCase {
  async execute(shopId: string) {
    let setting = await prisma.shopInventorySetting.findUnique({
      where: { shopId },
    });

    if (!setting) {
      setting = await prisma.shopInventorySetting.create({
        data: {
          shopId,
        },
      });
    }

    return {
      low_stock_limit: setting.lowStockDefault,
      critical_stock_limit: setting.lowStockGrocery,
      auto_low_stock_alert: setting.autoLowStockAlert,
      auto_deduct_on_sale: setting.reduceStockOnSale,
      allow_negative_stock: setting.allowNegativeStock,
      bin_assignment_required: setting.requireBinAssignment,
      show_bin_on_sale: setting.showBinDuringSale,
      track_expiry: setting.demandBasedReorder,
      costing_method: setting.stockMethod,
    };
  }
}
