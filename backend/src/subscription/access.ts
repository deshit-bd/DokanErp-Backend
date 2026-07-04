import { prisma } from "../config/prisma";

const TRIAL_DURATION_DAYS = 1;
const DEFAULT_DAILY_RATE_PER_ACCOUNT = 10;
const SALESMAN_BILLABLE_DELAY_MS = 24 * 60 * 60 * 1000;

export const FREE_TIER_PRODUCT_LIMIT = 50;
export const FREE_TIER_SALESMAN_LIMIT = 1;

type PrismaLike = typeof prisma | any;

export type SubscriptionAccessSnapshot = {
  allowed: boolean;
  shopId: string;
  status: "TRIAL" | "ACTIVE" | "GRACE" | "SUSPENDED" | "CANCELLED";
  tier: "TRIAL" | "PAID" | "BLOCKED";
  trialEndsAt: Date;
  billingDate: Date | null;
  billableAccounts: number;
  ratePerAccount: number;
  totalAmount: number;
  paidAmount: number;
  amountDue: number;
  message: string | null;
};

function addDays(source: Date, days: number) {
  const result = new Date(source);
  result.setDate(result.getDate() + days);
  return result;
}

function toMoney(value: unknown) {
  return Number(Number(value ?? 0).toFixed(2));
}

function getBillingDate(source = new Date()) {
  const billingDate = new Date(source);
  billingDate.setHours(0, 0, 0, 0);
  return billingDate;
}

function getNextMidnight(source: Date) {
  const result = new Date(source);
  result.setHours(24, 0, 0, 0);
  return result;
}

function getTrialWindow(startAt = new Date()) {
  const trialStartedAt = new Date(startAt);
  const trialEndsAt = new Date(trialStartedAt.getTime() + TRIAL_DURATION_DAYS * 24 * 60 * 60 * 1000);

  return {
    trialStartedAt,
    trialEndsAt,
  };
}

function computeInvoiceStatus(paidAmount: number, totalAmount: number) {
  if (paidAmount >= totalAmount) {
    return "PAID";
  }

  if (paidAmount > 0) {
    return "PARTIAL";
  }

  return "UNPAID";
}

async function loadShopForSubscription(shopId: string, client: PrismaLike = prisma) {
  return client.shop.findUnique({
    where: { id: shopId },
    select: {
      id: true,
      createdAt: true,
    },
  });
}

export async function ensureShopSubscription(shopId: string, client: PrismaLike = prisma, startAt?: Date) {
  const existing = await client.subscription.findUnique({
    where: { shopId },
  });

  if (existing) {
    if (Number(existing.dailyRatePerAccount) !== DEFAULT_DAILY_RATE_PER_ACCOUNT) {
      return client.subscription.update({
        where: { id: existing.id },
        data: { dailyRatePerAccount: DEFAULT_DAILY_RATE_PER_ACCOUNT },
      });
    }
    return existing;
  }

  const shop = await loadShopForSubscription(shopId, client);

  if (!shop) {
    throw new Error("Shop not found while creating subscription.");
  }

  const trialBase = startAt ?? shop.createdAt ?? new Date();
  const { trialStartedAt, trialEndsAt } = getTrialWindow(trialBase);

  return client.subscription.create({
    data: {
      shopId,
      status: "TRIAL",
      trialStartedAt,
      trialEndsAt,
      dailyRatePerAccount: DEFAULT_DAILY_RATE_PER_ACCOUNT,
    },
  });
}

export async function countBillableAccounts(shopId: string, client: PrismaLike = prisma) {
  const billableCutoff = new Date(Date.now() - SALESMAN_BILLABLE_DELAY_MS);

  await client.shopUser.updateMany({
    where: {
      shopId,
      role: "SALESMAN",
      isBillable: false,
      createdAt: {
        lte: billableCutoff,
      },
    },
    data: {
      isBillable: true,
    },
  });

  return client.shopUser.count({
    where: {
      shopId,
      isBillable: true,
      user: {
        status: "ACTIVE",
      },
    },
  });
}

