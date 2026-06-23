import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import {
  normalizeMoney as normalizeStockMoney,
  recordStockMovement,
} from "../utils/stock-movement";

const router = Router();

type CustomerStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";
type PaymentMetaInput = {
  senderNumber?: string | null;
  transactionId?: string | null;
  cardHolderName?: string | null;
  cardLast4?: string | null;
  cardType?: string | null;
  approvalCode?: string | null;
};

function toDisplayStatus(status: CustomerStatusValue) {
  return status.replace(/_/g, " ");
}

function toMoney(value: unknown) {
  return Number(value ?? 0);
}

function roundQuantity(value: number) {
  return Number(value.toFixed(3));
}

function roundCurrency(value: number) {
  return Number(value.toFixed(2));
}

function normalizeBatchOrder(value: string | null | undefined) {
  return value === "LIFO" ? "LIFO" : "FIFO";
}

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function normalizeCustomerPayment(
  paymentMethodRaw: unknown,
  amount: number,
  paymentMetaRaw: PaymentMetaInput | null | undefined,
) {
  const paymentMethod = normalizeText(paymentMethodRaw).toUpperCase() || null;

  if (paymentMethod === "DUE" && amount > 0) {
    return { error: "Due payments must have amount set to 0." };
  }

  if (amount > 0 && !paymentMethod) {
    return { error: "paymentMethod is required when amount is greater than 0." };
  }

  if (!paymentMethod || paymentMethod === "CASH" || paymentMethod === "DUE" || paymentMethod === "BANK") {
    return { paymentMethod, paymentMeta: null as Record<string, string> | null };
  }

  const paymentMeta = paymentMetaRaw && typeof paymentMetaRaw === "object" ? paymentMetaRaw : {};

  if (paymentMethod === "BKASH" || paymentMethod === "NAGAD") {
    const senderNumber = normalizeText(paymentMeta.senderNumber);
    const transactionId = normalizeText(paymentMeta.transactionId);

    if (!senderNumber || !transactionId) {
      return { error: `${paymentMethod} payments require senderNumber and transactionId.` };
    }

    return {
      paymentMethod,
      paymentMeta: {
        senderNumber,
        transactionId,
      },
    };
  }

  if (paymentMethod === "CARD") {
    const cardHolderName = normalizeText(paymentMeta.cardHolderName);
    const cardLast4 = normalizeText(paymentMeta.cardLast4);
    const cardType = normalizeText(paymentMeta.cardType);
    const approvalCode = normalizeText(paymentMeta.approvalCode);
    const transactionId = normalizeText(paymentMeta.transactionId);

    if (!cardHolderName || !cardLast4 || !cardType || (!approvalCode && !transactionId)) {
      return {
        error:
          "Card payments require cardHolderName, cardLast4, cardType, and approvalCode or transactionId.",
      };
    }

    return {
      paymentMethod,
      paymentMeta: {
        cardHolderName,
        cardLast4,
        cardType,
        approvalCode: approvalCode || undefined,
        transactionId: transactionId || undefined,
      },
    };
  }

  return { paymentMethod, paymentMeta: null as Record<string, string> | null };
}

function toBalanceType(due: number) {
  return due > 0 ? "DUE" : "CLEAR";
}

function buildCustomerCodeBase(name: string) {
  const normalized = name
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, "")
    .slice(0, 6);

  return normalized || "CUS";
}

async function createUniqueCustomerCode(name: string) {
  const base = buildCustomerCodeBase(name);

  for (let attempt = 0; attempt < 10; attempt += 1) {
    const suffix = `${Date.now()}`.slice(-4) + `${Math.floor(Math.random() * 100)}`.padStart(2, "0");
    const candidate = `${base}-${suffix}`;
    const existing = await (prisma as any).customer.findFirst({
      where: { customerCode: candidate },
      select: { id: true },
    });

    if (!existing) {
      return candidate;
    }
  }

  return `${base}-${Math.floor(Date.now() / 1000)}`;
}

async function resolveCustomerIdentifier(customerIdentifier?: string | null) {
  const normalized = customerIdentifier?.trim();

  if (!normalized) {
    return null;
  }

  return (prisma as any).customer.findFirst({
    where: {
      deletedAt: null,
      OR: [{ id: normalized }, { customerCode: normalized }],
    },
  });
}

async function resolveCustomerLinkedToShop(customerId: string, shopId: string) {
  return (prisma as any).customer.findFirst({
    where: {
      id: customerId,
      deletedAt: null,
      OR: [
        { sales: { some: { shopId } } },
        { payments: { some: { shopId } } },
        { ledgerEntries: { some: { shopId } } },
      ],
    },
  });
}

async function resolveShopIdentifier(shopIdentifier?: string | null) {
  const normalized = shopIdentifier?.trim();

  if (!normalized) {
    return null;
  }

  return prisma.shop.findFirst({
    where: {
      OR: [{ id: normalized }, { shopCode: normalized }],
    },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      phone: true,
      address: true,
      area: true,
      district: true,
      status: true,
    },
  });
}

async function requireCustomerAccess(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER", "SALESMAN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage customers." },
    };
  }

  return auth;
}

async function requireCustomerFinanceContext(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const auth = await requireCustomerAccess(request);

  if (isAuthError(auth as any)) {
    return auth;
  }

  if ("status" in auth) {
    return auth;
  }

  const rawShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!rawShopId) {
    return {
      status: 400,
      body: { message: "shopId is required for customer finance operations." },
    };
  }

  if (["SHOP_OWNER", "SALESMAN"].includes(auth.payload.role) && auth.payload.shopId && auth.payload.shopId !== rawShopId) {
    return {
      status: 403,
      body: { message: "You can only access customer finance for your own shop." },
    };
  }

  return { auth, shopId: rawShopId };
}

async function resolveFinanceShop(request: Parameters<typeof getAuthenticatedUser>[0]): Promise<any> {
  const context = await requireCustomerFinanceContext(request);

  if (isAuthError(context as any)) {
    return context;
  }

  if ("status" in context) {
    return context;
  }

  const shop = await resolveShopIdentifier(context.shopId);

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found for the provided shopId/shopCode." },
    };
  }

  return { auth: context.auth, shop };
}

async function resolveShopMoneyBox(shopId: string, moneyBoxId?: string | null) {
  const normalizedMoneyBoxId = moneyBoxId?.trim();

  if (!normalizedMoneyBoxId) {
    return null;
  }

  return (prisma as any).moneyBox.findFirst({
    where: {
      id: normalizedMoneyBoxId,
      shopId,
    },
    select: {
      id: true,
      boxName: true,
      code: true,
      type: true,
    },
  });
}

async function resolveDefaultMoneyBoxByType(shopId: string, type?: string | null) {
  const normalizedType = normalizeText(type).toUpperCase();

  if (!normalizedType || !["CASH", "BKASH", "NAGAD"].includes(normalizedType)) {
    return null;
  }

  return (prisma as any).moneyBox.findFirst({
    where: {
      shopId,
      type: normalizedType,
      status: "ACTIVE",
    },
    orderBy: [{ createdAt: "asc" }],
    select: {
      id: true,
      boxName: true,
      code: true,
      type: true,
      currentBalance: true,
    },
  });
}

