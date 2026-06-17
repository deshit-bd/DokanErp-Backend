import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { canAddProductsToShop, countDistinctShopProducts, FREE_TIER_PRODUCT_LIMIT } from "../subscription/access";

const router = Router();

function toMoney(value: unknown) {
  return Number(value ?? 0);
}

function normalizeOptionalText(value: unknown) {
  const text = `${value ?? ""}`.trim();
  return text || null;
}

function toDisplayLabel(value: string) {
  return value.replace(/_/g, " ");
}

function mapFinanceSourceMoneyBox(moneyBox: any) {
  return {
    id: moneyBox.id,
    boxName: moneyBox.boxName,
    code: moneyBox.code,
    type: moneyBox.type,
    typeLabel: toDisplayLabel(moneyBox.type),
    openingBalance: toMoney(moneyBox.openingBalance),
    currentBalance: toMoney(moneyBox.currentBalance),
    details: moneyBox.details ?? null,
    status: moneyBox.status,
  };
}

function mapFinanceSourceBankAccount(bankAccount: any) {
  return {
    id: bankAccount.id,
    accountName: bankAccount.accountName,
    bankName: bankAccount.bankName,
    branchName: bankAccount.branchName ?? null,
    accountNumber: bankAccount.accountNumber,
    accountType: bankAccount.accountType,
    openingBalance: toMoney(bankAccount.openingBalance),
    currentBalance: toMoney(bankAccount.currentBalance),
    currency: bankAccount.currency,
    status: bankAccount.status,
    isDefault: Boolean(bankAccount.isDefault),
    notes: bankAccount.notes ?? null,
  };
}

function mapShopSettingsResponse(params: {
  shop: {
    id: string;
    shopCode: string | null;
    shopName: string;
    businessType: string | null;
    phone: string | null;
    address: string | null;
    logoUrl: string | null;
    status: string;
    receiptSetting?: {
      showLogo: boolean;
      showAddress: boolean;
      showPhone: boolean;
      showVatInfo: boolean;
    } | null;
    inventorySetting?: {
      lowStockDefault: number;
      lowStockGrocery: number;
      autoLowStockAlert: boolean;
      reduceStockOnSale: boolean;
      allowNegativeStock: boolean;
      requireBinAssignment: boolean;
      showBinDuringSale: boolean;
      demandBasedReorder: boolean;
      manualStockApproval: boolean;
      stockMethod: string;
    } | null;
  };
  owner: {
    id: string;
    name: string;
    phone: string | null;
    email: string | null;
  };
}) {
  return {
    shop: {
      id: params.shop.id,
      shopCode: params.shop.shopCode,
      shopName: params.shop.shopName,
      businessType: params.shop.businessType,
      phone: params.shop.phone,
      address: params.shop.address,
      logoUrl: params.shop.logoUrl,
      status: params.shop.status,
    },
    owner: {
      id: params.owner.id,
      name: params.owner.name,
      phone: params.owner.phone,
      email: params.owner.email,
    },
    receipt: {
      showPhone: params.shop.receiptSetting?.showPhone ?? true,
      showAddress: params.shop.receiptSetting?.showAddress ?? false,
      showLogo: params.shop.receiptSetting?.showLogo ?? false,
      showVatInfo: params.shop.receiptSetting?.showVatInfo ?? false,
    },
    inventory: params.shop.inventorySetting ? {
      lowStockDefault: params.shop.inventorySetting.lowStockDefault,
      lowStockGrocery: params.shop.inventorySetting.lowStockGrocery,
      autoLowStockAlert: params.shop.inventorySetting.autoLowStockAlert,
      reduceStockOnSale: params.shop.inventorySetting.reduceStockOnSale,
      allowNegativeStock: params.shop.inventorySetting.allowNegativeStock,
      requireBinAssignment: params.shop.inventorySetting.requireBinAssignment,
      showBinDuringSale: params.shop.inventorySetting.showBinDuringSale,
      demandBasedReorder: params.shop.inventorySetting.demandBasedReorder,
      manualStockApproval: params.shop.inventorySetting.manualStockApproval,
      stockMethod: params.shop.inventorySetting.stockMethod,
    } : {
      lowStockDefault: 10,
      lowStockGrocery: 5,
      autoLowStockAlert: true,
      reduceStockOnSale: true,
      allowNegativeStock: false,
      requireBinAssignment: false,
      showBinDuringSale: true,
      demandBasedReorder: false,
      manualStockApproval: false,
      stockMethod: "FIFO",
    },
  };
}

async function requireShopContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || !auth.payload.shopId) {
    return {
      status: 403,
      body: { message: "Invalid application scope." },
    };
  }

  const shop = await prisma.shop.findUnique({
    where: { id: auth.payload.shopId },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      businessType: true,
      status: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found." },
    };
  }

  return { auth, shop };
}

async function requireOwnerShopContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || auth.payload.role !== "SHOP_OWNER" || !auth.payload.shopId) {
    return {
      status: 403,
      body: { message: "Only shop owners can manage quick setup." },
    };
  }

  const shop = await prisma.shop.findUnique({
    where: { id: auth.payload.shopId },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      businessType: true,
      status: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found." },
    };
  }

  return { auth, shop };
}

async function requireShopFinanceReadContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || !auth.payload.shopId || !["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "Only shop owner or salesman can view finance sources." },
    };
  }

  const shop = await prisma.shop.findUnique({
    where: { id: auth.payload.shopId },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      businessType: true,
      status: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found." },
    };
  }

  if (auth.payload.role === "SALESMAN") {
    const membership = await prisma.shopUser.findFirst({
      where: {
        shopId: shop.id,
        userId: auth.user.id,
        role: "SALESMAN",
      },
      select: { id: true },
    });

    if (!membership) {
      return {
        status: 403,
        body: { message: "This salesman is not assigned to the selected shop." },
      };
    }
  }

  return { auth, shop };
}

