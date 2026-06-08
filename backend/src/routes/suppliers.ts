import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type SupplierStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";

function toDisplayStatus(status: SupplierStatusValue) {
  return status.replace(/_/g, " ");
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage suppliers." },
    };
  }

  return auth;
}

async function requireFinanceContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  const rawShopId =
    auth.payload.shopId ??
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ??
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (!rawShopId) {
    return {
      status: 400,
      body: { message: "shopId is required for supplier finance operations." },
    };
  }

  return { auth, shopId: rawShopId };
}

async function buildSupplierFinanceSummary(supplierId: string, shopId: string) {
  const [purchases, payments] = await Promise.all([
    (prisma as any).purchase.findMany({
      where: { supplierId, shopId },
      select: { totalAmount: true, paidAmount: true, dueAmount: true },
    }),
    (prisma as any).supplierPayment.findMany({
      where: { supplierId, shopId },
      select: { amount: true },
    }),
  ]);

  const totalPurchase = purchases.reduce((sum: number, row: { totalAmount: any }) => sum + Number(row.totalAmount ?? 0), 0);
  const totalPaidFromPurchases = purchases.reduce((sum: number, row: { paidAmount: any }) => sum + Number(row.paidAmount ?? 0), 0);
  const totalDue = purchases.reduce((sum: number, row: { dueAmount: any }) => sum + Number(row.dueAmount ?? 0), 0);
  const totalPaid = payments.reduce((sum: number, row: { amount: any }) => sum + Number(row.amount ?? 0), totalPaidFromPurchases);

  return {
    totalPurchase,
    totalPaid,
    due: totalDue,
  };
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

    const suppliers = await (prisma as any).supplier.findMany({
      where: {
        deletedAt: null,
        ...(status ? { status } : {}),
        ...(search
          ? {
              OR: [
                { supplierCode: { contains: search, mode: "insensitive" } },
                { name: { contains: search, mode: "insensitive" } },
                { mobile: { contains: search, mode: "insensitive" } },
                { email: { contains: search, mode: "insensitive" } },
                { contactPerson: { contains: search, mode: "insensitive" } },
                { contactPersonMobile: { contains: search, mode: "insensitive" } },
              ],
            }
          : {}),
      },
      include: {
        _count: {
          select: {
            purchases: true,
          },
        },
      },
      orderBy: [{ createdAt: "desc" }, { name: "asc" }],
    });

    return response.json({
      stats: {
        total: suppliers.length,
        active: suppliers.filter((item: { status: SupplierStatusValue }) => item.status === "ACTIVE").length,
        inactive: suppliers.filter((item: { status: SupplierStatusValue }) => item.status === "INACTIVE").length,
        archived: suppliers.filter((item: { status: SupplierStatusValue }) => item.status === "ARCHIVED").length,
      },
      suppliers: suppliers.map((supplier: any) => ({
        id: supplier.id,
        supplierCode: supplier.supplierCode,
        name: supplier.name,
        mobile: supplier.mobile,
        email: supplier.email,
        address: supplier.address,
        contactPerson: supplier.contactPerson,
        contactPersonMobile: supplier.contactPersonMobile,
        notes: supplier.notes,
        status: supplier.status,
        statusLabel: toDisplayStatus(supplier.status),
        purchases: supplier._count.purchases,
        createdAt: supplier.createdAt,
        updatedAt: supplier.updatedAt,
      })),
    });
  } catch (error) {
    console.error("Failed to load suppliers.", error);

    return response.status(503).json({
      message:
        "Suppliers are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.post("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const body = request.body as {
      supplierCode?: string;
      name?: string;
      mobile?: string | null;
      email?: string | null;
      address?: string | null;
      contactPerson?: string | null;
      contactPersonMobile?: string | null;
      notes?: string | null;
      status?: SupplierStatusValue;
    };

    const supplierCode = body.supplierCode?.trim();
    const name = body.name?.trim();
    const mobile = body.mobile?.trim() || null;
    const email = body.email?.trim() || null;
    const address = body.address?.trim() || null;
    const contactPerson = body.contactPerson?.trim() || null;
    const contactPersonMobile = body.contactPersonMobile?.trim() || null;
    const notes = body.notes?.trim() || null;
    const status = body.status ?? "ACTIVE";

    if (!supplierCode) {
      return response.status(400).json({ message: "Supplier code is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Supplier name is required." });
    }

    const existingSupplier = await (prisma as any).supplier.findFirst({
      where: {
        OR: [{ supplierCode }, { name }],
        deletedAt: null,
      },
      select: { id: true, supplierCode: true, name: true },
    });

    if (existingSupplier) {
      return response.status(409).json({
        message:
          existingSupplier.supplierCode === supplierCode
            ? "Supplier code already exists."
            : "Supplier name already exists.",
      });
    }

    const supplier = await (prisma as any).supplier.create({
      data: {
        supplierCode,
        name,
        mobile,
        email,
        address,
        contactPerson,
        contactPersonMobile,
        notes,
        status,
      },
    });

    return response.status(201).json({
      message: "Supplier created successfully.",
      supplier: {
        id: supplier.id,
        supplierCode: supplier.supplierCode,
        name: supplier.name,
        mobile: supplier.mobile,
        email: supplier.email,
        address: supplier.address,
        contactPerson: supplier.contactPerson,
        contactPersonMobile: supplier.contactPersonMobile,
        notes: supplier.notes,
        status: supplier.status,
        statusLabel: toDisplayStatus(supplier.status),
        purchases: 0,
        createdAt: supplier.createdAt,
        updatedAt: supplier.updatedAt,
      },
    });
  } catch (error) {
    console.error("Failed to create supplier.", error);

    return response.status(503).json({
      message:
        "Supplier could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.get("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const supplier = await (prisma as any).supplier.findFirst({
      where: {
        id: request.params.id,
        deletedAt: null,
      },
      include: {
        _count: {
          select: { purchases: true },
        },
      },
    });

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    return response.json({
      supplier: {
        id: supplier.id,
        supplierCode: supplier.supplierCode,
        name: supplier.name,
        mobile: supplier.mobile,
        email: supplier.email,
        address: supplier.address,
        contactPerson: supplier.contactPerson,
        contactPersonMobile: supplier.contactPersonMobile,
        notes: supplier.notes,
        status: supplier.status,
        statusLabel: toDisplayStatus(supplier.status),
        purchases: supplier._count.purchases,
        createdAt: supplier.createdAt,
        updatedAt: supplier.updatedAt,
      },
    });
  } catch (error) {
    console.error("Failed to load supplier.", error);

    return response.status(503).json({ message: "Supplier could not be loaded right now." });
  }
});

router.put("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const supplier = await (prisma as any).supplier.findFirst({
      where: { id: request.params.id, deletedAt: null },
    });

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const body = request.body as {
      supplierCode?: string;
      name?: string;
      mobile?: string | null;
      email?: string | null;
      address?: string | null;
      contactPerson?: string | null;
      contactPersonMobile?: string | null;
      notes?: string | null;
      status?: SupplierStatusValue;
    };

    const supplierCode = body.supplierCode?.trim();
    const name = body.name?.trim();
    const mobile = body.mobile?.trim() || null;
    const email = body.email?.trim() || null;
    const address = body.address?.trim() || null;
    const contactPerson = body.contactPerson?.trim() || null;
    const contactPersonMobile = body.contactPersonMobile?.trim() || null;
    const notes = body.notes?.trim() || null;
    const status = body.status ?? supplier.status;

    if (!supplierCode) {
      return response.status(400).json({ message: "Supplier code is required." });
    }

    if (!name) {
      return response.status(400).json({ message: "Supplier name is required." });
    }

    const duplicateSupplier = await (prisma as any).supplier.findFirst({
      where: {
        id: { not: request.params.id },
        deletedAt: null,
        OR: [{ supplierCode }, { name }],
      },
      select: { id: true, supplierCode: true, name: true },
    });

    if (duplicateSupplier) {
      return response.status(409).json({
        message:
          duplicateSupplier.supplierCode === supplierCode
            ? "Supplier code already exists."
            : "Supplier name already exists.",
      });
    }

    const updatedSupplier = await (prisma as any).supplier.update({
      where: { id: request.params.id },
      data: {
        supplierCode,
        name,
        mobile,
        email,
        address,
        contactPerson,
        contactPersonMobile,
        notes,
        status,
      },
    });

    return response.json({
      message: "Supplier updated successfully.",
      supplier: {
        id: updatedSupplier.id,
        supplierCode: updatedSupplier.supplierCode,
        name: updatedSupplier.name,
        mobile: updatedSupplier.mobile,
        email: updatedSupplier.email,
        address: updatedSupplier.address,
        contactPerson: updatedSupplier.contactPerson,
        contactPersonMobile: updatedSupplier.contactPersonMobile,
        notes: updatedSupplier.notes,
        status: updatedSupplier.status,
        statusLabel: toDisplayStatus(updatedSupplier.status),
        createdAt: updatedSupplier.createdAt,
        updatedAt: updatedSupplier.updatedAt,
      },
    });
  } catch (error) {
    console.error("Failed to update supplier.", error);

    return response.status(503).json({ message: "Supplier could not be updated right now." });
  }
});