async function buildCustomerFinanceSummary(customerId: string, shopId: string) {
  const ledgerEntries = await (prisma as any).customerLedger.findMany({
    where: { customerId, shopId },
    select: { debit: true, credit: true, entryType: true },
  });

  const totalDebit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
  const totalCredit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);
  
  const totalSales = ledgerEntries
    .filter((entry: any) => entry.entryType === "SALE")
    .reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
    
  const totalPaid = ledgerEntries
    .filter((entry: any) => entry.entryType === "PAYMENT")
    .reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);

  const due = Math.max(0, totalDebit - totalCredit);

  return {
    totalSales,
    totalPaid,
    due,
  };
}

function mapCustomerMaster(customer: any) {
  return {
    id: customer.id,
    customerCode: customer.customerCode,
    name: customer.name,
    companyOrPersonName: customer.name,
    mobile: customer.mobile,
    email: customer.email,
    address: customer.address,
    shortNote: customer.notes,
    notes: customer.notes,
    storeCredit: toMoney(customer.storeCredit),
    status: customer.status,
    statusLabel: toDisplayStatus(customer.status),
    createdAt: customer.createdAt,
    updatedAt: customer.updatedAt,
  };
}

function mapCustomerSaleRecord(sale: any) {
  const items = Array.isArray(sale.items) ? sale.items : [];
  const totalQty = items.reduce((sum: number, item: any) => sum + Number(item.quantity ?? 0), 0);

  return {
    id: sale.id,
    shopId: sale.shopId,
    customerId: sale.customerId,
    createdByUserId: sale.createdByUserId,
    customerName: sale.customer?.name ?? null,
    customerMobile: sale.customer?.mobile ?? null,
    invoiceNo: sale.invoiceNo,
    saleDate: sale.saleDate,
    totalAmount: toMoney(sale.totalAmount),
    paidAmount: toMoney(sale.paidAmount),
    dueAmount: toMoney(sale.dueAmount),
    discountAmount: toMoney(sale.discountAmount ?? 0),
    taxAmount: toMoney(sale.taxAmount ?? 0),
    chargeAmount: toMoney(sale.chargeAmount ?? 0),
    paymentMethod: sale.paymentMethod,
    status: sale.status ?? "ACTIVE",
    cancelledAt: sale.cancelledAt ?? null,
    cancelReason: sale.cancelReason ?? null,
    refundMethod: sale.refundMethod ?? null,
    refundAmount: toMoney(sale.refundAmount ?? 0),
    cancelNotes: sale.cancelNotes ?? null,
    notes: sale.notes ?? null,
    itemsCount: items.length,
    totalQty: Number(totalQty.toFixed(3)),
    items: items.map((item: any) => ({
      id: item.id,
      masterProductId: item.masterProductId,
      name: item.masterProduct?.name ?? item.productName ?? "",
      sku: item.masterProduct?.sku ?? "",
      quantity: toMoney(item.quantity),
      salePrice: toMoney(item.salePrice),
      totalAmount: toMoney(item.totalAmount),
    })),
  };
}

router.get("/", async (request, response) => {
  try {
    const requestedShopIdentifier = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";

    if (requestedShopIdentifier) {
      const context = await resolveFinanceShop(request);

      if (isAuthError(context as any)) {
        return sendAuthError(response, context as any);
      }

      if ("status" in context) {
        return response.status(context.status).json(context.body);
      }

      const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
      const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

      const customers = await (prisma as any).customer.findMany({
        where: {
          deletedAt: null,
          ...(status ? { status } : {}),
          AND: [
            {
              OR: [
                { sales: { some: { shopId: context.shop.id } } },
                { payments: { some: { shopId: context.shop.id } } },
                { ledgerEntries: { some: { shopId: context.shop.id } } },
              ],
            },
            ...(search
              ? [
                  {
                    OR: [
                      { customerCode: { contains: search, mode: "insensitive" } },
                      { name: { contains: search, mode: "insensitive" } },
                      { mobile: { contains: search, mode: "insensitive" } },
                      { email: { contains: search, mode: "insensitive" } },
                    ],
                  },
                ]
              : []),
          ],
        },
        include: {
          ledgerEntries: {
            where: { shopId: context.shop.id },
            orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
            take: 1,
            select: {
              id: true,
              entryType: true,
              referenceNo: true,
              debit: true,
              credit: true,
              notes: true,
              entryDate: true,
            },
          },
        },
        orderBy: [{ name: "asc" }],
      });

      const customerSummaries = await Promise.all(
        customers.map(async (customer: any) => {
          const summary = await buildCustomerFinanceSummary(customer.id, context.shop.id);
          const due = toMoney(summary.due);
          const totalSales = toMoney(summary.totalSales);
          const totalPaid = toMoney(summary.totalPaid);
          const lastLedgerEntry = customer.ledgerEntries[0] ?? null;

          return {
            ...mapCustomerMaster(customer),
            avatarLabel: customer.name?.charAt(0)?.toUpperCase() ?? "C",
            totalSales,
            totalPaid,
            due,
            balanceType: toBalanceType(due),
            dueLabel: due > 0 ? `Due ${due}` : "Paid",
            lastActivityAt: lastLedgerEntry?.entryDate ?? null,
            lastActivity: lastLedgerEntry
              ? {
                  id: lastLedgerEntry.id,
                  entryType: lastLedgerEntry.entryType,
                  referenceNo: lastLedgerEntry.referenceNo,
                  debit: toMoney(lastLedgerEntry.debit),
                  credit: toMoney(lastLedgerEntry.credit),
                  notes: lastLedgerEntry.notes,
                  entryDate: lastLedgerEntry.entryDate,
                }
              : null,
          };
        }),
      );

      return response.json({
        shop: {
          id: context.shop.id,
          shopCode: context.shop.shopCode,
          shopName: context.shop.shopName,
          phone: context.shop.phone,
          address: context.shop.address,
          area: context.shop.area,
          district: context.shop.district,
          status: context.shop.status,
        },
        stats: {
          total: customerSummaries.length,
          active: customerSummaries.filter((item) => item.status === "ACTIVE").length,
          inactive: customerSummaries.filter((item) => item.status === "INACTIVE").length,
          archived: customerSummaries.filter((item) => item.status === "ARCHIVED").length,
          totalSales: customerSummaries.reduce((sum, item) => sum + item.totalSales, 0),
          totalPaid: customerSummaries.reduce((sum, item) => sum + item.totalPaid, 0),
          totalDue: customerSummaries.reduce((sum, item) => sum + item.due, 0),
        },
        customers: customerSummaries,
      });
    }

    const auth = await requireCustomerAccess(request);

    if (isAuthError(auth as any)) {
      return sendAuthError(response, auth as any);
    }

    if ("status" in auth) {
      return response.status(auth.status).json(auth.body);
    }

    const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

    const customers = await (prisma as any).customer.findMany({
      where: {
        deletedAt: null,
        ...(status ? { status } : {}),
        ...(search
          ? {
              OR: [
                { customerCode: { contains: search, mode: "insensitive" } },
                { name: { contains: search, mode: "insensitive" } },
                { mobile: { contains: search, mode: "insensitive" } },
                { email: { contains: search, mode: "insensitive" } },
              ],
            }
          : {}),
      },
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
    });

    return response.json({
      stats: {
        total: customers.length,
        active: customers.filter((item: { status: CustomerStatusValue }) => item.status === "ACTIVE").length,
        inactive: customers.filter((item: { status: CustomerStatusValue }) => item.status === "INACTIVE").length,
        archived: customers.filter((item: { status: CustomerStatusValue }) => item.status === "ARCHIVED").length,
      },
      customers: customers.map(mapCustomerMaster),
    });
  } catch (error) {
    console.error("Failed to load customers.", error);

    return response.status(503).json({
      message:
        "Customers are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push.",
    });
  }
});

