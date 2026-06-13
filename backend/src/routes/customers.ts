import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type CustomerStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

function toDisplayStatus(status: CustomerStatusValue) {
  return status.replace(/_/g, " ");
}

function toMoney(value: unknown) {
  return Number(value ?? 0);
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

  if (!["SUPER_ADMIN", "ADMIN", "SHOP_OWNER"].includes(auth.payload.role)) {
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

  if (auth.payload.role === "SHOP_OWNER" && auth.payload.shopId && auth.payload.shopId !== rawShopId) {
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
    status: customer.status,
    statusLabel: toDisplayStatus(customer.status),
    createdAt: customer.createdAt,
    updatedAt: customer.updatedAt,
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
            ...(search
              ? []
              : [
                  {
                    OR: [
                      { sales: { some: { shopId: context.shop.id } } },
                      { payments: { some: { shopId: context.shop.id } } },
                      { ledgerEntries: { some: { shopId: context.shop.id } } },
                      {
                        AND: [
                          { sales: { none: {} } },
                          { payments: { none: {} } },
                          { ledgerEntries: { none: {} } },
                        ],
                      },
                    ],
                  },
                ]),
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
      return response.status(409).json({
        message: "Customer already exists. Duplicate customer add is blocked.",
        customer: {
          id: duplicateCustomer.id,
          customerCode: duplicateCustomer.customerCode,
          name: duplicateCustomer.name,
          companyOrPersonName: duplicateCustomer.name,
          mobile: duplicateCustomer.mobile,
        },
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
      paymentMethod?: string | null;
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
      }>;
    };

    const customer = await resolveCustomerIdentifier(body.customerId);

    if (!customer) {
      return response.status(404).json({ message: "Customer not found." });
    }

    const items = body.items ?? [];

    if (items.length === 0) {
      return response.status(400).json({ message: "At least one sale item is required." });
    }

    const normalizedItems = items.map((item) => {
      const masterProductId = item.masterProductId || item.productId || item.shopProductId || "";
      const quantity = Number(item.quantity ?? item.qty ?? 0);
      const salePrice = Number(item.salePrice ?? item.unitPrice ?? item.price ?? 0);

      return {
        masterProductId,
        quantity,
        salePrice,
        totalAmount: Number((quantity * salePrice).toFixed(2)),
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

    if (!Number.isFinite(paidAmount) || paidAmount < 0) {
      return response.status(400).json({ message: "Paid amount must be a valid number." });
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

    if (body.moneyBoxId && !moneyBox) {
      return response.status(404).json({ message: "Money box not found for this shop." });
    }

    const totalAmount = Number(normalizedItems.reduce((sum, item) => sum + item.totalAmount, 0).toFixed(2));

    if (paidAmount > totalAmount) {
      return response.status(400).json({ message: "Paid amount cannot be greater than total sale amount." });
    }

    const dueAmount = Number((totalAmount - paidAmount).toFixed(2));
    const saleDate = body.saleDate ? new Date(body.saleDate) : new Date();

    const sale = await (prisma as any).$transaction(async (tx: any) => {
      const createdSale = await tx.customerSale.create({
        data: {
          shopId: context.shop.id,
          customerId: customer.id,
          invoiceNo: body.invoiceNo?.trim() || null,
          saleDate,
          totalAmount,
          paidAmount,
          dueAmount,
          paymentMethod: body.paymentMethod?.trim() || null,
          notes: body.notes?.trim() || null,
          items: {
            create: normalizedItems.map((item) => ({
              masterProductId: item.masterProductId,
              quantity: item.quantity,
              salePrice: item.salePrice,
              totalAmount: item.totalAmount,
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

      let payment: any = null;

      if (paidAmount > 0) {
        payment = await tx.customerPayment.create({
          data: {
            shopId: context.shop.id,
            customerId: customer.id,
            amount: paidAmount,
            paymentMethod: body.paymentMethod?.trim() || null,
            moneyBoxId: moneyBox?.id ?? null,
            referenceNo: createdSale.invoiceNo || null,
            notes: body.notes?.trim() || null,
            paidAt: saleDate,
          },
        });

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
        })),
      },
      payment: sale.payment
        ? {
            id: sale.payment.id,
            amount: toMoney(sale.payment.amount),
            paymentMethod: sale.payment.paymentMethod,
            moneyBoxId: sale.payment.moneyBoxId,
            referenceNo: sale.payment.referenceNo,
            paidAt: sale.payment.paidAt,
          }
        : null,
    });
  } catch (error) {
    console.error("Failed to create customer sale.", error);

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

    const customer = await resolveCustomerIdentifier(request.params.id);

    if (!customer) {
      return response.status(404).json({ message: "Customer not found." });
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

    const customer = await resolveCustomerIdentifier(request.params.id);

    if (!customer) {
      return response.status(404).json({ message: "Customer not found." });
    }

    const body = request.body as {
      amount?: number | string | null;
      paymentMethod?: string | null;
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

    const moneyBox = await resolveShopMoneyBox(context.shop.id, body.moneyBoxId);

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
          paymentMethod: body.paymentMethod?.trim() || null,
          moneyBoxId: moneyBox?.id ?? null,
          referenceNo: body.referenceNo?.trim() || null,
          notes: body.notes?.trim() || null,
          paidAt,
        },
      });

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

    const customer = await resolveCustomerIdentifier(request.params.id);

    if (!customer) {
      return response.status(404).json({ message: "Customer not found." });
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

      const customer = await resolveCustomerIdentifier(request.params.id);

      if (!customer) {
        return response.status(404).json({ message: "Customer not found." });
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