router.get("/", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
      return response.status(403).json({ message: "You do not have permission to view shops." });
    }

    const shops = await prisma.shop.findMany({
      select: {
        id: true,
        shopCode: true,
        shopName: true,
        status: true,
      },
      orderBy: [{ shopName: "asc" }],
    });

    return response.json({
      shops: shops.map((shop) => ({
        id: shop.id,
        shopCode: shop.shopCode,
        shopName: shop.shopName,
        status: shop.status,
      })),
    });
  } catch (error) {
    console.error("Failed to load shops.", error);

    return response.status(503).json({
      message: "Shops could not be loaded right now.",
    });
  }
});

router.get("/me/settings", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const shop = await prisma.shop.findUnique({
      where: { id: context.shop.id },
      select: {
        id: true,
        shopCode: true,
        shopName: true,
        businessType: true,
        phone: true,
        address: true,
        logoUrl: true,
        status: true,
        receiptSetting: {
          select: {
            showLogo: true,
            showAddress: true,
            showPhone: true,
            showVatInfo: true,
          },
        },
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
      },
    });

    if (!shop) {
      return response.status(404).json({ message: "Shop not found." });
    }

    return response.json({
      ...mapShopSettingsResponse({
        shop,
        owner: context.auth.user,
      }),
      preferences: {
        language: "bn",
        theme: "light",
        currency: "BDT",
      },
    });
  } catch (error) {
    console.error("Failed to load shop settings.", error);

    return response.status(503).json({
      message: "Shop settings could not be loaded right now.",
    });
  }
});

router.get("/me/finance-sources", async (request, response) => {
  try {
    const context = await requireShopFinanceReadContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const [moneyBoxes, bankAccounts] = await Promise.all([
      (prisma as any).moneyBox.findMany({
        where: {
          shopId: context.shop.id,
          status: "ACTIVE",
        },
        orderBy: [{ type: "asc" }, { createdAt: "asc" }],
      }),
      (prisma as any).bankAccount.findMany({
        where: {
          shopId: context.shop.id,
          status: "ACTIVE",
        },
        orderBy: [{ isDefault: "desc" }, { createdAt: "asc" }],
      }),
    ]);

    return response.json({
      shop: context.shop,
      moneyBoxes: moneyBoxes.map(mapFinanceSourceMoneyBox),
      bankAccounts: bankAccounts.map(mapFinanceSourceBankAccount),
    });
  } catch (error) {
    console.error("Failed to load shop finance sources.", error);

    return response.status(503).json({
      message: "Shop finance sources could not be loaded right now.",
    });
  }
});

router.post("/me/money-boxes", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      boxName?: string;
      code?: string;
      type?: "CASH" | "BKASH" | "NAGAD";
      openingBalance?: number | string;
      details?: string | null;
      status?: "ACTIVE" | "INACTIVE";
    };

    const boxName = `${body.boxName ?? ""}`.trim();
    const code = `${body.code ?? ""}`.trim();
    const type = body.type;
    const details = normalizeOptionalText(body.details);
    const status = body.status ?? "ACTIVE";
    const openingBalance = Number(body.openingBalance ?? 0);

    if (!boxName || !code || !type) {
      return response.status(400).json({ message: "boxName, code, and type are required." });
    }

    if (!Number.isFinite(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const existingCode = await (prisma as any).moneyBox.findUnique({
      where: { code },
      select: { id: true },
    });

    if (existingCode) {
      return response.status(409).json({ message: "Money box code already exists." });
    }

    const moneyBox = await (prisma as any).moneyBox.create({
      data: {
        shopId: context.shop.id,
        boxName,
        code,
        type,
        openingBalance,
        currentBalance: openingBalance,
        details,
        status,
      },
    });

    return response.status(201).json({
      message: "Money box created successfully.",
      moneyBox: mapFinanceSourceMoneyBox(moneyBox),
    });
  } catch (error) {
    console.error("Failed to create shop money box.", error);

    return response.status(503).json({
      message: "Money box could not be created right now.",
    });
  }
});

router.put("/me/money-boxes/:id", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const existing = await (prisma as any).moneyBox.findFirst({
      where: {
        id: request.params.id,
        shopId: context.shop.id,
      },
    });

    if (!existing) {
      return response.status(404).json({ message: "Money box not found in this shop." });
    }

    const body = request.body as {
      boxName?: string;
      code?: string;
      type?: "CASH" | "BKASH" | "NAGAD";
      openingBalance?: number | string;
      details?: string | null;
      status?: "ACTIVE" | "INACTIVE";
    };

    const boxName = `${body.boxName ?? existing.boxName ?? ""}`.trim();
    const code = `${body.code ?? existing.code ?? ""}`.trim();
    const type = body.type ?? existing.type;
    const details = body.details === undefined ? existing.details : normalizeOptionalText(body.details);
    const status = body.status ?? existing.status;
    const openingBalance = body.openingBalance === undefined ? Number(existing.openingBalance ?? 0) : Number(body.openingBalance ?? 0);

    if (!boxName || !code || !type) {
      return response.status(400).json({ message: "boxName, code, and type are required." });
    }

    if (!Number.isFinite(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const duplicateCode = await (prisma as any).moneyBox.findFirst({
      where: {
        code,
        id: { not: existing.id },
      },
      select: { id: true },
    });

    if (duplicateCode) {
      return response.status(409).json({ message: "Money box code already exists." });
    }

    const openingDelta = openingBalance - Number(existing.openingBalance ?? 0);

    const updated = await (prisma as any).moneyBox.update({
      where: { id: existing.id },
      data: {
        boxName,
        code,
        type,
        details,
        status,
        openingBalance,
        currentBalance: Number(existing.currentBalance ?? 0) + openingDelta,
      },
    });

    return response.json({
      message: "Money box updated successfully.",
      moneyBox: mapFinanceSourceMoneyBox(updated),
    });
  } catch (error) {
    console.error("Failed to update shop money box.", error);

    return response.status(503).json({
      message: "Money box could not be updated right now.",
    });
  }
});