router.post("/", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const { shop } = context;

    const body = request.body as {
      customerCode?: string;
      companyOrPersonName?: string;
      name?: string;
      mobile?: string | null;
      email?: string | null;
      address?: string | null;
      shortNote?: string | null;
      notes?: string | null;
      status?: CustomerStatusValue;
      openingDue?: number | string | null;
    };

    const customerCode = body.customerCode?.trim();
    const name = body.name?.trim() || body.companyOrPersonName?.trim();
    const mobile = body.mobile?.trim() || null;
    const email = body.email?.trim() || null;
    const address = body.address?.trim() || null;
    const notes = body.notes?.trim() || body.shortNote?.trim() || null;
    const status = body.status ?? "ACTIVE";

    if (!name) {
      return response.status(400).json({ message: "Customer name is required." });
    }

    const generatedCustomerCode = customerCode || (await createUniqueCustomerCode(name));

    const duplicateCustomer = await (prisma as any).customer.findFirst({
      where: {
        deletedAt: null,
        OR: [{ customerCode: generatedCustomerCode }, ...(mobile ? [{ mobile }] : []), { name }],
      },
      select: {
        id: true,
        customerCode: true,
        name: true,
        mobile: true,
      },
    });

    if (duplicateCustomer) {
      const existingShopLink = await resolveCustomerLinkedToShop(
        duplicateCustomer.id,
        shop.id,
      );

      if (existingShopLink) {
        return response.status(409).json({
          message: "Customer already added for this shop.",
          customer: {
            id: duplicateCustomer.id,
            customerCode: duplicateCustomer.customerCode,
            name: duplicateCustomer.name,
            companyOrPersonName: duplicateCustomer.name,
            mobile: duplicateCustomer.mobile,
          },
        });
      }

      const openingDue = Number(body.openingDue ?? 0);

      await (prisma as any).customerLedger.create({
        data: {
          shopId: shop.id,
          customerId: duplicateCustomer.id,
          entryType: "OPENING_DUE",
          referenceNo: `REG-${duplicateCustomer.customerCode}`,
          debit: openingDue,
          credit: 0,
          notes:
            openingDue > 0
              ? "প্রারম্ভিক বকেয়া"
              : "বিদ্যমান গ্রাহককে এই দোকানের সাথে যুক্ত করা হয়েছে",
          entryDate: new Date(),
        },
      });

      const linkedCustomer = await (prisma as any).customer.findUnique({
        where: { id: duplicateCustomer.id },
      });

      return response.status(200).json({
        message: "Existing global customer linked to this shop successfully.",
        customer: mapCustomerMaster(linkedCustomer),
      });
    }

    const customer = await (prisma as any).customer.create({
      data: {
        customerCode: generatedCustomerCode,
        name,
        mobile,
        email,
        address,
        notes,
        status,
      },
    });

    const openingDue = Number(body.openingDue ?? 0);

    // Create a ledger entry to bind this customer to the shop and record opening balance
    await (prisma as any).customerLedger.create({
      data: {
        shopId: shop.id,
        customerId: customer.id,
        entryType: "OPENING_DUE",
        referenceNo: `REG-${customer.customerCode}`,
        debit: openingDue,
        credit: 0,
        notes: openingDue > 0 ? "প্রারম্ভিক বকেয়া" : "গ্রাহক নিবন্ধন",
        entryDate: new Date(),
      },
    });

    return response.status(201).json({
      message: "Customer created successfully.",
      customer: mapCustomerMaster(customer),
    });
  } catch (error) {
    console.error("Failed to create customer.", error);

    return response.status(503).json({
      message:
        "Customer could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push.",
    });
  }
});

router.get("/sales", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const date = typeof request.query.date === "string" ? request.query.date.trim() : "";
    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";
    const startDate = date ? new Date(`${date}T00:00:00.000Z`) : null;
    const endDate = date ? new Date(`${date}T23:59:59.999Z`) : null;

    const sales = await (prisma as any).customerSale.findMany({
      where: {
        shopId: context.shop.id,
        ...(status ? { status } : {}),
        ...(startDate && endDate ? { saleDate: { gte: startDate, lte: endDate } } : {}),
      },
      include: {
        customer: {
          select: { id: true, name: true, mobile: true },
        },
        items: {
          include: {
            masterProduct: {
              select: { id: true, sku: true, name: true },
            },
          },
        },
      },
      orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
    });

    const mappedSales = sales.map(mapCustomerSaleRecord);

    return response.json({
      shop: {
        id: context.shop.id,
        shopCode: context.shop.shopCode,
        shopName: context.shop.shopName,
      },
      summary: {
        totalSales: mappedSales.length,
        activeSales: mappedSales.filter((sale: any) => sale.status === "ACTIVE").length,
        cancelledSales: mappedSales.filter((sale: any) => sale.status === "CANCELLED").length,
        totalAmount: Number(mappedSales.reduce((sum: number, sale: any) => sum + sale.totalAmount, 0).toFixed(2)),
        totalPaid: Number(mappedSales.reduce((sum: number, sale: any) => sum + sale.paidAmount, 0).toFixed(2)),
        totalDue: Number(mappedSales.reduce((sum: number, sale: any) => sum + sale.dueAmount, 0).toFixed(2)),
      },
      sales: mappedSales,
    });
  } catch (error) {
    console.error("Failed to load shop sales.", error);
    return response.status(503).json({ message: "Sales history could not be loaded right now." });
  }
});

router.get("/sales/closing-summary", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const date = typeof request.query.date === "string" && request.query.date.trim()
      ? request.query.date.trim()
      : new Date().toISOString().slice(0, 10);
    const startDate = new Date(`${date}T00:00:00.000Z`);
    const endDate = new Date(`${date}T23:59:59.999Z`);

    const sales = await (prisma as any).customerSale.findMany({
      where: {
        shopId: context.shop.id,
        saleDate: { gte: startDate, lte: endDate },
        status: "ACTIVE",
      },
      include: {
        items: {
          include: {
            masterProduct: {
              select: { id: true, name: true },
            },
          },
        },
      },
      orderBy: [{ saleDate: "desc" }],
    });

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
          productMap.set(key, {
            masterProductId: key,
            name: item.masterProduct?.name ?? "Unknown",
            quantity: Number(item.quantity ?? 0),
          });
        }
      });
    });

    const topProducts = Array.from(productMap.values())
      .sort((a, b) => b.quantity - a.quantity)
      .slice(0, 5)
      .map((item) => ({
        ...item,
        quantity: Number(item.quantity.toFixed(3)),
      }));

    return response.json({
      shop: {
        id: context.shop.id,
        shopCode: context.shop.shopCode,
        shopName: context.shop.shopName,
      },
      date,
      summary,
      paymentBreakdown,
      topProducts,
      sales: sales.map(mapCustomerSaleRecord),
    });
  } catch (error) {
    console.error("Failed to load daily sales closing summary.", error);
    return response.status(503).json({ message: "Daily closing summary could not be loaded right now." });
  }
});