export async function countActiveSalesmen(shopId: string, client: PrismaLike = prisma) {
  return client.shopUser.count({
    where: {
      shopId,
      role: "SALESMAN",
      user: {
        status: "ACTIVE",
      },
    },
  });
}

export async function countDistinctShopProducts(shopId: string, client: PrismaLike = prisma) {
  const rows = await client.shopProduct.findMany({
    where: { shopId },
    select: {
      masterProductId: true,
    },
  });

  return rows.length;
}

export async function ensureDailyInvoice(shopId: string, client: PrismaLike = prisma, source = new Date()) {
  const subscription = await ensureShopSubscription(shopId, client);
  const billableAccounts = await countBillableAccounts(shopId, client);
  const billingDate = getBillingDate(source);
  const ratePerAccount = toMoney(subscription.dailyRatePerAccount);
  const totalAmount = toMoney(billableAccounts * ratePerAccount);

  const invoice = await client.invoice.upsert({
    where: {
      shopId_billingDate: {
        shopId,
        billingDate,
      },
    },
    create: {
      subscriptionId: subscription.id,
      shopId,
      billingDate,
      billableAccounts,
      ratePerAccount,
      totalAmount,
      paidAmount: 0,
      status: computeInvoiceStatus(0, totalAmount),
    },
    update: {
      billableAccounts,
      ratePerAccount,
      totalAmount,
    },
  });

  const paidAmount = toMoney(invoice.paidAmount);
  const nextStatus = computeInvoiceStatus(paidAmount, totalAmount);

  if (
    invoice.billableAccounts === billableAccounts &&
    Number(invoice.ratePerAccount) === ratePerAccount &&
    Number(invoice.totalAmount) === totalAmount &&
    invoice.status === nextStatus
  ) {
    return invoice;
  }

  return client.invoice.update({
    where: { id: invoice.id },
    data: {
      billableAccounts,
      ratePerAccount,
      totalAmount,
      status: nextStatus,
    },
  });
}

export async function evaluateShopSubscriptionAccess(shopId: string, client: PrismaLike = prisma): Promise<SubscriptionAccessSnapshot> {
  const now = new Date();
  const subscription = await ensureShopSubscription(shopId, client);

  if (subscription.status === "SUSPENDED" || subscription.status === "CANCELLED") {
    return {
      allowed: false,
      shopId,
      status: subscription.status,
      tier: "BLOCKED",
      trialEndsAt: subscription.trialEndsAt,
      billingDate: null,
      billableAccounts: 0,
      ratePerAccount: toMoney(subscription.dailyRatePerAccount),
      totalAmount: 0,
      paidAmount: 0,
      amountDue: 0,
      message: "This shop subscription is not active. Please contact support.",
    };
  }

  if (subscription.status === "TRIAL" && subscription.trialEndsAt >= now) {
    return {
      allowed: true,
      shopId,
      status: "TRIAL",
      tier: "TRIAL",
      trialEndsAt: subscription.trialEndsAt,
      billingDate: null,
      billableAccounts: await countBillableAccounts(shopId, client),
      ratePerAccount: toMoney(subscription.dailyRatePerAccount),
      totalAmount: 0,
      paidAmount: 0,
      amountDue: 0,
      message: null,
    };
  }

  const invoice = await ensureDailyInvoice(shopId, client, now);
  const paidAmount = toMoney(invoice.paidAmount);
  const totalAmount = toMoney(invoice.totalAmount);
  const amountDue = toMoney(Math.max(totalAmount - paidAmount, 0));

  if (paidAmount >= totalAmount) {
    if (subscription.status !== "ACTIVE" || !subscription.billingStartedAt || subscription.graceEndsAt) {
      await client.subscription.update({
        where: { id: subscription.id },
        data: {
          status: "ACTIVE",
          billingStartedAt: subscription.billingStartedAt ?? now,
          graceEndsAt: null,
        },
      });
    }

    return {
      allowed: true,
      shopId,
      status: "ACTIVE",
      tier: "PAID",
      trialEndsAt: subscription.trialEndsAt,
      billingDate: invoice.billingDate,
      billableAccounts: invoice.billableAccounts,
      ratePerAccount: toMoney(invoice.ratePerAccount),
      totalAmount,
      paidAmount,
      amountDue,
      message: null,
    };
  }

  if (subscription.status !== "GRACE") {
    await client.subscription.update({
      where: { id: subscription.id },
      data: {
        status: "GRACE",
        graceEndsAt: now,
      },
    });
  }

  return {
    allowed: false,
    shopId,
    status: "GRACE",
    tier: "BLOCKED",
    trialEndsAt: subscription.trialEndsAt,
    billingDate: invoice.billingDate,
    billableAccounts: invoice.billableAccounts,
    ratePerAccount: toMoney(invoice.ratePerAccount),
    totalAmount,
    paidAmount,
    amountDue,
    message: `Free trial ended. Please pay BDT ${amountDue} to continue using the app.`,
  };
}

