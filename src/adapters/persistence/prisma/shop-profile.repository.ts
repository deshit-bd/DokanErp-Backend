import { deriveBinStatus, toMoney } from "@domain/shop-profile/shop-profile.entity";
import type {
  BankAccountSource,
  CatalogProduct,
  ConfiguredShopProduct,
  MoneyBoxSource,
  ShopProfileRepository,
} from "@application/shop-profile/ports/shop-profile-repository.port";

import { prisma } from "../../../infrastructure/prisma/client";
import { ensureGeneralInventoryBin } from "./inventory.repository";

async function syncQuickSetupBatch(
  tx: any,
  params: { shopId: string; masterProductId: string; productName: string; openingStock: number; purchasePrice: number | null; salePrice: number | null },
) {
  const { shopId, masterProductId, productName, openingStock, purchasePrice, salePrice } = params;
  const targetBin = await ensureGeneralInventoryBin(tx, shopId, masterProductId, productName);

  const existingBatch = await tx.inventoryBinItem.findFirst({
    where: { shopId, masterProductId, purchaseItemId: null, batchNo: "1" },
    orderBy: [{ createdAt: "asc" }, { id: "asc" }],
  });

  if (openingStock <= 0) {
    if (existingBatch) {
      await tx.inventoryBinItem.delete({ where: { id: existingBatch.id } });
    }
  } else if (existingBatch) {
    await tx.inventoryBinItem.update({
      where: { id: existingBatch.id },
      data: { binId: targetBin.id, quantity: openingStock, purchasePrice, salePrice, batchNo: "1", notes: "Quick setup batch 1" },
    });
  } else {
    await tx.inventoryBinItem.create({
      data: { shopId, binId: targetBin.id, masterProductId, quantity: openingStock, purchasePrice, salePrice, batchNo: "1", notes: "Quick setup batch 1" },
    });
  }

  const totalBinQtyAgg = await tx.inventoryBinItem.aggregate({ where: { binId: targetBin.id }, _sum: { quantity: true } });
  const quantityValue = Number(totalBinQtyAgg._sum.quantity ?? 0);

  await tx.inventoryBin.update({
    where: { id: targetBin.id },
    data: {
      productName,
      status: deriveBinStatus(quantityValue),
      quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
      daysLabel: quantityValue <= 0 ? "খালি" : "Batch 1",
    },
  });
}

function toMoneyBoxSource(record: any): MoneyBoxSource {
  return {
    id: record.id,
    boxName: record.boxName,
    code: record.code,
    type: record.type,
    openingBalance: toMoney(record.openingBalance),
    currentBalance: toMoney(record.currentBalance),
    details: record.details ?? null,
    status: record.status,
  };
}

function toBankAccountSource(record: any): BankAccountSource {
  return {
    id: record.id,
    accountName: record.accountName,
    bankName: record.bankName,
    branchName: record.branchName ?? null,
    accountNumber: record.accountNumber,
    accountType: record.accountType,
    openingBalance: toMoney(record.openingBalance),
    currentBalance: toMoney(record.currentBalance),
    currency: record.currency,
    status: record.status,
    isDefault: Boolean(record.isDefault),
    notes: record.notes ?? null,
  };
}

const SHOP_SETTINGS_SELECT = {
  id: true,
  shopCode: true,
  shopName: true,
  businessType: true,
  phone: true,
  address: true,
  logoUrl: true,
  status: true,
  receiptSetting: { select: { showLogo: true, showAddress: true, showPhone: true, showVatInfo: true } },
  inventorySetting: {
    select: {
      lowStockDefault: true,
      lowStockGrocery: true,
      autoLowStockAlert: true,
      reduceStockOnSale: true,
      allowNegativeStock: true,
      requireBinAssignment: true,
      showBinDuringSale: true,
      demandBasedReorder: true,
      manualStockApproval: true,
      stockMethod: true,
    },
  },
} as const;

export class PrismaShopProfileRepository implements ShopProfileRepository {
  async findAllShops() {
    return prisma.shop.findMany({
      select: { id: true, shopCode: true, shopName: true, status: true },
      orderBy: [{ shopName: "asc" }],
    });
  }

  async findShopById(id: string) {
    return prisma.shop.findUnique({ where: { id }, select: { id: true, shopCode: true, shopName: true, businessType: true, status: true } });
  }

  async findSalesmanMembership(shopId: string, userId: string) {
    return prisma.shopUser.findFirst({ where: { shopId, userId, role: "SALESMAN" }, select: { id: true } });
  }