router.get("/sales/:saleId", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const sale = await (prisma as any).customerSale.findFirst({
      where: {
        id: request.params.saleId,
        shopId: context.shop.id,
      },
      include: {
        customer: {
          select: { id: true, name: true, mobile: true, address: true },
        },
        items: {
          include: {
            masterProduct: {
              select: { id: true, sku: true, name: true },
            },
          },
        },
      },
    });

    if (!sale) {
      return response.status(404).json({ message: "Sale not found." });
    }

    const payment = await (prisma as any).customerPayment.findFirst({
      where: {
        shopId: context.shop.id,
        referenceNo: sale.invoiceNo ?? undefined,
      },
      orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      shop: {
        id: context.shop.id,
        shopCode: context.shop.shopCode,
        shopName: context.shop.shopName,
        phone: context.shop.phone,
        address: context.shop.address,
      },
      sale: {
        ...mapCustomerSaleRecord(sale),
        customer: sale.customer
          ? {
              id: sale.customer.id,
              name: sale.customer.name,
              mobile: sale.customer.mobile,
              address: sale.customer.address,
            }
          : null,
        paymentDetails: payment?.paymentMeta ?? null,
      },
    });
  } catch (error) {
    console.error("Failed to load sale details.", error);
    return response.status(503).json({ message: "Sale details could not be loaded right now." });
  }
});

router.post("/sales/:saleId/cancel", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      refundMethod?: string | null;
      reason?: string | null;
      notes?: string | null;
    };

    const refundMethod = normalizeText(body.refundMethod).toUpperCase() || "CASH_REFUND";
    const reason = normalizeText(body.reason);
    const notes = normalizeText(body.notes);

    if (!reason) {
      return response.status(400).json({ message: "Cancellation reason is required." });
    }

    const result = await (prisma as any).$transaction(async (tx: any) => {
      const sale = await tx.customerSale.findFirst({
        where: {
          id: request.params.saleId,
          shopId: context.shop.id,
        },
        include: {
          items: true,
          customer: true,
        },
      });

      if (!sale) {
        return { errorStatus: 404, errorMessage: "Sale not found." };
      }

      if ((sale.status ?? "ACTIVE") === "CANCELLED") {
        return { errorStatus: 400, errorMessage: "This sale is already cancelled." };
      }

      const salePayment = Number(sale.paidAmount ?? 0);
      const paymentType = normalizeText(sale.paymentMethod).toUpperCase();
      const refundMoneyBox =
        refundMethod === "CASH_REFUND"
          ? await tx.moneyBox.findFirst({
              where: { shopId: context.shop.id, type: "CASH", status: "ACTIVE" },
              orderBy: [{ createdAt: "asc" }],
            })
          : refundMethod === "WALLET_REFUND"
            ? await tx.moneyBox.findFirst({
                where: { shopId: context.shop.id, type: paymentType === "NAGAD" ? "NAGAD" : "BKASH", status: "ACTIVE" },
                orderBy: [{ createdAt: "asc" }],
              })
            : null;

      for (const item of sale.items) {
        const shopProduct = await tx.shopProduct.findUnique({
          where: {
            shopId_masterProductId: {
              shopId: context.shop.id,
              masterProductId: item.masterProductId,
            },
          },
          select: {
            id: true,
            masterProductId: true,
            openingStock: true,
            purchasePrice: true,
            salePrice: true,
          },
        });

        const previousStock = Number(shopProduct?.openingStock ?? 0);
        const nextStock = previousStock + Number(item.quantity ?? 0);

        await tx.shopProduct.update({
          where: {
            shopId_masterProductId: {
              shopId: context.shop.id,
              masterProductId: item.masterProductId,
            },
          },
          data: {
            openingStock: {
              increment: item.quantity,
            },
          },
        });

        if (shopProduct) {
          await recordStockMovement(tx, {
            shopId: context.shop.id,
            shopProductId: shopProduct.id,
            masterProductId: shopProduct.masterProductId,
            movementType: "SALE_CANCEL",
            quantityDelta: Number(item.quantity ?? 0),
            stockBefore: previousStock,
            stockAfter: nextStock,
            purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
            salePrice: normalizeStockMoney(shopProduct.salePrice),
            unitPrice: Number(item.salePrice ?? 0),
            referenceType: "SALE_CANCEL",
            referenceId: sale.id,
            referenceNo: sale.invoiceNo || null,
            note: reason,
            createdByUserId: context.auth.user.id,
          });
        }
      }

      const cancelledSale = await tx.customerSale.update({
        where: { id: sale.id },
        data: {
          status: "CANCELLED",
          cancelledAt: new Date(),
          cancelReason: reason,
          refundMethod,
          refundAmount: sale.paidAmount,
          cancelNotes: notes || null,
        },
        include: {
          customer: {
            select: { id: true, name: true, mobile: true },
          },
          items: {
            include: {
              masterProduct: {
                select: { id: true, sku: true, name: true },
              },
            },
          },
        },
      });

      await tx.customerLedger.create({
        data: {
          shopId: context.shop.id,
          customerId: sale.customerId,
          customerSaleId: sale.id,
          entryType: "ADJUSTMENT",
          referenceNo: sale.invoiceNo || sale.customer.customerCode || null,
          debit: 0,
          credit: sale.totalAmount,
          notes: `SALE_CANCELLED | ${reason}${notes ? ` | ${notes}` : ""}`,
          entryDate: new Date(),
        },
      });

      if (salePayment > 0 && refundMethod === "LATER_ADJUSTMENT") {
        await tx.customer.update({
          where: { id: sale.customerId },
          data: {
            storeCredit: {
              increment: salePayment,
            },
          },
        });

        await tx.customerLedger.create({
          data: {
            shopId: context.shop.id,
            customerId: sale.customerId,
            customerSaleId: sale.id,
            entryType: "ADJUSTMENT",
            referenceNo: sale.invoiceNo || sale.customer.customerCode || null,
            debit: salePayment,
            credit: 0,
            notes: `STORE_CREDIT_GRANTED | ${notes || reason}`,
            entryDate: new Date(),
          },
        });
      }

      if (salePayment > 0 && refundMethod !== "LATER_ADJUSTMENT") {
        if (refundMoneyBox) {
          await tx.moneyBox.update({
            where: { id: refundMoneyBox.id },
            data: {
              currentBalance: {
                decrement: salePayment,
              },
            },
          });
        }

        await tx.customerLedger.create({
          data: {
            shopId: context.shop.id,
            customerId: sale.customerId,
            customerSaleId: sale.id,
            entryType: "ADJUSTMENT",
            referenceNo: sale.invoiceNo || sale.customer.customerCode || null,
            debit: salePayment,
            credit: 0,
            notes: `SALE_REFUND | ${refundMethod}${notes ? ` | ${notes}` : ""}`,
            entryDate: new Date(),
          },
        });
      }

      return { sale: cancelledSale };
    });

    if ("errorStatus" in result) {
      return response.status(result.errorStatus).json({ message: result.errorMessage });
    }

    return response.json({
      message: "Sale cancelled successfully.",
      sale: mapCustomerSaleRecord(result.sale),
    });
  } catch (error) {
    console.error("Failed to cancel sale.", error);
    return response.status(503).json({ message: "Sale could not be cancelled right now." });
  }
});

