import type { Request, Response } from "express";

import { AppError, ForbiddenError, NotFoundError, ServiceUnavailableError } from "@domain/shared/app-error";
import { CreateChargeUseCase } from "@application/shop-profile/use-cases/create-charge.use-case";
import { CreateLocalShopProductUseCase } from "@application/shop-profile/use-cases/create-local-shop-product.use-case";
import { CreateShopBankAccountUseCase } from "@application/shop-profile/use-cases/create-shop-bank-account.use-case";
import { CreateShopMoneyBoxUseCase } from "@application/shop-profile/use-cases/create-shop-money-box.use-case";
import { CreateTaxUseCase } from "@application/shop-profile/use-cases/create-tax.use-case";
import { DeleteChargeUseCase } from "@application/shop-profile/use-cases/delete-charge.use-case";
import { DeleteTaxUseCase } from "@application/shop-profile/use-cases/delete-tax.use-case";
import { GetQuickSetupCatalogUseCase } from "@application/shop-profile/use-cases/get-quick-setup-catalog.use-case";
import { GetShopFinanceSourcesUseCase } from "@application/shop-profile/use-cases/get-shop-finance-sources.use-case";
import { GetShopInventorySettingsUseCase } from "@application/shop-profile/use-cases/get-shop-inventory-settings.use-case";
import { GetShopSettingsUseCase } from "@application/shop-profile/use-cases/get-shop-settings.use-case";
import { GetTaxesChargesUseCase } from "@application/shop-profile/use-cases/get-taxes-charges.use-case";
import { ListShopProductsUseCase } from "@application/shop-profile/use-cases/list-shop-products.use-case";
import { ListShopsUseCase } from "@application/shop-profile/use-cases/list-shops.use-case";
import { SaveQuickSetupPricingUseCase } from "@application/shop-profile/use-cases/save-quick-setup-pricing.use-case";
import { SelectQuickSetupProductsUseCase } from "@application/shop-profile/use-cases/select-quick-setup-products.use-case";
import { UpdateChargeUseCase } from "@application/shop-profile/use-cases/update-charge.use-case";
import { UpdateShopBankAccountUseCase } from "@application/shop-profile/use-cases/update-shop-bank-account.use-case";
import { UpdateShopInventorySettingsUseCase } from "@application/shop-profile/use-cases/update-shop-inventory-settings.use-case";
import { UpdateShopLogoUseCase } from "@application/shop-profile/use-cases/update-shop-logo.use-case";
import { UpdateShopMoneyBoxUseCase } from "@application/shop-profile/use-cases/update-shop-money-box.use-case";
import { UpdateShopProductUseCase } from "@application/shop-profile/use-cases/update-shop-product.use-case";
import { UpdateShopSettingsUseCase } from "@application/shop-profile/use-cases/update-shop-settings.use-case";
import { UpdateTaxUseCase } from "@application/shop-profile/use-cases/update-tax.use-case";
import type { ShopProfileRepository } from "@application/shop-profile/ports/shop-profile-repository.port";

import { PrismaShopProfileRepository } from "../../persistence/prisma/shop-profile.repository";
import { ShopLogoStorageAdapter } from "../../storage/shop-logo-storage.adapter";

const shopProfileRepository: ShopProfileRepository = new PrismaShopProfileRepository();
const logoStorage = new ShopLogoStorageAdapter();