router.post("/me/bank-accounts", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      accountName?: string;
      bankName?: string;
      branchName?: string | null;
      accountNumber?: string;
      accountType?: "CURRENT" | "SAVINGS";
      openingBalance?: number | string;
      currency?: string;
      status?: "ACTIVE" | "INACTIVE" | "CLOSED";
      isDefault?: boolean;
      notes?: string | null;
    };

    const accountName = `${body.accountName ?? ""}`.trim();
    const bankName = `${body.bankName ?? ""}`.trim();
    const branchName = normalizeOptionalText(body.branchName);
    const accountNumber = `${body.accountNumber ?? ""}`.trim();
    const accountType = body.accountType;
    const openingBalance = Number(body.openingBalance ?? 0);
    const currency = `${body.currency ?? "BDT"}`.trim().toUpperCase() || "BDT";
    const status = body.status ?? "ACTIVE";
    const isDefault = Boolean(body.isDefault);
    const notes = normalizeOptionalText(body.notes);

    if (!accountName || !bankName || !accountNumber || !accountType) {
      return response.status(400).json({ message: "accountName, bankName, accountNumber, and accountType are required." });
    }

    if (!Number.isFinite(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const existingAccount = await (prisma as any).bankAccount.findFirst({
      where: {
        bankName,
        accountNumber,
      },
      select: { id: true },
    });

    if (existingAccount) {
      return response.status(409).json({ message: "A bank account with this bank and account number already exists." });
    }

    const created = await prisma.$transaction(async (transaction) => {
      if (isDefault) {
        await (transaction as any).bankAccount.updateMany({
          where: { shopId: context.shop.id },
          data: { isDefault: false },
        });
      }

      return (transaction as any).bankAccount.create({
        data: {
          shopId: context.shop.id,
          accountName,
          bankName,
          branchName,
          accountNumber,
          accountType,
          openingBalance,
          currentBalance: openingBalance,
          currency,
          status,
          isDefault,
          notes,
        },
      });
    });

    return response.status(201).json({
      message: "Bank account created successfully.",
      bankAccount: mapFinanceSourceBankAccount(created),
    });
  } catch (error) {
    console.error("Failed to create shop bank account.", error);

    return response.status(503).json({
      message: "Bank account could not be created right now.",
    });
  }
});

router.put("/me/bank-accounts/:id", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const existing = await (prisma as any).bankAccount.findFirst({
      where: {
        id: request.params.id,
        shopId: context.shop.id,
      },
    });

    if (!existing) {
      return response.status(404).json({ message: "Bank account not found in this shop." });
    }

    const body = request.body as {
      accountName?: string;
      bankName?: string;
      branchName?: string | null;
      accountNumber?: string;
      accountType?: "CURRENT" | "SAVINGS";
      openingBalance?: number | string;
      currency?: string;
      status?: "ACTIVE" | "INACTIVE" | "CLOSED";
      isDefault?: boolean;
      notes?: string | null;
    };

    const accountName = `${body.accountName ?? existing.accountName ?? ""}`.trim();
    const bankName = `${body.bankName ?? existing.bankName ?? ""}`.trim();
    const branchName = body.branchName === undefined ? existing.branchName : normalizeOptionalText(body.branchName);
    const accountNumber = `${body.accountNumber ?? existing.accountNumber ?? ""}`.trim();
    const accountType = body.accountType ?? existing.accountType;
    const openingBalance = body.openingBalance === undefined ? Number(existing.openingBalance ?? 0) : Number(body.openingBalance ?? 0);
    const currency = `${body.currency ?? existing.currency ?? "BDT"}`.trim().toUpperCase() || "BDT";
    const status = body.status ?? existing.status;
    const isDefault = body.isDefault === undefined ? Boolean(existing.isDefault) : Boolean(body.isDefault);
    const notes = body.notes === undefined ? existing.notes : normalizeOptionalText(body.notes);

    if (!accountName || !bankName || !accountNumber || !accountType) {
      return response.status(400).json({ message: "accountName, bankName, accountNumber, and accountType are required." });
    }

    if (!Number.isFinite(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const duplicateAccount = await (prisma as any).bankAccount.findFirst({
      where: {
        bankName,
        accountNumber,
        id: { not: existing.id },
      },
      select: { id: true },
    });

    if (duplicateAccount) {
      return response.status(409).json({ message: "A bank account with this bank and account number already exists." });
    }

    const updated = await prisma.$transaction(async (transaction) => {
      if (isDefault) {
        await (transaction as any).bankAccount.updateMany({
          where: { shopId: context.shop.id, id: { not: existing.id } },
          data: { isDefault: false },
        });
      }

      const openingDelta = openingBalance - Number(existing.openingBalance ?? 0);

      return (transaction as any).bankAccount.update({
        where: { id: existing.id },
        data: {
          accountName,
          bankName,
          branchName,
          accountNumber,
          accountType,
          openingBalance,
          currentBalance: Number(existing.currentBalance ?? 0) + openingDelta,
          currency,
          status,
          isDefault,
          notes,
        },
      });
    });

    return response.json({
      message: "Bank account updated successfully.",
      bankAccount: mapFinanceSourceBankAccount(updated),
    });
  } catch (error) {
    console.error("Failed to update shop bank account.", error);

    return response.status(503).json({
      message: "Bank account could not be updated right now.",
    });
  }
});