router.post("/sales", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      customerId?: string;
      invoiceNo?: string | null;
      paidAmount?: number | string | null;
      storeCreditUsed?: number | string | null;
      discountAmount?: number | string | null;
      taxAmount?: number | string | null;
      chargeAmount?: number | string | null;
      paymentMethod?: string | null;
      paymentDetails?: PaymentMetaInput | null;
      moneyBoxId?: string | null;
      notes?: string | null;
      saleDate?: string | null;
      items?: Array<{
        productId?: string;
        masterProductId?: string;
        shopProductId?: string;
        qty?: number | string;
        quantity?: number | string;
        salePrice?: number | string;
        unitPrice?: number | string;
        price?: number | string;
        batchNo?: string | null;
      }>;
      lines?: Array<{
        productId?: string;
        masterProductId?: string;
        shopProductId?: string;
        qty?: number | string;
        quantity?: number | string;
        salePrice?: number | string;
        unitPrice?: number | string;
        price?: number | string;
        batchNo?: string | null;
      }>;
    };

    const customer = body.customerId
      ? await resolveCustomerLinkedToShop(body.customerId, context.shop.id)
      : null;

    if (!customer) {
      return response.status(404).json({
        message:
          "Customer is not linked to this shop. Add the customer to this store first.",
      });
    }

    const items = body.items ?? body.lines ?? [];

    if (items.length === 0) {
      return response.status(400).json({ message: "At least one sale item is required." });
    }

    const normalizedItems = items.map((item) => {
      const masterProductId = item.masterProductId || item.productId || item.shopProductId || "";
      const quantity = Number(item.quantity ?? item.qty ?? 0);
      const salePrice = Number(item.salePrice ?? item.unitPrice ?? item.price ?? 0);
      const batchNo = normalizeText(item.batchNo) || null;

      return {
        masterProductId,
        quantity,
        salePrice,
        totalAmount: Number((quantity * salePrice).toFixed(2)),
        batchNo,
      };
    });

    if (
      normalizedItems.some(
        (item) =>
          !item.masterProductId ||
          !Number.isFinite(item.quantity) ||
          item.quantity <= 0 ||
          !Number.isFinite(item.salePrice) ||
          item.salePrice < 0,
      )
    ) {
      return response.status(400).json({ message: "Each sale item requires a valid product, quantity, and sale price." });
    }

    const paidAmount = body.paidAmount == null || body.paidAmount === "" ? 0 : Number(body.paidAmount);
    const requestedStoreCreditUsed =
      body.storeCreditUsed == null || body.storeCreditUsed === "" ? 0 : Number(body.storeCreditUsed);
    const discountAmount = body.discountAmount == null || body.discountAmount === "" ? 0 : Number(body.discountAmount);
    const taxAmount = body.taxAmount == null || body.taxAmount === "" ? 0 : Number(body.taxAmount);
    const chargeAmount = body.chargeAmount == null || body.chargeAmount === "" ? 0 : Number(body.chargeAmount);

    if (!Number.isFinite(paidAmount) || paidAmount < 0) {
      return response.status(400).json({ message: "Paid amount must be a valid number." });
    }

    if (!Number.isFinite(requestedStoreCreditUsed) || requestedStoreCreditUsed < 0) {
      return response.status(400).json({ message: "storeCreditUsed must be a valid number." });
    }

    if (!Number.isFinite(discountAmount) || discountAmount < 0) {
      return response.status(400).json({ message: "discountAmount must be a valid number." });
    }

    if (!Number.isFinite(taxAmount) || taxAmount < 0) {
      return response.status(400).json({ message: "taxAmount must be a valid number." });
    }

    if (!Number.isFinite(chargeAmount) || chargeAmount < 0) {
      return response.status(400).json({ message: "chargeAmount must be a valid number." });
    }

    const paymentInfo = normalizeCustomerPayment(body.paymentMethod, paidAmount, body.paymentDetails);

    if ("error" in paymentInfo) {
      return response.status(400).json({ message: paymentInfo.error });
    }

    const masterProducts = await (prisma as any).masterProduct.findMany({
      where: {
        id: { in: normalizedItems.map((item) => item.masterProductId) },
      },
      select: { id: true, sku: true, name: true },
    });

    if (masterProducts.length !== normalizedItems.length) {
      return response.status(400).json({ message: "One or more sale products do not exist." });
    }

    const moneyBox = await resolveShopMoneyBox(context.shop.id, body.moneyBoxId);
    const fallbackMoneyBox = !moneyBox ? await resolveDefaultMoneyBoxByType(context.shop.id, paymentInfo.paymentMethod) : null;
    const effectiveMoneyBox = moneyBox ?? fallbackMoneyBox;

    if (body.moneyBoxId && !moneyBox) {
      return response.status(404).json({ message: "Money box not found for this shop." });
    }

    const availableStoreCredit = toMoney(customer.storeCredit);
    const storeCreditUsed = Math.min(availableStoreCredit, requestedStoreCreditUsed);

    if (requestedStoreCreditUsed > availableStoreCredit) {
      return response.status(400).json({ message: "Requested store credit is greater than available customer credit." });
    }

    const saleDate = body.saleDate ? new Date(body.saleDate) : new Date();

    const sale = await (prisma as any).$transaction(async (tx: any) => {
      const inventorySetting = await tx.shopInventorySetting.findUnique({
        where: { shopId: context.shop.id },
      });
      const reduceStock = inventorySetting ? inventorySetting.reduceStockOnSale : true;
      const allowNegative = inventorySetting ? inventorySetting.allowNegativeStock : false;
      const stockMethod = normalizeBatchOrder(inventorySetting?.stockMethod);
      const saleItemRecords: Array<{
        masterProductId: string;
        quantity: number;
        salePrice: number;
        totalAmount: number;
        batchNo: string | null;
      }> = [];
      const saleMovementRecords: Array<{
        shopProductId: string;
        masterProductId: string;
        quantity: number;
        stockBefore: number;
        stockAfter: number;
        salePrice: number;
        purchasePrice: number | null;
      }> = [];

      for (const item of normalizedItems) {
        const shopProduct = await tx.shopProduct.findUnique({
          where: {
            shopId_masterProductId: {
              shopId: context.shop.id,
              masterProductId: item.masterProductId,
            },
          },
        });

        if (!shopProduct) {
          throw new Error(`Product not found in shop inventory: ${item.masterProductId}`);
        }

        const currentStock = Number(shopProduct.openingStock ?? 0);
        if (reduceStock && !allowNegative && currentStock < item.quantity) {
          throw new Error(`Insufficient stock for product. Available: ${currentStock}, Requested: ${item.quantity}`);
        }

        const binItems = await tx.inventoryBinItem.findMany({
          where: {
            shopId: context.shop.id,
            masterProductId: item.masterProductId,
            quantity: { gt: 0 },
            ...(item.batchNo ? { batchNo: item.batchNo } : {}),
          },
          orderBy: [{ createdAt: stockMethod === "LIFO" ? "desc" : "asc" }, { id: "asc" }],
        });

        const touchedBinIds = new Set<string>();
        let remainingToAllocate = item.quantity;

        for (const binItem of binItems) {
          if (remainingToAllocate <= 0) {
            break;
          }

          const binQty = Number(binItem.quantity ?? 0);
          if (binQty <= 0) {
            continue;
          }

          const allocatedQty = Math.min(binQty, remainingToAllocate);
          const batchSalePrice = roundCurrency(
            Number(
              binItem.salePrice ??
              shopProduct.salePrice ??
              item.salePrice,
            ) || 0,
          );

          saleItemRecords.push({
            masterProductId: item.masterProductId,
            quantity: allocatedQty,
            salePrice: batchSalePrice,
            totalAmount: roundCurrency(allocatedQty * batchSalePrice),
            batchNo: binItem.batchNo ?? item.batchNo ?? null,
          });

          remainingToAllocate = roundQuantity(remainingToAllocate - allocatedQty);

          if (reduceStock) {
            const newBinQty = roundQuantity(binQty - allocatedQty);
            touchedBinIds.add(binItem.binId);

            if (newBinQty <= 0) {
              await tx.inventoryBinItem.delete({
                where: { id: binItem.id },
              });
            } else {
              await tx.inventoryBinItem.update({
                where: { id: binItem.id },
                data: { quantity: newBinQty },
              });
            }
          }
        }

        if (remainingToAllocate > 0) {
          if (reduceStock && !allowNegative) {
            throw new Error(
              `Insufficient batch stock for product. Requested: ${item.quantity}, Allocated: ${roundQuantity(item.quantity - remainingToAllocate)}`,
            );
          }

          const fallbackSalePrice = roundCurrency(
            Number(shopProduct.salePrice ?? item.salePrice) || 0,
          );

          saleItemRecords.push({
            masterProductId: item.masterProductId,
            quantity: remainingToAllocate,
            salePrice: fallbackSalePrice,
            totalAmount: roundCurrency(remainingToAllocate * fallbackSalePrice),
            batchNo: item.batchNo,
          });
        }

        if (reduceStock) {
          const nextStock = roundQuantity(currentStock - item.quantity);
          for (const binId of touchedBinIds) {
            const [bin, totalBinQty] = await Promise.all([
              tx.inventoryBin.findUnique({
                where: { id: binId },
              }),
              tx.inventoryBinItem.aggregate({
                where: { binId },
                _sum: { quantity: true },
              }),
            ]);

            if (!bin) {
              continue;
            }

            const quantityValue = Number(totalBinQty._sum.quantity ?? 0);
            await tx.inventoryBin.update({
              where: { id: binId },
              data: {
                status: quantityValue <= 0 ? "EMPTY" : quantityValue < 10 ? "LOW" : "FULL",
                quantityLabel: quantityValue <= 0 ? "খালি" : `${quantityValue} পিস`,
                productName: quantityValue <= 0 ? "" : bin.productName,
                daysLabel: quantityValue <= 0 ? "খালি" : bin.daysLabel,
              },
            });
          }

          await tx.shopProduct.update({
            where: {
              shopId_masterProductId: {
                shopId: context.shop.id,
                masterProductId: item.masterProductId,
              },
            },
            data: {
              openingStock: {
                decrement: item.quantity,
              },
            },
          });

          saleMovementRecords.push({
            shopProductId: shopProduct.id,
            masterProductId: item.masterProductId,
            quantity: item.quantity,
            stockBefore: currentStock,
            stockAfter: nextStock,
            salePrice: roundCurrency(Number(shopProduct.salePrice ?? item.salePrice) || 0),
            purchasePrice: normalizeStockMoney(shopProduct.purchasePrice),
          });
        }
      }

      const totalAmount = roundCurrency(
        saleItemRecords.reduce((sum, item) => sum + item.totalAmount, 0),
      );
      const grandTotal = roundCurrency(totalAmount - discountAmount + taxAmount + chargeAmount);

      if (paidAmount + requestedStoreCreditUsed > grandTotal) {
        throw new Error("Paid amount plus store credit cannot be greater than total sale amount.");
      }

      const dueAmount = roundCurrency(grandTotal - paidAmount - storeCreditUsed);

      const createdSale = await tx.customerSale.create({
        data: {
          shopId: context.shop.id,
          customerId: customer.id,
          createdByUserId: context.auth.user.id,
          invoiceNo: body.invoiceNo?.trim() || null,
          saleDate,
          totalAmount,
          paidAmount,
          dueAmount,
          discountAmount,
          taxAmount,
          chargeAmount,
          paymentMethod: paymentInfo.paymentMethod,
          notes: body.notes?.trim() || null,
          items: {
            create: saleItemRecords.map((item) => ({
              masterProductId: item.masterProductId,
              quantity: item.quantity,
              salePrice: item.salePrice,
              totalAmount: item.totalAmount,
              batchNo: item.batchNo,
            })),
          },
        },
        include: {
          items: {
            include: {
              masterProduct: {
                select: { id: true, sku: true, name: true },
              },
            },
          },
        },
      });

      for (const entry of saleMovementRecords) {
        await recordStockMovement(tx, {
          shopId: context.shop.id,
          shopProductId: entry.shopProductId,
          masterProductId: entry.masterProductId,
          movementType: "SALE",
          quantityDelta: -entry.quantity,
          stockBefore: entry.stockBefore,
          stockAfter: entry.stockAfter,
          purchasePrice: entry.purchasePrice,
          salePrice: entry.salePrice,
          unitPrice: entry.salePrice,
          referenceType: "SALE",
          referenceId: createdSale.id,
          referenceNo: createdSale.invoiceNo || null,
          note: createdSale.notes || "Stock reduced from sale.",
          createdByUserId: context.auth.user.id,
        });
      }

      await tx.customerLedger.create({
        data: {
          shopId: context.shop.id,
          customerId: customer.id,
          customerSaleId: createdSale.id,
          entryType: "SALE",
          referenceNo: createdSale.invoiceNo || customer.customerCode || null,
          debit: totalAmount,
          credit: 0,
          notes: createdSale.notes,
          entryDate: saleDate,
        },
      });

      if (storeCreditUsed > 0) {
        await tx.customer.update({
          where: { id: customer.id },
          data: {
            storeCredit: {
              decrement: storeCreditUsed,
            },
          },
        });

        await tx.customerLedger.create({
          data: {
            shopId: context.shop.id,
            customerId: customer.id,
            customerSaleId: createdSale.id,
            entryType: "ADJUSTMENT",
            referenceNo: createdSale.invoiceNo || customer.customerCode || null,
            debit: 0,
            credit: storeCreditUsed,
            notes: `STORE_CREDIT_USED | ${createdSale.notes ?? ""}`.trim(),
            entryDate: saleDate,
          },
        });
      }

      let payment: any = null;

      if (paidAmount > 0) {
        payment = await tx.customerPayment.create({
          data: {
            shopId: context.shop.id,
            customerId: customer.id,
            amount: paidAmount,
            paymentMethod: paymentInfo.paymentMethod,
            paymentMeta: paymentInfo.paymentMeta,
            moneyBoxId: effectiveMoneyBox?.id ?? null,
            referenceNo: createdSale.invoiceNo || null,
            notes: body.notes?.trim() || null,
            paidAt: saleDate,
          },
        });

        if (effectiveMoneyBox && ["CASH", "BKASH", "NAGAD"].includes(paymentInfo.paymentMethod || "")) {
          await tx.moneyBox.update({
            where: { id: effectiveMoneyBox.id },
            data: {
              currentBalance: {
                increment: paidAmount,
              },
            },
          });
        }

        await tx.customerLedger.create({
          data: {
            shopId: context.shop.id,
            customerId: customer.id,
            customerSaleId: createdSale.id,
            customerPaymentId: payment.id,
            entryType: "PAYMENT",
            referenceNo: createdSale.invoiceNo || customer.customerCode || null,
            debit: 0,
            credit: paidAmount,
            notes: createdSale.notes,
            entryDate: saleDate,
          },
        });
      }

      return {
        createdSale,
        payment,
      };
    });

    return response.status(201).json({
      message: "Customer sale created successfully.",
      sale: {
        id: sale.createdSale.id,
        shopId: sale.createdSale.shopId,
        customerId: sale.createdSale.customerId,
        invoiceNo: sale.createdSale.invoiceNo,
        saleDate: sale.createdSale.saleDate,
        totalAmount: toMoney(sale.createdSale.totalAmount),
        paidAmount: toMoney(sale.createdSale.paidAmount),
        dueAmount: toMoney(sale.createdSale.dueAmount),
        storeCreditUsed,
        paymentMethod: sale.createdSale.paymentMethod,
        notes: sale.createdSale.notes,
        items: sale.createdSale.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: toMoney(item.quantity),
          salePrice: toMoney(item.salePrice),
          totalAmount: toMoney(item.totalAmount),
          batchNo: item.batchNo ?? null,
        })),
      },
      payment: sale.payment
        ? {
            id: sale.payment.id,
            amount: toMoney(sale.payment.amount),
            paymentMethod: sale.payment.paymentMethod,
            paymentDetails: sale.payment.paymentMeta ?? null,
            moneyBoxId: sale.payment.moneyBoxId,
            referenceNo: sale.payment.referenceNo,
            paidAt: sale.payment.paidAt,
          }
        : null,
    });
  } catch (error: any) {
    console.error("Failed to create customer sale.", error);

    if (
      error instanceof Error &&
      (
        error.message.startsWith("Insufficient stock") ||
        error.message.startsWith("Insufficient batch stock") ||
        error.message.startsWith("Product not found") ||
        error.message.startsWith("Paid amount plus store credit")
      )
    ) {
      return response.status(400).json({ message: error.message });
    }

    return response.status(503).json({ message: "Customer sale could not be created right now." });
  }
});