router.delete("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const supplier = await (prisma as any).supplier.findFirst({
      where: { id: request.params.id, deletedAt: null },
      select: { id: true },
    });

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    await (prisma as any).supplier.update({
      where: { id: request.params.id },
      data: {
        status: "ARCHIVED",
        deletedAt: new Date(),
      },
    });

    return response.json({ message: "Supplier deleted successfully." });
  } catch (error) {
    console.error("Failed to delete supplier.", error);

    return response.status(503).json({ message: "Supplier could not be deleted right now." });
  }
});

router.patch("/:id/status", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const status = (request.body as { status?: SupplierStatusValue }).status;

    if (!status || !["ACTIVE", "INACTIVE", "ARCHIVED"].includes(status)) {
      return response.status(400).json({ message: "A valid supplier status is required." });
    }

    const supplier = await (prisma as any).supplier.findFirst({
      where: { id: request.params.id, deletedAt: null },
      select: { id: true },
    });

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const updatedSupplier = await (prisma as any).supplier.update({
      where: { id: request.params.id },
      data: { status },
    });

    return response.json({
      message: "Supplier status updated successfully.",
      supplier: {
        id: updatedSupplier.id,
        status: updatedSupplier.status,
        statusLabel: toDisplayStatus(updatedSupplier.status),
      },
    });
  } catch (error) {
    console.error("Failed to update supplier status.", error);

    return response.status(503).json({ message: "Supplier status could not be updated right now." });
  }
});