router.patch("/me/settings", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      shopName?: string;
      businessType?: string | null;
      phone?: string | null;
      address?: string | null;
      ownerName?: string;
      ownerPhone?: string | null;
      receipt?: {
        showPhone?: boolean;
        showAddress?: boolean;
        showLogo?: boolean;
        showVatInfo?: boolean;
      };
    };

    const shopName = body.shopName?.trim();
    const ownerName = body.ownerName?.trim();
    const phone = normalizeOptionalText(body.phone);
    const address = normalizeOptionalText(body.address);
    const businessType = normalizeOptionalText(body.businessType);
    const ownerPhone = normalizeOptionalText(body.ownerPhone);

    if (!shopName) {
      return response.status(400).json({ message: "Shop name is required." });
    }

    if (!ownerName) {
      return response.status(400).json({ message: "Owner name is required." });
    }

    const duplicateShopPhone = phone
      ? await prisma.shop.findFirst({
          where: {
            phone,
            id: { not: context.shop.id },
          },
          select: { id: true },
        })
      : null;

    if (duplicateShopPhone) {
      return response.status(409).json({ message: "Shop mobile number is already in use." });
    }

    const duplicateOwnerPhone = ownerPhone
      ? await prisma.user.findFirst({
          where: {
            phone: ownerPhone,
            id: { not: context.auth.user.id },
          },
          select: { id: true },
        })
      : null;

    if (duplicateOwnerPhone) {
      return response.status(409).json({ message: "Owner mobile number is already in use." });
    }

    const updated = await prisma.$transaction(async (tx) => {
      const shop = await tx.shop.update({
        where: { id: context.shop.id },
        data: {
          shopName,
          businessType,
          phone,
          address,
        },
        select: {
          id: true,
          shopCode: true,
          shopName: true,
          businessType: true,
          phone: true,
          address: true,
          logoUrl: true,
          status: true,
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
        },
      });

      const owner = await tx.user.update({
        where: { id: context.auth.user.id },
        data: {
          name: ownerName,
          phone: ownerPhone,
        },
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
        },
      });

      const receipt = await tx.shopReceiptSetting.upsert({
        where: { shopId: context.shop.id },
        update: {
          showPhone: body.receipt?.showPhone ?? true,
          showAddress: body.receipt?.showAddress ?? false,
          showLogo: body.receipt?.showLogo ?? false,
          showVatInfo: body.receipt?.showVatInfo ?? false,
        },
        create: {
          shopId: context.shop.id,
          showPhone: body.receipt?.showPhone ?? true,
          showAddress: body.receipt?.showAddress ?? false,
          showLogo: body.receipt?.showLogo ?? false,
          showVatInfo: body.receipt?.showVatInfo ?? false,
        },
        select: {
          showLogo: true,
          showAddress: true,
          showPhone: true,
          showVatInfo: true,
        },
      });

      return {
        shop: {
          ...shop,
          receiptSetting: receipt,
        },
        owner,
      };
    });

    return response.json({
      message: "Shop settings updated successfully.",
      ...mapShopSettingsResponse(updated),
      preferences: {
        language: "bn",
        theme: "light",
        currency: "BDT",
      },
    });
  } catch (error) {
    console.error("Failed to update shop settings.", error);

    return response.status(503).json({
      message: "Shop settings could not be updated right now.",
    });
  }
});

router.get("/me/inventory-settings", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const inventorySetting = await prisma.shopInventorySetting.findUnique({
      where: { shopId: context.shop.id },
    });

    const settings = inventorySetting ? {
      lowStockDefault: inventorySetting.lowStockDefault,
      lowStockGrocery: inventorySetting.lowStockGrocery,
      autoLowStockAlert: inventorySetting.autoLowStockAlert,
      reduceStockOnSale: inventorySetting.reduceStockOnSale,
      allowNegativeStock: inventorySetting.allowNegativeStock,
      requireBinAssignment: inventorySetting.requireBinAssignment,
      showBinDuringSale: inventorySetting.showBinDuringSale,
      demandBasedReorder: inventorySetting.demandBasedReorder,
      manualStockApproval: inventorySetting.manualStockApproval,
      stockMethod: inventorySetting.stockMethod,
    } : {
      lowStockDefault: 10,
      lowStockGrocery: 5,
      autoLowStockAlert: true,
      reduceStockOnSale: true,
      allowNegativeStock: false,
      requireBinAssignment: false,
      showBinDuringSale: true,
      demandBasedReorder: false,
      manualStockApproval: false,
      stockMethod: "FIFO",
    };

    return response.json({
      inventory: settings,
    });
  } catch (error) {
    console.error("Failed to load shop inventory settings.", error);
    return response.status(503).json({
      message: "Shop inventory settings could not be loaded right now.",
    });
  }
});