router.get("/:id/sales", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const customer = await resolveCustomerLinkedToShop(
      request.params.id,
      context.shop.id,
    );

    if (!customer) {
      return response.status(404).json({ message: "Customer not found for this shop." });
    }

    const sales = await (prisma as any).customerSale.findMany({
      where: {
        shopId: context.shop.id,
        customerId: customer.id,
      },
      include: {
        items: {
          include: {
            masterProduct: {
              select: { id: true, sku: true, name: true },
            },
          },
        },
      },
      orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      shop: {
        id: context.shop.id,
        shopCode: context.shop.shopCode,
        shopName: context.shop.shopName,
      },
      customer: mapCustomerMaster(customer),
      sales: sales.map((sale: any) => ({
        id: sale.id,
        invoiceNo: sale.invoiceNo,
        saleDate: sale.saleDate,
        totalAmount: toMoney(sale.totalAmount),
        paidAmount: toMoney(sale.paidAmount),
        dueAmount: toMoney(sale.dueAmount),
        paymentMethod: sale.paymentMethod,
        notes: sale.notes,
        items: sale.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: toMoney(item.quantity),
          salePrice: toMoney(item.salePrice),
          totalAmount: toMoney(item.totalAmount),
        })),
      })),
    });
  } catch (error) {
    console.error("Failed to load customer sales.", error);

    return response.status(503).json({ message: "Customer sales could not be loaded right now." });
  }
});