const SALESMAN_TRIAL_WINDOW_MS = 24 * 60 * 60 * 1000;

export async function evaluateSalesmanTrialAccess(shopId: string, userId: string, client: PrismaLike = prisma) {
  const membership = await client.shopUser.findFirst({
    where: {
      shopId,
      userId,
      role: "SALESMAN",
    },
    select: {
      id: true,
      createdAt: true,
    },
  });

  if (!membership) {
    return {
      allowed: false,
      trialEndsAt: null,
      remainingMs: 0,
    };
  }

  const trialEndsAt = new Date(membership.createdAt.getTime() + SALESMAN_TRIAL_WINDOW_MS);
  const remainingMs = trialEndsAt.getTime() - Date.now();

  return {
    allowed: remainingMs > 0,
    trialEndsAt,
    remainingMs: Math.max(remainingMs, 0),
  };
}

export async function canAddSalesmanInCurrentTier(shopId: string, client: PrismaLike = prisma) {
  const access = await evaluateShopSubscriptionAccess(shopId, client);

  if (!access.allowed) {
    return {
      allowed: false,
      message: access.message,
      access,
    };
  }

  if (access.tier !== "TRIAL") {
    return {
      allowed: true,
      message: null,
      access,
    };
  }

  const currentSalesmen = await countActiveSalesmen(shopId, client);

  if (currentSalesmen >= FREE_TIER_SALESMAN_LIMIT) {
    return {
      allowed: false,
      message: `Free tier allows only ${FREE_TIER_SALESMAN_LIMIT} salesman.`,
      access,
    };
  }

  return {
    allowed: true,
    message: null,
    access,
  };
}

export async function canAddProductsToShop(shopId: string, masterProductIds: string[], client: PrismaLike = prisma) {
  const access = await evaluateShopSubscriptionAccess(shopId, client);

  if (!access.allowed) {
    return {
      allowed: false,
      message: access.message,
      access,
      currentProductCount: 0,
      nextProductCount: 0,
    };
  }

  if (access.tier !== "TRIAL") {
    return {
      allowed: true,
      message: null,
      access,
      currentProductCount: 0,
      nextProductCount: 0,
    };
  }

  const currentProducts = await client.shopProduct.findMany({
    where: { shopId },
    select: {
      masterProductId: true,
    },
  });

  const productIds = new Set(currentProducts.map((item: { masterProductId: string }) => item.masterProductId));

  for (const masterProductId of masterProductIds) {
    productIds.add(masterProductId);
  }

  if (productIds.size > FREE_TIER_PRODUCT_LIMIT) {
    return {
      allowed: false,
      message: `Free tier allows up to ${FREE_TIER_PRODUCT_LIMIT} products per shop.`,
      access,
      currentProductCount: currentProducts.length,
      nextProductCount: productIds.size,
    };
  }

  return {
    allowed: true,
    message: null,
    access,
    currentProductCount: currentProducts.length,
    nextProductCount: productIds.size,
  };
}