router.patch("/me/inventory-settings", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      lowStockDefault?: number;
      lowStockGrocery?: number;
      autoLowStockAlert?: boolean;
      reduceStockOnSale?: boolean;
      allowNegativeStock?: boolean;
      requireBinAssignment?: boolean;
      showBinDuringSale?: boolean;
      demandBasedReorder?: boolean;
      manualStockApproval?: boolean;
      stockMethod?: string;
    };

    if (body.stockMethod !== undefined && body.stockMethod !== "FIFO" && body.stockMethod !== "LIFO") {
      return response.status(400).json({
        message: "Invalid stock calculation method. Must be 'FIFO' or 'LIFO'.",
      });
    }

    const updated = await prisma.shopInventorySetting.upsert({
      where: { shopId: context.shop.id },
      update: {
        lowStockDefault: body.lowStockDefault !== undefined ? Number(body.lowStockDefault) : undefined,
        lowStockGrocery: body.lowStockGrocery !== undefined ? Number(body.lowStockGrocery) : undefined,
        autoLowStockAlert: body.autoLowStockAlert !== undefined ? !!body.autoLowStockAlert : undefined,
        reduceStockOnSale: body.reduceStockOnSale !== undefined ? !!body.reduceStockOnSale : undefined,
        allowNegativeStock: body.allowNegativeStock !== undefined ? !!body.allowNegativeStock : undefined,
        requireBinAssignment: body.requireBinAssignment !== undefined ? !!body.requireBinAssignment : undefined,
        showBinDuringSale: body.showBinDuringSale !== undefined ? !!body.showBinDuringSale : undefined,
        demandBasedReorder: body.demandBasedReorder !== undefined ? !!body.demandBasedReorder : undefined,
        manualStockApproval: body.manualStockApproval !== undefined ? !!body.manualStockApproval : undefined,
        stockMethod: body.stockMethod !== undefined ? String(body.stockMethod) : undefined,
      },
      create: {
        shopId: context.shop.id,
        lowStockDefault: body.lowStockDefault !== undefined ? Number(body.lowStockDefault) : 10,
        lowStockGrocery: body.lowStockGrocery !== undefined ? Number(body.lowStockGrocery) : 5,
        autoLowStockAlert: body.autoLowStockAlert !== undefined ? !!body.autoLowStockAlert : true,
        reduceStockOnSale: body.reduceStockOnSale !== undefined ? !!body.reduceStockOnSale : true,
        allowNegativeStock: body.allowNegativeStock !== undefined ? !!body.allowNegativeStock : false,
        requireBinAssignment: body.requireBinAssignment !== undefined ? !!body.requireBinAssignment : false,
        showBinDuringSale: body.showBinDuringSale !== undefined ? !!body.showBinDuringSale : true,
        demandBasedReorder: body.demandBasedReorder !== undefined ? !!body.demandBasedReorder : false,
        manualStockApproval: body.manualStockApproval !== undefined ? !!body.manualStockApproval : false,
        stockMethod: body.stockMethod !== undefined ? String(body.stockMethod) : "FIFO",
      },
    });

    return response.json({
      message: "Shop inventory settings updated successfully.",
      inventory: {
        lowStockDefault: updated.lowStockDefault,
        lowStockGrocery: updated.lowStockGrocery,
        autoLowStockAlert: updated.autoLowStockAlert,
        reduceStockOnSale: updated.reduceStockOnSale,
        allowNegativeStock: updated.allowNegativeStock,
        requireBinAssignment: updated.requireBinAssignment,
        showBinDuringSale: updated.showBinDuringSale,
        demandBasedReorder: updated.demandBasedReorder,
        manualStockApproval: updated.manualStockApproval,
        stockMethod: updated.stockMethod,
      },
    });
  } catch (error) {
    console.error("Failed to update shop inventory settings.", error);
    return response.status(503).json({
      message: "Shop inventory settings could not be updated right now.",
    });
  }
});

router.patch("/me/logo", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as { logoUrl?: string | null };
    const logoUrl = normalizeOptionalText(body.logoUrl);

    const shop = await prisma.shop.update({
      where: { id: context.shop.id },
      data: {
        logoUrl,
      },
      select: {
        id: true,
        shopCode: true,
        shopName: true,
        businessType: true,
        phone: true,
        address: true,
        logoUrl: true,
        status: true,
        receiptSetting: {
          select: {
            showLogo: true,
            showAddress: true,
            showPhone: true,
            showVatInfo: true,
          },
        },
      },
    });

    return response.json({
      message: "Shop logo updated successfully.",
      ...mapShopSettingsResponse({
        shop,
        owner: context.auth.user,
      }),
    });
  } catch (error) {
    console.error("Failed to update shop logo.", error);

    return response.status(503).json({
      message: "Shop logo could not be updated right now.",
    });
  }
});

router.get("/quick-setup/catalog", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const [suggestedProducts, configuredProducts, configuredProductCount] = await Promise.all([
      (prisma as any).masterProduct.findMany({
        where: {
          status: "ACTIVE",
        },
        orderBy: [{ name: "asc" }],
        take: 8,
        select: {
          id: true,
          sku: true,
          name: true,
          price: true,
          suggestedPrice: true,
          packageSize: true,
        },
      }),
      (prisma as any).shopProduct.findMany({
        where: { shopId: context.shop.id, masterProductId: { not: null } },
        include: {
          masterProduct: {
            select: {
              id: true,
              sku: true,
              name: true,
              packageSize: true,
              price: true,
              suggestedPrice: true,
            },
          },
        },
        orderBy: [{ createdAt: "asc" }],
      }),
      countDistinctShopProducts(context.shop.id),
    ]);

    const selectedProductIds = new Set(
      configuredProducts.map((item: { masterProductId: string }) => item.masterProductId),
    );

    return response.json({
      shop: context.shop,
      limits: {
        freeTierProductLimit: FREE_TIER_PRODUCT_LIMIT,
        configuredProductCount,
      },
      suggestedProducts: suggestedProducts.map((product: any) => ({
        id: product.id,
        sku: product.sku,
        name: product.name,
        packageSize: product.packageSize,
        price: toMoney(product.price),
        suggestedPrice: toMoney(product.suggestedPrice ?? product.price),
        selected: selectedProductIds.has(product.id),
      })),
      configuredProducts: configuredProducts.map((item: any) => ({
        masterProductId: item.masterProductId,
        name: item.masterProduct.name,
        sku: item.masterProduct.sku,
        packageSize: item.masterProduct.packageSize,
        openingStock: toMoney(item.openingStock),
        salePrice: toMoney(item.salePrice ?? item.masterProduct.suggestedPrice ?? item.masterProduct.price),
      })),
    });
  } catch (error) {
    console.error("Failed to load quick setup catalog.", error);

    return response.status(503).json({
      message: "Quick setup products could not be loaded right now.",
    });
  }
});