const listShopsUseCase = new ListShopsUseCase(shopProfileRepository);
const getShopSettingsUseCase = new GetShopSettingsUseCase(shopProfileRepository);
const updateShopSettingsUseCase = new UpdateShopSettingsUseCase(shopProfileRepository);
const getShopFinanceSourcesUseCase = new GetShopFinanceSourcesUseCase(shopProfileRepository);
const createShopMoneyBoxUseCase = new CreateShopMoneyBoxUseCase(shopProfileRepository);
const updateShopMoneyBoxUseCase = new UpdateShopMoneyBoxUseCase(shopProfileRepository);
const createShopBankAccountUseCase = new CreateShopBankAccountUseCase(shopProfileRepository);
const updateShopBankAccountUseCase = new UpdateShopBankAccountUseCase(shopProfileRepository);
const getShopInventorySettingsUseCase = new GetShopInventorySettingsUseCase(shopProfileRepository);
const updateShopInventorySettingsUseCase = new UpdateShopInventorySettingsUseCase(shopProfileRepository);
const updateShopLogoUseCase = new UpdateShopLogoUseCase(shopProfileRepository, logoStorage);
const getQuickSetupCatalogUseCase = new GetQuickSetupCatalogUseCase(shopProfileRepository);
const listShopProductsUseCase = new ListShopProductsUseCase(shopProfileRepository);
const createLocalShopProductUseCase = new CreateLocalShopProductUseCase(shopProfileRepository);
const selectQuickSetupProductsUseCase = new SelectQuickSetupProductsUseCase(shopProfileRepository);
const saveQuickSetupPricingUseCase = new SaveQuickSetupPricingUseCase(shopProfileRepository);
const updateShopProductUseCase = new UpdateShopProductUseCase(shopProfileRepository);
const getTaxesChargesUseCase = new GetTaxesChargesUseCase(shopProfileRepository);
const createTaxUseCase = new CreateTaxUseCase(shopProfileRepository);
const createChargeUseCase = new CreateChargeUseCase(shopProfileRepository);
const updateTaxUseCase = new UpdateTaxUseCase(shopProfileRepository);
const updateChargeUseCase = new UpdateChargeUseCase(shopProfileRepository);
const deleteTaxUseCase = new DeleteTaxUseCase(shopProfileRepository);
const deleteChargeUseCase = new DeleteChargeUseCase(shopProfileRepository);

function rethrowOr(error: unknown, wrapped: AppError): never {
  if (error instanceof AppError) {
    throw error;
  }
  console.error(wrapped.message, error);
  throw wrapped;
}

function requestOrigin(request: Request): string {
  const protocol = request.protocol || "http";
  const host = request.get("host") || "localhost:4000";
  return `${protocol}://${host}`;
}

async function requireShopContext(request: Request) {
  const context = request.context!;
  if (context.appType !== "MOBILE" || !context.shopId) {
    throw new ForbiddenError("Invalid application scope.");
  }
  const shop = await shopProfileRepository.findShopById(context.shopId);
  if (!shop) {
    throw new NotFoundError("Shop not found.");
  }
  return shop;
}

async function requireOwnerShopContext(request: Request) {
  const context = request.context!;
  if (context.appType !== "MOBILE" || context.role !== "SHOP_OWNER" || !context.shopId) {
    throw new ForbiddenError("Only shop owners can manage quick setup.");
  }
  const shop = await shopProfileRepository.findShopById(context.shopId);
  if (!shop) {
    throw new NotFoundError("Shop not found.");
  }
  return shop;
}

async function requireShopFinanceReadContext(request: Request) {
  const context = request.context!;
  if (context.appType !== "MOBILE" || !context.shopId || !["SHOP_OWNER", "SALESMAN"].includes(context.role)) {
    throw new ForbiddenError("Only shop owner or salesman can view finance sources.");
  }
  const shop = await shopProfileRepository.findShopById(context.shopId);
  if (!shop) {
    throw new NotFoundError("Shop not found.");
  }
  if (context.role === "SALESMAN") {
    const membership = await shopProfileRepository.findSalesmanMembership(shop.id, context.userId);
    if (!membership) {
      throw new ForbiddenError("This salesman is not assigned to the selected shop.");
    }
  }
  return shop;
}