router.post("/:id/payments", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const customer = await resolveCustomerLinkedToShop(
      request.params.id,
      context.shop.id,
    );

    if (!customer) {
      return response.status(404).json({ message: "Customer not found for this shop." });
    }

    const body = request.body as {
      amount?: number | string | null;
      paymentMethod?: string | null;
      paymentDetails?: PaymentMetaInput | null;
      moneyBoxId?: string | null;
      referenceNo?: string | null;
      notes?: string | null;
      paidAt?: string | null;
    };

    const amount = Number(body.amount ?? 0);

    if (!Number.isFinite(amount) || amount <= 0) {
      return response.status(400).json({ message: "Amount must be a valid positive number." });
    }

    const summary = await buildCustomerFinanceSummary(customer.id, context.shop.id);
    const dueBeforePayment = toMoney(summary.due);

    if (dueBeforePayment <= 0) {
      return response.status(400).json({ message: "This customer has no outstanding due in the selected shop." });
    }

    if (amount > dueBeforePayment) {
      return response.status(400).json({ message: "Payment amount cannot be greater than the outstanding due." });
    }

    const paymentInfo = normalizeCustomerPayment(body.paymentMethod, amount, body.paymentDetails);

    if ("error" in paymentInfo) {
      return response.status(400).json({ message: paymentInfo.error });
    }

    const moneyBox = await resolveShopMoneyBox(context.shop.id, body.moneyBoxId);
    const fallbackMoneyBox = !moneyBox ? await resolveDefaultMoneyBoxByType(context.shop.id, paymentInfo.paymentMethod) : null;
    const effectiveMoneyBox = moneyBox ?? fallbackMoneyBox;

    if (body.moneyBoxId && !moneyBox) {
      return response.status(404).json({ message: "Money box not found for this shop." });
    }

    const paidAt = body.paidAt ? new Date(body.paidAt) : new Date();

    const payment = await (prisma as any).$transaction(async (tx: any) => {
      const createdPayment = await tx.customerPayment.create({
        data: {
          shopId: context.shop.id,
          customerId: customer.id,
          amount,
          paymentMethod: paymentInfo.paymentMethod,
          paymentMeta: paymentInfo.paymentMeta,
          moneyBoxId: effectiveMoneyBox?.id ?? null,
          referenceNo: body.referenceNo?.trim() || null,
          notes: body.notes?.trim() || null,
          paidAt,
        },
      });

      if (effectiveMoneyBox && ["CASH", "BKASH", "NAGAD"].includes(paymentInfo.paymentMethod || "")) {
        await tx.moneyBox.update({
          where: { id: effectiveMoneyBox.id },
          data: {
            currentBalance: {
              increment: amount,
            },
          },
        });
      }

      await tx.customerLedger.create({
        data: {
          shopId: context.shop.id,
          customerId: customer.id,
          customerPaymentId: createdPayment.id,
          entryType: "PAYMENT",
          referenceNo: createdPayment.referenceNo || customer.customerCode || null,
          debit: 0,
          credit: amount,
          notes: createdPayment.notes,
          entryDate: paidAt,
        },
      });

      return createdPayment;
    });

    return response.status(201).json({
      message: "Customer payment recorded successfully.",
      payment: {
        id: payment.id,
        shopId: payment.shopId,
        customerId: payment.customerId,
        amount: toMoney(payment.amount),
        paymentMethod: payment.paymentMethod,
        paymentDetails: payment.paymentMeta ?? null,
        moneyBoxId: payment.moneyBoxId,
        referenceNo: payment.referenceNo,
        notes: payment.notes,
        paidAt: payment.paidAt,
      },
      dueBeforePayment,
      dueAfterPayment: Number((dueBeforePayment - amount).toFixed(2)),
    });
  } catch (error) {
    console.error("Failed to record customer payment.", error);

    return response.status(503).json({ message: "Customer payment could not be recorded right now." });
  }
});