  async findShopSettings(id: string) {
    return prisma.shop.findUnique({ where: { id }, select: SHOP_SETTINGS_SELECT }) as any;
  }

  async updateShopProfile(id: string, input: any, ownerId: string, ownerInput: any, receiptInput: any) {
    const result = await prisma.$transaction(async (tx) => {
      const shop = await tx.shop.update({ where: { id }, data: input, select: SHOP_SETTINGS_SELECT });
      const owner = await tx.user.update({ where: { id: ownerId }, data: ownerInput, select: { id: true, name: true, phone: true, email: true } });
      const receipt = await tx.shopReceiptSetting.upsert({
        where: { shopId: id },
        update: receiptInput,
        create: { shopId: id, ...receiptInput },
        select: { showLogo: true, showAddress: true, showPhone: true, showVatInfo: true },
      });
      return { shop: { ...shop, receiptSetting: receipt }, owner };
    });

    return result as any;
  }

  async updateShopLogo(id: string, logoUrl: string | null) {
    return prisma.shop.update({
      where: { id },
      data: { logoUrl },
      select: { id: true, shopCode: true, shopName: true, businessType: true, phone: true, address: true, logoUrl: true, status: true, receiptSetting: { select: { showLogo: true, showAddress: true, showPhone: true, showVatInfo: true } } },
    }) as any;
  }

  async findShopByPhoneExcept(phone: string, excludeId: string) {
    return prisma.shop.findFirst({ where: { phone, id: { not: excludeId } }, select: { id: true } });
  }

  async findUserByPhoneExcept(phone: string, excludeId: string) {
    return prisma.user.findFirst({ where: { phone, id: { not: excludeId } }, select: { id: true } });
  }

  async findInventorySettings(shopId: string) {
    const record = await prisma.shopInventorySetting.findUnique({ where: { shopId } });
    return record;
  }

  async upsertInventorySettings(shopId: string, update: any, createDefaults: any) {
    return prisma.shopInventorySetting.upsert({
      where: { shopId },
      update,
      create: { shopId, ...createDefaults },
    });
  }

  async findActiveMoneyBoxes(shopId: string): Promise<MoneyBoxSource[]> {
    const records = await (prisma as any).moneyBox.findMany({ where: { shopId, status: "ACTIVE" }, orderBy: [{ type: "asc" }, { createdAt: "asc" }] });
    return records.map(toMoneyBoxSource);
  }