export const shopProfileController = {
  async list(request: Request, response: Response) {
    const context = request.context!;
    if (!["SUPER_ADMIN", "ADMIN"].includes(context.role)) {
      throw new ForbiddenError("You do not have permission to view shops.");
    }
    try {
      const shops = await listShopsUseCase.execute();
      response.json({ shops });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shops could not be loaded right now."));
    }
  },

  async getSettings(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const context = request.context!;
      const settings = await getShopSettingsUseCase.execute(shop.id, { id: context.userId, name: context.userName, phone: null, email: null });
      response.json(settings);
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop settings could not be loaded right now."));
    }
  },

  async updateSettings(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const context = request.context!;
      const body = request.body as any;
      const result = await updateShopSettingsUseCase.execute({
        shopId: shop.id,
        ownerId: context.userId,
        shopName: body.shopName,
        businessType: body.businessType,
        phone: body.phone,
        address: body.address,
        ownerName: body.ownerName,
        ownerPhone: body.ownerPhone,
        receipt: body.receipt,
      });
      response.json({ message: "Shop settings updated successfully.", ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop settings could not be updated right now."));
    }
  },

  async getFinanceSources(request: Request, response: Response) {
    try {
      const shop = await requireShopFinanceReadContext(request);
      const result = await getShopFinanceSourcesUseCase.execute(shop.id);
      response.json({ shop, ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop finance sources could not be loaded right now."));
    }
  },

  async createMoneyBox(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as any;
      const moneyBox = await createShopMoneyBoxUseCase.execute({ shopId: shop.id, ...body });
      response.status(201).json({ message: "Money box created successfully.", moneyBox });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Money box could not be created right now."));
    }
  },

  async updateMoneyBox(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as any;
      const moneyBox = await updateShopMoneyBoxUseCase.execute({ id: String(request.params.id), shopId: shop.id, ...body });
      response.json({ message: "Money box updated successfully.", moneyBox });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Money box could not be updated right now."));
    }
  },

  async createBankAccount(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as any;
      const bankAccount = await createShopBankAccountUseCase.execute({ shopId: shop.id, ...body });
      response.status(201).json({ message: "Bank account created successfully.", bankAccount });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Bank account could not be created right now."));
    }
  },

  async updateBankAccount(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as any;
      const bankAccount = await updateShopBankAccountUseCase.execute({ id: String(request.params.id), shopId: shop.id, ...body });
      response.json({ message: "Bank account updated successfully.", bankAccount });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Bank account could not be updated right now."));
    }
  },

  async getInventorySettings(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const inventory = await getShopInventorySettingsUseCase.execute(shop.id);
      response.json({ inventory });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop inventory settings could not be loaded right now."));
    }
  },

  async updateInventorySettings(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const inventory = await updateShopInventorySettingsUseCase.execute(shop.id, request.body ?? {});
      response.json({ message: "Shop inventory settings updated successfully.", inventory });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop inventory settings could not be updated right now."));
    }
  },

  async updateLogo(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const context = request.context!;
      const body = request.body as { logoUrl?: string | null };
      await updateShopLogoUseCase.execute(shop.id, body.logoUrl, requestOrigin(request));
      const settings = await getShopSettingsUseCase.execute(shop.id, { id: context.userId, name: context.userName, phone: null, email: null });
      response.json({ message: "Shop logo updated successfully.", ...settings });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop logo could not be updated right now."));
    }
  },

  async getQuickSetupCatalog(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const { FREE_TIER_PRODUCT_LIMIT } = await import("../../../subscription/access");
      const result = await getQuickSetupCatalogUseCase.execute(shop.id, FREE_TIER_PRODUCT_LIMIT);
      response.json({ shop, ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Quick setup products could not be loaded right now."));
    }
  },

  async listProducts(request: Request, response: Response) {
    try {
      const shop = await requireShopContext(request);
      const products = await listShopProductsUseCase.execute(shop.id);
      response.json({ shop, products });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Shop products could not be loaded right now."));
    }
  },

  async createLocalProduct(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const context = request.context!;
      const body = request.body as any;
      const result = await createLocalShopProductUseCase.execute({ shopId: shop.id, ownerId: context.userId, ...body });
      response.status(201).json({ message: "Shop product created successfully and sent for admin approval.", ...result });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Local shop product could not be created right now."));
    }
  },

  async selectQuickSetupProducts(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as { productIds?: string[] };
      const products = await selectQuickSetupProductsUseCase.execute(shop.id, body.productIds);
      response.status(201).json({ message: "Quick setup products selected successfully.", products: products.map((item) => ({ ...item, lowStockThreshold: item.lowStockLimit })) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Quick setup selection could not be saved right now."));
    }
  },

  async saveQuickSetupPricing(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as { items?: any[] };
      const products = await saveQuickSetupPricingUseCase.execute(shop.id, body.items);
      response.json({ message: "Opening stock and sale price saved successfully.", products: products.map((item) => ({ ...item, lowStockThreshold: item.lowStockLimit })) });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Quick setup pricing could not be saved right now."));
    }
  },

  async updateProduct(request: Request, response: Response) {
    try {
      const shop = await requireOwnerShopContext(request);
      const body = request.body as { stock?: number; price?: number; lowStockLimit?: number };
      const updated = await updateShopProductUseCase.execute(String(request.params.shopProductId), shop.id, body);

      response.json({
        message: "Shop product updated successfully.",
        product: {
          id: updated.source === "SHOP_LOCAL" ? updated.id : updated.masterProductId,
          shopProductId: updated.id,
          masterProductId: updated.masterProductId,
          sku: updated.masterProduct?.sku ?? updated.localBarcode ?? updated.id,
          name: updated.masterProduct?.name ?? updated.localName ?? "Unnamed product",
          packageSize: updated.masterProduct?.packageSize ?? updated.localUnit ?? updated.id,
          pictureUrl: updated.masterProduct?.pictureUrl ?? updated.localPictureUrl ?? null,
          price: Number(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price ?? 0),
          purchasePrice: Number(updated.purchasePrice ?? updated.masterProduct?.price ?? 0),
          stock: Number(updated.openingStock ?? 0),
          lowStockLimit: Number(updated.lowStockLimit ?? 0),
          category: updated.localCategory ?? "",
          brand: updated.localBrand ?? null,
          unit: updated.localUnit ?? null,
          barcode: updated.localBarcode ?? null,
          approvalStatus: updated.approvalRequest?.status ?? null,
        },
      });
    } catch (error) {
      rethrowOr(error, new ServiceUnavailableError("Failed to update shop product."));
    }
  },

  async getTaxesCharges(request: Request, response: Response) {
    const context = request.context!;
    if (context.appType !== "MOBILE" || !context.shopId) {
      throw new ForbiddenError("Only mobile clients can retrieve taxes and charges.");
    }
    const result = await getTaxesChargesUseCase.execute(context.shopId);
    response.json(result);
  },

  async createTax(request: Request, response: Response) {
    const shop = await requireOwnerShopContext(request);
    const body = request.body as { name?: string; rate?: number; type?: string };
    const tax = await createTaxUseCase.execute(shop.id, body.name, body.rate, body.type);
    response.status(201).json(tax);
  },

  async createCharge(request: Request, response: Response) {
    const shop = await requireOwnerShopContext(request);
    const body = request.body as { name?: string; amount?: number; type?: string };
    const charge = await createChargeUseCase.execute(shop.id, body.name, body.amount, body.type);
    response.status(201).json(charge);
  },

  async updateTax(request: Request, response: Response) {
    const shop = await requireOwnerShopContext(request);
    await updateTaxUseCase.execute(String(request.params.id), shop.id, request.body ?? {});
    response.json({ success: true });
  },

  async updateCharge(request: Request, response: Response) {
    const shop = await requireOwnerShopContext(request);
    await updateChargeUseCase.execute(String(request.params.id), shop.id, request.body ?? {});
    response.json({ success: true });
  },

  async deleteTax(request: Request, response: Response) {
    const shop = await requireOwnerShopContext(request);
    await deleteTaxUseCase.execute(String(request.params.id), shop.id);
    response.json({ success: true });
  },

  async deleteCharge(request: Request, response: Response) {
    const shop = await requireOwnerShopContext(request);
    await deleteChargeUseCase.execute(String(request.params.id), shop.id);
    response.json({ success: true });
  },
};