router.get("/:id/ledger", async (request, response) => {
  try {
    const context = await resolveFinanceShop(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const customer = await resolveCustomerLinkedToShop(
      request.params.id,
      context.shop.id,
    );

    if (!customer) {
      return response.status(404).json({ message: "Customer not found for this shop." });
    }

    const ledgerEntries = await (prisma as any).customerLedger.findMany({
      where: {
        shopId: context.shop.id,
        customerId: customer.id,
      },
      include: {
        customerSale: {
          select: {
            id: true,
            invoiceNo: true,
            saleDate: true,
            totalAmount: true,
            paidAmount: true,
            dueAmount: true,
          },
        },
        customerPayment: {
          select: {
            id: true,
            amount: true,
            paymentMethod: true,
            paymentMeta: true,
            referenceNo: true,
            paidAt: true,
          },
        },
      },
      orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
    });

    let balance = 0;

    return response.json({
      shop: {
        id: context.shop.id,
        shopCode: context.shop.shopCode,
        shopName: context.shop.shopName,
      },
      customer: mapCustomerMaster(customer),
      ledger: ledgerEntries.map((entry: any) => {
        balance += toMoney(entry.debit) - toMoney(entry.credit);

        return {
          id: entry.id,
          entryType: entry.entryType,
          referenceNo: entry.referenceNo,
          debit: toMoney(entry.debit),
          credit: toMoney(entry.credit),
          balance,
          notes: entry.notes,
          entryDate: entry.entryDate,
          sale: entry.customerSale
            ? {
                id: entry.customerSale.id,
                invoiceNo: entry.customerSale.invoiceNo,
                saleDate: entry.customerSale.saleDate,
                totalAmount: toMoney(entry.customerSale.totalAmount),
                paidAmount: toMoney(entry.customerSale.paidAmount),
                dueAmount: toMoney(entry.customerSale.dueAmount),
              }
            : null,
          payment: entry.customerPayment
            ? {
                id: entry.customerPayment.id,
                amount: toMoney(entry.customerPayment.amount),
                paymentMethod: entry.customerPayment.paymentMethod,
                paymentDetails: entry.customerPayment.paymentMeta ?? null,
                referenceNo: entry.customerPayment.referenceNo,
                paidAt: entry.customerPayment.paidAt,
              }
            : null,
        };
      }),
      due: balance,
    });
  } catch (error) {
    console.error("Failed to load customer ledger.", error);

    return response.status(503).json({ message: "Customer ledger could not be loaded right now." });
  }
});

router.get("/:id", async (request, response) => {
  try {
    const requestedShopIdentifier = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";

    if (requestedShopIdentifier) {
      const context = await resolveFinanceShop(request);

      if (isAuthError(context as any)) {
        return sendAuthError(response, context as any);
      }

      if ("status" in context) {
        return response.status(context.status).json(context.body);
      }

      const customer = await resolveCustomerLinkedToShop(
        request.params.id,
        context.shop.id,
      );

      if (!customer) {
        return response.status(404).json({ message: "Customer not found for this shop." });
      }

      const [summary, sales, payments, ledgerEntries] = await Promise.all([
        buildCustomerFinanceSummary(customer.id, context.shop.id),
        (prisma as any).customerSale.findMany({
          where: { shopId: context.shop.id, customerId: customer.id },
          orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
          take: 10,
          select: {
            id: true,
            invoiceNo: true,
            saleDate: true,
            totalAmount: true,
            paidAmount: true,
            dueAmount: true,
            paymentMethod: true,
            notes: true,
          },
        }),
        (prisma as any).customerPayment.findMany({
          where: { shopId: context.shop.id, customerId: customer.id },
          orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
          take: 10,
          select: {
            id: true,
            amount: true,
            paymentMethod: true,
            paymentMeta: true,
            referenceNo: true,
            notes: true,
            paidAt: true,
          },
        }),
        (prisma as any).customerLedger.findMany({
          where: { shopId: context.shop.id, customerId: customer.id },
          orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
          take: 20,
          select: {
            id: true,
            entryType: true,
            referenceNo: true,
            debit: true,
            credit: true,
            notes: true,
            entryDate: true,
          },
        }),
      ]);

      const due = toMoney(summary.due);

      return response.json({
        shop: {
          id: context.shop.id,
          shopCode: context.shop.shopCode,
          shopName: context.shop.shopName,
          phone: context.shop.phone,
          address: context.shop.address,
          area: context.shop.area,
          district: context.shop.district,
          status: context.shop.status,
        },
        customer: {
          ...mapCustomerMaster(customer),
          finance: {
            totalSales: toMoney(summary.totalSales),
            totalPaid: toMoney(summary.totalPaid),
            due,
            balanceType: toBalanceType(due),
            dueLabel: due > 0 ? `Due ${due}` : "Paid",
          },
          recentSales: sales.map((sale: any) => ({
            id: sale.id,
            invoiceNo: sale.invoiceNo,
            saleDate: sale.saleDate,
            totalAmount: toMoney(sale.totalAmount),
            paidAmount: toMoney(sale.paidAmount),
            dueAmount: toMoney(sale.dueAmount),
            paymentMethod: sale.paymentMethod,
            notes: sale.notes,
          })),
          recentPayments: payments.map((payment: any) => ({
            id: payment.id,
            amount: toMoney(payment.amount),
          paymentMethod: payment.paymentMethod,
          paymentDetails: payment.paymentMeta ?? null,
          referenceNo: payment.referenceNo,
          notes: payment.notes,
          paidAt: payment.paidAt,
          })),
          recentTransactions: ledgerEntries.map((entry: any) => ({
            id: entry.id,
            entryType: entry.entryType,
            referenceNo: entry.referenceNo,
            debit: toMoney(entry.debit),
            credit: toMoney(entry.credit),
            notes: entry.notes,
            entryDate: entry.entryDate,
          })),
        },
      });
    }

    const auth = await requireCustomerAccess(request);

    if (isAuthError(auth as any)) {
      return sendAuthError(response, auth as any);
    }

    if ("status" in auth) {
      return response.status(auth.status).json(auth.body);
    }

    const customer = await resolveCustomerIdentifier(request.params.id);

    if (!customer) {
      return response.status(404).json({ message: "Customer not found." });
    }

    return response.json({
      customer: mapCustomerMaster(customer),
    });
  } catch (error) {
    console.error("Failed to load customer.", error);

    return response.status(503).json({ message: "Customer could not be loaded right now." });
  }
});

export default router;