  async findActiveBankAccounts(shopId: string): Promise<BankAccountSource[]> {
    const records = await (prisma as any).bankAccount.findMany({ where: { shopId, status: "ACTIVE" }, orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }] });
    return records.map(toBankAccountSource);
  }

  async findMoneyBoxByCode(code: string) {
    return (prisma as any).moneyBox.findUnique({ where: { code }, select: { id: true } });
  }

  async findMoneyBoxByCodeExcept(code: string, excludeId: string) {
    return (prisma as any).moneyBox.findFirst({ where: { code, id: { not: excludeId } }, select: { id: true } });
  }

  async findShopMoneyBox(id: string, shopId: string) {
    const record = await (prisma as any).moneyBox.findFirst({ where: { id, shopId } });
    return record ? { ...toMoneyBoxSource(record), shopId: record.shopId } : null;
  }

  async createMoneyBox(shopId: string, input: any): Promise<MoneyBoxSource> {
    const record = await (prisma as any).moneyBox.create({ data: { shopId, ...input, currentBalance: input.openingBalance } });
    return toMoneyBoxSource(record);
  }

  async updateMoneyBoxWithBalanceDelta(id: string, input: any, previousOpeningBalance: number, previousCurrentBalance: number): Promise<MoneyBoxSource> {
    const openingDelta = input.openingBalance - previousOpeningBalance;
    const record = await (prisma as any).moneyBox.update({
      where: { id },
      data: { ...input, currentBalance: previousCurrentBalance + openingDelta },
    });
    return toMoneyBoxSource(record);
  }

  async findBankAccountByBankAndNumber(bankName: string, accountNumber: string) {
    return (prisma as any).bankAccount.findFirst({ where: { bankName, accountNumber }, select: { id: true } });
  }

  async findBankAccountByBankAndNumberExcept(bankName: string, accountNumber: string, excludeId: string) {
    return (prisma as any).bankAccount.findFirst({ where: { bankName, accountNumber, id: { not: excludeId } }, select: { id: true } });
  }

  async findShopBankAccount(id: string, shopId: string) {
    const record = await (prisma as any).bankAccount.findFirst({ where: { id, shopId } });
    return record ? { ...toBankAccountSource(record), shopId: record.shopId } : null;
  }

  async createBankAccount(shopId: string, input: any): Promise<BankAccountSource> {
    const record = await prisma.$transaction(async (tx) => {
      if (input.isDefault) {
        await (tx as any).bankAccount.updateMany({ where: { shopId }, data: { isDefault: false } });
      }
      return (tx as any).bankAccount.create({ data: { shopId, ...input, currentBalance: input.openingBalance } });
    });
    return toBankAccountSource(record);
  }

  async updateBankAccountWithBalanceDelta(id: string, shopId: string, input: any, previousOpeningBalance: number, previousCurrentBalance: number): Promise<BankAccountSource> {
    const record = await prisma.$transaction(async (tx) => {
      if (input.isDefault) {
        await (tx as any).bankAccount.updateMany({ where: { shopId, id: { not: id } }, data: { isDefault: false } });
      }
      const openingDelta = input.openingBalance - previousOpeningBalance;
      return (tx as any).bankAccount.update({ where: { id }, data: { ...input, currentBalance: previousCurrentBalance + openingDelta } });
    });
    return toBankAccountSource(record);
  }

  async findQuickSetupCatalog(): Promise<CatalogProduct[]> {
    const products = await (prisma as any).masterProduct.findMany({
      where: { status: "ACTIVE" },
      orderBy: [{ name: "asc" }],
      take: 100,
      select: { id: true, sku: true, name: true, price: true, suggestedPrice: true, packageSize: true, category: { select: { name: true } } },
    });

    return products.map((product: any) => ({
      id: product.id,
      sku: product.sku,
      name: product.name,
      category: product.category?.name ?? "অন্যান্য",
      packageSize: product.packageSize,
      price: toMoney(product.price),
      suggestedPrice: toMoney(product.suggestedPrice ?? product.price),
    }));
  }

  async findConfiguredShopProducts(shopId: string): Promise<ConfiguredShopProduct[]> {
    const items = await (prisma as any).shopProduct.findMany({
      where: { shopId, masterProductId: { not: null } },
      include: { masterProduct: { select: { id: true, sku: true, name: true, packageSize: true, price: true, suggestedPrice: true } } },
      orderBy: [{ createdAt: "asc" }],
    });

    return items.map((item: any) => ({
      masterProductId: item.masterProductId,
      name: item.masterProduct.name,
      sku: item.masterProduct.sku,
      packageSize: item.masterProduct.packageSize,
      openingStock: toMoney(item.openingStock),
      purchasePrice: toMoney(item.purchasePrice ?? item.masterProduct.price),
      salePrice: toMoney(item.salePrice ?? item.masterProduct.suggestedPrice ?? item.masterProduct.price),
      lowStockLimit: Number(item.lowStockLimit ?? 10),
    }));
  }

  async countDistinctShopProducts(shopId: string): Promise<number> {
    const { countDistinctShopProducts } = await import("../../../subscription/access");
    return countDistinctShopProducts(shopId);
  }

  async findShopProductsWithMasterProduct(shopId: string) {
    const shopProducts = await (prisma as any).shopProduct.findMany({
      where: { shopId },
      include: {
        masterProduct: { select: { id: true, sku: true, name: true, packageSize: true, pictureUrl: true, price: true, suggestedPrice: true, status: true } },
        approvalRequest: { select: { id: true, status: true } },
      },
      orderBy: [{ createdAt: "asc" }],
    });

    return shopProducts.map((item: any) => ({
      id: item.source === "SHOP_LOCAL" ? item.id : item.masterProductId,
      shopProductId: item.id,
      masterProductId: item.masterProductId,
      sku: item.masterProduct?.sku ?? item.localBarcode ?? item.id,
      name: item.masterProduct?.name ?? item.localName ?? "Unnamed product",
      packageSize: item.masterProduct?.packageSize ?? item.localUnit ?? item.masterProduct?.sku ?? item.id,
      pictureUrl: item.masterProduct?.pictureUrl ?? item.localPictureUrl ?? null,
      price: toMoney(item.salePrice ?? item.masterProduct?.suggestedPrice ?? item.masterProduct?.price),
      purchasePrice: toMoney(item.purchasePrice ?? item.masterProduct?.price),
      suggestedPrice: toMoney(item.salePrice ?? item.masterProduct?.suggestedPrice ?? item.masterProduct?.price),
      stock: Number(item.openingStock ?? 0),
      lowStockLimit: Number(item.lowStockLimit ?? 0),
      category: item.localCategory ?? "",
      brand: item.localBrand ?? null,
      unit: item.localUnit ?? null,
      barcode: item.localBarcode ?? null,
      status: item.masterProduct?.status ?? "ACTIVE",
      approvalStatus: item.approvalRequest?.status ?? null,
      source: item.source,
    }));
  }

  async findActiveMasterProductsExcluding(excludeIds: string[]) {
    const masterProducts = await (prisma as any).masterProduct.findMany({
      where: { status: "ACTIVE", ...(excludeIds.length ? { id: { notIn: excludeIds } } : {}) },
      select: { id: true, sku: true, name: true, packageSize: true, pictureUrl: true, price: true, suggestedPrice: true, status: true },
      orderBy: [{ name: "asc" }],
      take: 100,
    });

    return masterProducts.map((item: any) => ({
      id: item.id,
      shopProductId: null,
      masterProductId: item.id,
      sku: item.sku,
      name: item.name,
      packageSize: item.packageSize ?? item.sku,
      pictureUrl: item.pictureUrl ?? null,
      price: toMoney(item.suggestedPrice ?? item.price),
      purchasePrice: toMoney(item.price),
      suggestedPrice: toMoney(item.suggestedPrice ?? item.price),
      stock: 0,
      category: "",
      status: item.status,
      source: "MASTER",
    }));
  }

  async findExistingLocalBarcode(shopId: string, barcode: string) {
    return (prisma as any).shopProduct.findFirst({
      where: { shopId, OR: [{ localBarcode: barcode }, { masterProduct: { barcodes: { some: { barcode } } } }] },
      select: { id: true },
    });
  }

  async createLocalShopProduct(shopId: string, ownerId: string, input: any) {
    return prisma.$transaction(async (tx) => {
      const typedTx = tx as any;
      const requestRow = await typedTx.masterProductRequest.create({
        data: { shopId, createdByUserId: ownerId, status: "PENDING", ...input },
      });

      const shopProduct = await typedTx.shopProduct.create({
        data: {
          shopId,
          source: "SHOP_LOCAL",
          localName: input.name,
          localCategory: input.category,
          localBrand: input.brand,
          localUnit: input.unit,
          localBarcode: input.barcode,
          localPictureUrl: input.pictureUrl,
          openingStock: input.openingStock,
          lowStockLimit: input.lowStockLimit,
          salePrice: input.salePrice,
          purchasePrice: input.purchasePrice,
          approvalRequestId: requestRow.id,
        },
      });

      const linkedRequest = await typedTx.masterProductRequest.update({ where: { id: requestRow.id }, data: { shopProductId: shopProduct.id } });

      return { shopProduct, request: linkedRequest };
    });
  }

  async findMasterProductsByIds(ids: string[]) {
    return (prisma as any).masterProduct.findMany({ where: { id: { in: ids }, status: "ACTIVE" }, select: { id: true, sku: true, name: true, price: true, suggestedPrice: true } });
  }

  async selectQuickSetupProducts(shopId: string, products: Array<{ id: string; price: unknown; suggestedPrice: unknown }>): Promise<ConfiguredShopProduct[]> {
    const productIds = products.map((product) => product.id);

    const selectedProducts = await prisma.$transaction(async (tx) => {
      const typedTx = tx as any;
      for (const product of products) {
        await typedTx.shopProduct.upsert({
          where: { shopId_masterProductId: { shopId, masterProductId: product.id } },
          update: {},
          create: {
            shopId,
            masterProductId: product.id,
            openingStock: 0,
            purchasePrice: product.price ?? 0,
            salePrice: product.suggestedPrice ?? product.price ?? 0,
            lowStockLimit: 10,
          },
        });
      }

      return typedTx.shopProduct.findMany({
        where: { shopId, masterProductId: { in: productIds } },
        include: { masterProduct: { select: { id: true, sku: true, name: true, packageSize: true, price: true, suggestedPrice: true } } },
      });
    });

    return selectedProducts.map((item: any) => ({
      masterProductId: item.masterProductId,
      name: item.masterProduct.name,
      sku: item.masterProduct.sku,
      packageSize: item.masterProduct.packageSize,
      openingStock: toMoney(item.openingStock),
      purchasePrice: toMoney(item.purchasePrice ?? item.masterProduct.price),
      salePrice: toMoney(item.salePrice ?? item.masterProduct.suggestedPrice ?? item.masterProduct.price),
      lowStockLimit: Number(item.lowStockLimit ?? 10),
    }));
  }

  async saveQuickSetupPricing(shopId: string, items: Array<{ masterProductId: string; openingStock: number; purchasePrice: number; salePrice: number; lowStockLimit: number }>) {
    const updatedProducts = await prisma.$transaction(async (tx) => {
      const typedTx = tx as any;
      const configuredProducts = await typedTx.shopProduct.findMany({
        where: { shopId, masterProductId: { in: items.map((item) => item.masterProductId) } },
        select: { id: true, masterProductId: true, masterProduct: { select: { id: true, name: true, sku: true, packageSize: true, price: true, suggestedPrice: true } } },
      });

      const configuredById = new Map<string, any>(configuredProducts.map((item: any) => [item.masterProductId, item]));

      for (const item of items) {
        const configured = configuredById.get(item.masterProductId);
        const productName = configured?.masterProduct?.name ?? "Stock";

        await typedTx.shopProduct.update({
          where: { shopId_masterProductId: { shopId, masterProductId: item.masterProductId } },
          data: { openingStock: item.openingStock, purchasePrice: item.purchasePrice, salePrice: item.salePrice, lowStockLimit: item.lowStockLimit },
        });

        await syncQuickSetupBatch(typedTx, {
          shopId,
          masterProductId: item.masterProductId,
          productName,
          openingStock: item.openingStock,
          purchasePrice: item.purchasePrice,
          salePrice: item.salePrice,
        });
      }

      return typedTx.shopProduct.findMany({
        where: { shopId, masterProductId: { in: items.map((item) => item.masterProductId) } },
        include: { masterProduct: { select: { id: true, sku: true, name: true, packageSize: true } } },
      });
    });

    return updatedProducts.map((item: any) => ({
      masterProductId: item.masterProductId,
      name: item.masterProduct.name,
      sku: item.masterProduct.sku,
      packageSize: item.masterProduct.packageSize,
      openingStock: toMoney(item.openingStock),
      purchasePrice: toMoney(item.purchasePrice ?? item.masterProduct.price),
      salePrice: toMoney(item.salePrice),
      lowStockLimit: Number(item.lowStockLimit ?? 10),
      batchNo: "1",
    }));
  }

  async countConfiguredShopProducts(shopId: string, masterProductIds: string[]): Promise<number> {
    return (prisma as any).shopProduct.count({ where: { shopId, masterProductId: { in: masterProductIds } } });
  }

  async findShopProductById(id: string) {
    return (prisma as any).shopProduct.findUnique({ where: { id }, select: { id: true, shopId: true } });
  }

  async updateShopProduct(id: string, update: any) {
    return (prisma as any).shopProduct.update({
      where: { id },
      data: update,
      include: { masterProduct: true, approvalRequest: { select: { id: true, status: true } } },
    });
  }

  async findTaxesAndCharges(shopId: string) {
    const [taxes, charges] = await Promise.all([
      prisma.shopTax.findMany({ where: { shopId }, orderBy: { createdAt: "asc" } }),
      prisma.shopCharge.findMany({ where: { shopId }, orderBy: { createdAt: "asc" } }),
    ]);
    return { taxes, charges };
  }

  async createTax(shopId: string, input: { name: string; rate: number; type: string }) {
    return prisma.shopTax.create({ data: { shopId, name: input.name, rate: input.rate, type: input.type, isActive: true } });
  }

  async createCharge(shopId: string, input: { name: string; amount: number; type: string }) {
    return prisma.shopCharge.create({ data: { shopId, name: input.name, amount: input.amount, type: input.type, isActive: true } });
  }

  async updateTax(id: string, shopId: string, update: any): Promise<void> {
    await prisma.shopTax.updateMany({ where: { id, shopId }, data: update });
  }

  async updateCharge(id: string, shopId: string, update: any): Promise<void> {
    await prisma.shopCharge.updateMany({ where: { id, shopId }, data: update });
  }

  async deleteTax(id: string, shopId: string): Promise<void> {
    await prisma.shopTax.deleteMany({ where: { id, shopId } });
  }

  async deleteCharge(id: string, shopId: string): Promise<void> {
    await prisma.shopCharge.deleteMany({ where: { id, shopId } });
  }
}