router.get("/products", async (request, response) => {
  try {
    const context = await requireShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const shopProducts = await (prisma as any).shopProduct.findMany({
      where: { shopId: context.shop.id },
      include: {
        masterProduct: {
          select: {
            id: true,
            sku: true,
            name: true,
            packageSize: true,
            pictureUrl: true,
            price: true,
            suggestedPrice: true,
            status: true,
          },
        },
        approvalRequest: {
          select: {
            id: true,
            status: true,
          },
        },
      },
      orderBy: [{ createdAt: "asc" }],
    });

    const configuredMasterProductIds = shopProducts.map((item: any) => item.masterProductId);

    const masterProducts = await (prisma as any).masterProduct.findMany({
      where: {
        status: "ACTIVE",
        ...(configuredMasterProductIds.length
          ? { id: { notIn: configuredMasterProductIds } }
          : {}),
      },
      select: {
        id: true,
        sku: true,
        name: true,
        packageSize: true,
        pictureUrl: true,
        price: true,
        suggestedPrice: true,
        status: true,
      },
      orderBy: [{ name: "asc" }],
      take: 100,
    });

    return response.json({
      shop: context.shop,
      products: [
        ...shopProducts.map((item: any) => ({
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
        })),
        ...masterProducts.map((item: any) => ({
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
        })),
      ],
    });
  } catch (error) {
    console.error("Failed to load shop products.", error);

    return response.status(503).json({
      message: "Shop products could not be loaded right now.",
    });
  }
});

router.post("/products/local", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      name?: string;
      category?: string | null;
      brand?: string | null;
      unit?: string | null;
      barcode?: string | null;
      pictureUrl?: string | null;
      salePrice?: number | string | null;
      purchasePrice?: number | string | null;
      openingStock?: number | string | null;
      lowStockLimit?: number | string | null;
    };

    const name = body.name?.trim();
    const category = body.category?.trim() || null;
    const brand = body.brand?.trim() || null;
    const unit = body.unit?.trim() || null;
    const barcode = body.barcode?.trim() || null;
    const pictureUrl = body.pictureUrl?.trim() || null;
    const salePrice = body.salePrice == null || body.salePrice === "" ? null : Number(body.salePrice);
    const purchasePrice = body.purchasePrice == null || body.purchasePrice === "" ? null : Number(body.purchasePrice);
    const openingStock = body.openingStock == null || body.openingStock === "" ? 0 : Number(body.openingStock);
    const lowStockLimit = body.lowStockLimit == null || body.lowStockLimit === "" ? 0 : Number(body.lowStockLimit);

    if (!name) {
      return response.status(400).json({ message: "Product name is required." });
    }

    if (!category) {
      return response.status(400).json({ message: "Category is required." });
    }

    if (!unit) {
      return response.status(400).json({ message: "Unit is required." });
    }

    if (!Number.isFinite(openingStock) || openingStock < 0) {
      return response.status(400).json({ message: "Opening stock must be a valid number." });
    }

    if (!Number.isFinite(lowStockLimit) || lowStockLimit < 0) {
      return response.status(400).json({ message: "Low stock limit must be a valid number." });
    }

    if (salePrice != null && (!Number.isFinite(salePrice) || salePrice < 0)) {
      return response.status(400).json({ message: "Sale price must be a valid number." });
    }

    if (purchasePrice != null && (!Number.isFinite(purchasePrice) || purchasePrice < 0)) {
      return response.status(400).json({ message: "Purchase price must be a valid number." });
    }

    const existingLocalBarcode = barcode
      ? await (prisma as any).shopProduct.findFirst({
          where: {
            shopId: context.shop.id,
            OR: [{ localBarcode: barcode }, { masterProduct: { barcodes: { some: { barcode } } } }],
          },
          select: { id: true },
        })
      : null;

    if (existingLocalBarcode) {
      return response.status(409).json({ message: "Barcode already exists in this shop." });
    }

    const created = await (prisma as any).$transaction(async (tx: any) => {
      const requestRow = await tx.masterProductRequest.create({
        data: {
          shopId: context.shop.id,
          createdByUserId: context.auth.user.id,
          name,
          category,
          brand,
          unit,
          barcode,
          pictureUrl,
          purchasePrice,
          salePrice,
          openingStock,
          lowStockLimit,
          status: "PENDING",
        },
      });

      const shopProduct = await tx.shopProduct.create({
        data: {
          shopId: context.shop.id,
          source: "SHOP_LOCAL",
          localName: name,
          localCategory: category,
          localBrand: brand,
          localUnit: unit,
          localBarcode: barcode,
          localPictureUrl: pictureUrl,
          openingStock,
          lowStockLimit,
          salePrice,
          purchasePrice,
          approvalRequestId: requestRow.id,
        },
      });

      const linkedRequest = await tx.masterProductRequest.update({
        where: { id: requestRow.id },
        data: { shopProductId: shopProduct.id },
      });

      return { shopProduct, request: linkedRequest };
    });

    return response.status(201).json({
      message: "Shop product created successfully and sent for admin approval.",
      product: {
        id: created.shopProduct.id,
        shopProductId: created.shopProduct.id,
        masterProductId: null,
        name,
        sku: barcode || created.shopProduct.id,
        packageSize: unit,
        pictureUrl,
        price: salePrice,
        purchasePrice,
        suggestedPrice: salePrice,
        stock: openingStock,
        lowStockLimit,
        category,
        brand,
        unit,
        barcode,
        source: "SHOP_LOCAL",
        approvalStatus: "PENDING",
      },
      approvalRequest: {
        id: created.request.id,
        status: created.request.status,
      },
    });
  } catch (error) {
    console.error("Failed to create local shop product.", error);
    return response.status(503).json({ message: "Local shop product could not be created right now." });
  }
});

