import { prisma } from "../../../config/prisma";

export interface UpdateInventorySettingsInput {
  low_stock_limit?: number;
  critical_stock_limit?: number;
  auto_low_stock_alert?: boolean;
  auto_deduct_on_sale?: boolean;
  allow_negative_stock?: boolean;
  bin_assignment_required?: boolean;
  show_bin_on_sale?: boolean;
  track_expiry?: boolean;
  costing_method?: string;
}

export class UpdateInventorySettingsUseCase {
  async execute(shopId: string, input: UpdateInventorySettingsInput) {
    const setting = await prisma.shopInventorySetting.upsert({
      where: { shopId },
      create: {
        shopId,
        lowStockDefault: input.low_stock_limit ?? 10,
        lowStockGrocery: input.critical_stock_limit ?? 5,
        autoLowStockAlert: input.auto_low_stock_alert ?? true,
        reduceStockOnSale: input.auto_deduct_on_sale ?? true,
        allowNegativeStock: input.allow_negative_stock ?? false,
        requireBinAssignment: input.bin_assignment_required ?? false,
        showBinDuringSale: input.show_bin_on_sale ?? true,
        demandBasedReorder: input.track_expiry ?? false,
        stockMethod: input.costing_method ?? "FIFO",
      },
      update: {
        lowStockDefault: input.low_stock_limit,
        lowStockGrocery: input.critical_stock_limit,
        autoLowStockAlert: input.auto_low_stock_alert,
        reduceStockOnSale: input.auto_deduct_on_sale,
        allowNegativeStock: input.allow_negative_stock,
        requireBinAssignment: input.bin_assignment_required,
        showBinDuringSale: input.show_bin_on_sale,
        demandBasedReorder: input.track_expiry,
        stockMethod: input.costing_method,
      },
    });

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