router.get("/:id/dues", async (request, response) => {
  try {
    const context = await requireFinanceContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const supplier = await (prisma as any).supplier.findFirst({
      where: { id: request.params.id, deletedAt: null },
      select: { id: true },
    });

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const summary = await buildSupplierFinanceSummary(request.params.id, context.shopId);

    return response.json({
      supplierId: request.params.id,
      shopId: context.shopId,
      totalPurchase: summary.totalPurchase,
      totalPaid: summary.totalPaid,
      due: summary.due,
    });
  } catch (error) {
    console.error("Failed to load supplier dues.", error);

    return response.status(503).json({ message: "Supplier dues could not be loaded right now." });
  }
});

router.get("/:id/ledger", async (request, response) => {
  try {
    const context = await requireFinanceContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const ledgerEntries = await (prisma as any).supplierLedger.findMany({
      where: {
        supplierId: request.params.id,
        shopId: context.shopId,
      },
      orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
    });

    let balance = 0;

    return response.json({
      supplierId: request.params.id,
      shopId: context.shopId,
      ledger: ledgerEntries.map((entry: any) => {
        balance += Number(entry.debit ?? 0) - Number(entry.credit ?? 0);

        return {
          id: entry.id,
          entryType: entry.entryType,
          referenceNo: entry.referenceNo,
          debit: Number(entry.debit ?? 0),
          credit: Number(entry.credit ?? 0),
          balance,
          notes: entry.notes,
          entryDate: entry.entryDate,
          purchaseId: entry.purchaseId,
          supplierPaymentId: entry.supplierPaymentId,
        };
      }),
    });
  } catch (error) {
    console.error("Failed to load supplier ledger.", error);

    return response.status(503).json({ message: "Supplier ledger could not be loaded right now." });
  }
});