router.post("/quick-setup/catalog/select", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      productIds?: string[];
    };

    const productIds = Array.isArray(body.productIds)
      ? [...new Set(body.productIds.map((item) => `${item}`.trim()).filter(Boolean))]
      : [];

    if (productIds.length === 0) {
      return response.status(400).json({ message: "At least one product must be selected." });
    }

    const products = await (prisma as any).masterProduct.findMany({
      where: {
        id: { in: productIds },
        status: "ACTIVE",
      },
      select: {
        id: true,
        sku: true,
        name: true,
        price: true,
        suggestedPrice: true,
      },
    });

    if (products.length !== productIds.length) {
      return response.status(400).json({ message: "One or more selected products do not exist." });
    }

    const productAccess = await canAddProductsToShop(context.shop.id, productIds);

    if (!productAccess.allowed) {
      return response.status(productAccess.access?.tier === "BLOCKED" ? 402 : 403).json({
        message: productAccess.message,
        subscription: productAccess.access,
        currentProductCount: productAccess.currentProductCount,
        nextProductCount: productAccess.nextProductCount,
      });
    }

    const selectedProducts = await (prisma as any).$transaction(async (tx: any) => {
      for (const product of products) {
        await tx.shopProduct.upsert({
          where: {
            shopId_masterProductId: {
              shopId: context.shop.id,
              masterProductId: product.id,
            },
          },
          update: {},
          create: {
            shopId: context.shop.id,
            masterProductId: product.id,
            openingStock: 0,
            salePrice: product.suggestedPrice ?? product.price ?? 0,
          },
        });
      }

      return tx.shopProduct.findMany({
        where: {
          shopId: context.shop.id,
          masterProductId: { in: productIds },
        },
        include: {
          masterProduct: {
            select: {
              id: true,
              sku: true,
              name: true,
              packageSize: true,
              price: true,
              suggestedPrice: true,
            },
          },
        },
      });
    });

    return response.status(201).json({
      message: "Quick setup products selected successfully.",
      products: selectedProducts.map((item: any) => ({
        masterProductId: item.masterProductId,
        name: item.masterProduct.name,
        sku: item.masterProduct.sku,
        packageSize: item.masterProduct.packageSize,
        openingStock: toMoney(item.openingStock),
        salePrice: toMoney(item.salePrice ?? item.masterProduct.suggestedPrice ?? item.masterProduct.price),
      })),
    });
  } catch (error) {
    console.error("Failed to save quick setup selection.", error);

    return response.status(503).json({
      message: "Quick setup selection could not be saved right now.",
    });
  }
});

router.patch("/quick-setup/catalog/pricing", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      items?: Array<{
        masterProductId?: string;
        openingStock?: number | string | null;
        salePrice?: number | string | null;
      }>;
    };

    const items = Array.isArray(body.items) ? body.items : [];

    if (items.length === 0) {
      return response.status(400).json({ message: "At least one pricing item is required." });
    }

    const normalizedItems = items.map((item) => ({
      masterProductId: item.masterProductId?.trim() || "",
      openingStock: Number(item.openingStock ?? 0),
      salePrice: Number(item.salePrice ?? 0),
    }));

    if (
      normalizedItems.some(
        (item) =>
          !item.masterProductId ||
          !Number.isFinite(item.openingStock) ||
          item.openingStock < 0 ||
          !Number.isFinite(item.salePrice) ||
          item.salePrice < 0,
      )
    ) {
      return response.status(400).json({ message: "Each setup item requires a valid product, stock, and sale price." });
    }

    const configuredProducts = await (prisma as any).shopProduct.findMany({
      where: {
        shopId: context.shop.id,
        masterProductId: { in: normalizedItems.map((item) => item.masterProductId) },
      },
      select: {
        masterProductId: true,
      },
    });

    if (configuredProducts.length !== normalizedItems.length) {
      return response.status(400).json({ message: "Select the products first before setting stock and price." });
    }

    const updatedProducts = await (prisma as any).$transaction(async (tx: any) => {
      for (const item of normalizedItems) {
        await tx.shopProduct.update({
          where: {
            shopId_masterProductId: {
              shopId: context.shop.id,
              masterProductId: item.masterProductId,
            },
          },
          data: {
            openingStock: item.openingStock,
            salePrice: item.salePrice,
          },
        });
      }

      return tx.shopProduct.findMany({
        where: {
          shopId: context.shop.id,
          masterProductId: { in: normalizedItems.map((item) => item.masterProductId) },
        },
        include: {
          masterProduct: {
            select: {
              id: true,
              sku: true,
              name: true,
              packageSize: true,
            },
          },
        },
      });
    });

    return response.json({
      message: "Opening stock and sale price saved successfully.",
      products: updatedProducts.map((item: any) => ({
        masterProductId: item.masterProductId,
        name: item.masterProduct.name,
        sku: item.masterProduct.sku,
        packageSize: item.masterProduct.packageSize,
        openingStock: toMoney(item.openingStock),
        salePrice: toMoney(item.salePrice),
      })),
    });
  } catch (error) {
    console.error("Failed to save quick setup pricing.", error);

    return response.status(503).json({
      message: "Quick setup pricing could not be saved right now.",
    });
  }
});

router.patch("/products/:shopProductId", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const { shopProductId } = request.params;
    const body = request.body as {
      stock?: number;
      price?: number;
      lowStockLimit?: number;
    };

    const shopProduct = await (prisma as any).shopProduct.findUnique({
      where: { id: shopProductId },
    });

    if (!shopProduct || shopProduct.shopId !== context.shop.id) {
      return response.status(404).json({ message: "Shop product not found." });
    }

    const updateData: any = {};
    if (body.stock !== undefined) {
      updateData.openingStock = body.stock;
    }
    if (body.price !== undefined) {
      updateData.salePrice = body.price;
    }
    if (body.lowStockLimit !== undefined) {
      updateData.lowStockLimit = body.lowStockLimit;
    }

    const updated = await (prisma as any).shopProduct.update({
      where: { id: shopProductId },
      data: updateData,
      include: {
        masterProduct: true,
        approvalRequest: {
          select: {
            id: true,
            status: true,
          }
        }
      }
    });

    return response.json({
      message: "Shop product updated successfully.",
      product: {
        id: updated.source === "SHOP_LOCAL" ? updated.id : updated.masterProductId,
        shopProductId: updated.id,
        masterProductId: updated.masterProductId,
        sku: updated.masterProduct?.sku ?? updated.localBarcode ?? updated.id,
        name: updated.masterProduct?.name ?? updated.localName ?? "Unnamed product",
        packageSize: updated.masterProduct?.packageSize ?? updated.localUnit ?? updated.id,
        pictureUrl: updated.masterProduct?.pictureUrl ?? updated.localPictureUrl ?? null,
        price: toMoney(updated.salePrice ?? updated.masterProduct?.suggestedPrice ?? updated.masterProduct?.price),
        purchasePrice: toMoney(updated.purchasePrice ?? updated.masterProduct?.price),
        stock: Number(updated.openingStock ?? 0),
        lowStockLimit: Number(updated.lowStockLimit ?? 0),
        category: updated.localCategory ?? "",
        brand: updated.localBrand ?? null,
        unit: updated.localUnit ?? null,
        barcode: updated.localBarcode ?? null,
        approvalStatus: updated.approvalRequest?.status ?? null,
      }
    });
  } catch (error) {
    console.error("Failed to update shop product:", error);
    return response.status(503).json({ message: "Failed to update shop product." });
  }
});

router.get("/me/taxes-charges", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const shopId = context.shop.id;

    const taxes = await prisma.shopTax.findMany({
      where: { shopId },
      orderBy: { createdAt: "asc" },
    });

    const charges = await prisma.shopCharge.findMany({
      where: { shopId },
      orderBy: { createdAt: "asc" },
    });

    return response.json({ taxes, charges });
  } catch (error) {
    console.error("Failed to fetch taxes and charges:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

router.post("/me/taxes", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const { name, rate, type } = request.body;

    if (!name || rate === undefined) {
      return response.status(400).json({ message: "Name and rate are required." });
    }

    const tax = await prisma.shopTax.create({
      data: {
        shopId: context.shop.id,
        name,
        rate: Number(rate),
        type: type || "PERCENTAGE",
        isActive: true,
      },
    });

    return response.status(201).json(tax);
  } catch (error) {
    console.error("Failed to create tax:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

router.post("/me/charges", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const { name, amount, type } = request.body;

    if (!name || amount === undefined) {
      return response.status(400).json({ message: "Name and amount are required." });
    }

    const charge = await prisma.shopCharge.create({
      data: {
        shopId: context.shop.id,
        name,
        amount: Number(amount),
        type: type || "FIXED",
        isActive: true,
      },
    });

    return response.status(201).json(charge);
  } catch (error) {
    console.error("Failed to create charge:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

router.patch("/me/taxes/:id", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const { id } = request.params;
    const { isActive, name, rate } = request.body;

    await prisma.shopTax.updateMany({
      where: { id, shopId: context.shop.id },
      data: {
        ...(isActive !== undefined && { isActive }),
        ...(name && { name }),
        ...(rate !== undefined && { rate: Number(rate) }),
      },
    });

    return response.json({ success: true });
  } catch (error) {
    console.error("Failed to update tax:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

router.patch("/me/charges/:id", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const { id } = request.params;
    const { isActive, name, amount, type } = request.body;

    await prisma.shopCharge.updateMany({
      where: { id, shopId: context.shop.id },
      data: {
        ...(isActive !== undefined && { isActive }),
        ...(name && { name }),
        ...(amount !== undefined && { amount: Number(amount) }),
        ...(type && { type }),
      },
    });

    return response.json({ success: true });
  } catch (error) {
    console.error("Failed to update charge:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

router.delete("/me/taxes/:id", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    await prisma.shopTax.deleteMany({
      where: { id: request.params.id, shopId: context.shop.id },
    });

    return response.json({ success: true });
  } catch (error) {
    console.error("Failed to delete tax:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

router.delete("/me/charges/:id", async (request, response) => {
  try {
    const context = await requireOwnerShopContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    await prisma.shopCharge.deleteMany({
      where: { id: request.params.id, shopId: context.shop.id },
    });

    return response.json({ success: true });
  } catch (error) {
    console.error("Failed to delete charge:", error);
    return response.status(500).json({ message: "Internal server error." });
  }
});

export default router;