router.post("/:id/payments", async (request, response) => {
  try {
    const context = await requireFinanceContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const body = request.body as {
      amount?: number | string;
      paymentMethod?: string | null;
      moneyBoxId?: string | null;
      notes?: string | null;
      paidAt?: string | null;
    };

    const amount = Number(body.amount);
    const paymentMethod = body.paymentMethod?.trim() || null;
    const moneyBoxId = body.moneyBoxId?.trim() || null;
    const notes = body.notes?.trim() || null;
    const paidAt = body.paidAt ? new Date(body.paidAt) : new Date();

    if (!Number.isFinite(amount) || amount <= 0) {
      return response.status(400).json({ message: "A valid payment amount is required." });
    }

    const supplier = await (prisma as any).supplier.findFirst({
      where: { id: request.params.id, deletedAt: null },
      select: { id: true, supplierCode: true },
    });

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const payment = await (prisma as any).supplierPayment.create({
      data: {
        shopId: context.shopId,
        supplierId: request.params.id,
        amount,
        paymentMethod,
        moneyBoxId,
        notes,
        paidAt,
      },
    });

    await (prisma as any).supplierLedger.create({
      data: {
        shopId: context.shopId,
        supplierId: request.params.id,
        supplierPaymentId: payment.id,
        entryType: "PAYMENT",
        referenceNo: supplier.supplierCode,
        debit: 0,
        credit: amount,
        notes,
        entryDate: paidAt,
      },
    });

    return response.status(201).json({
      message: "Supplier payment created successfully.",
      payment: {
        id: payment.id,
        shopId: payment.shopId,
        supplierId: payment.supplierId,
        amount: Number(payment.amount),
        paymentMethod: payment.paymentMethod,
        moneyBoxId: payment.moneyBoxId,
        notes: payment.notes,
        paidAt: payment.paidAt,
      },
    });
  } catch (error) {
    console.error("Failed to create supplier payment.", error);

    return response.status(503).json({ message: "Supplier payment could not be saved right now." });
  }
});

router.get("/:id/payments", async (request, response) => {
  try {
    const context = await requireFinanceContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const payments = await (prisma as any).supplierPayment.findMany({
      where: {
        supplierId: request.params.id,
        shopId: context.shopId,
      },
      orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      supplierId: request.params.id,
      shopId: context.shopId,
      payments: payments.map((payment: any) => ({
        id: payment.id,
        amount: Number(payment.amount),
        paymentMethod: payment.paymentMethod,
        moneyBoxId: payment.moneyBoxId,
        notes: payment.notes,
        paidAt: payment.paidAt,
        createdAt: payment.createdAt,
      })),
    });
  } catch (error) {
    console.error("Failed to load supplier payments.", error);

    return response.status(503).json({ message: "Supplier payments could not be loaded right now." });
  }
});

router.get("/:id/purchases", async (request, response) => {
  try {
    const context = await requireFinanceContext(request);

    if (isAuthError(context as any)) {
      return sendAuthError(response, context as any);
    }

    if ("status" in context) {
      return response.status(context.status).json(context.body);
    }

    const purchases = await (prisma as any).purchase.findMany({
      where: {
        supplierId: request.params.id,
        shopId: context.shopId,
      },
      include: {
        items: {
          include: {
            masterProduct: {
              select: { id: true, name: true, sku: true },
            },
          },
        },
      },
      orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      supplierId: request.params.id,
      shopId: context.shopId,
      purchases: purchases.map((purchase: any) => ({
        id: purchase.id,
        invoiceNo: purchase.invoiceNo,
        purchaseDate: purchase.purchaseDate,
        totalAmount: Number(purchase.totalAmount),
        paidAmount: Number(purchase.paidAmount),
        dueAmount: Number(purchase.dueAmount),
        paymentMethod: purchase.paymentMethod,
        notes: purchase.notes,
        items: purchase.items.map((item: any) => ({
          id: item.id,
          masterProductId: item.masterProductId,
          name: item.masterProduct.name,
          sku: item.masterProduct.sku,
          quantity: Number(item.quantity),
          purchasePrice: Number(item.purchasePrice),
          totalAmount: Number(item.totalAmount),
        })),
      })),
    });
  } catch (error) {
    console.error("Failed to load supplier purchases.", error);

    return response.status(503).json({ message: "Supplier purchases could not be loaded right now." });
  }
});

export default router;
