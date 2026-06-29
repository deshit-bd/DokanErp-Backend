import { Router, Request, Response } from "express";
import crypto from "crypto";

import {
  getAuthenticatedUser,
  isAuthError,
  sendAuthError,
  type AuthenticatedUser,
  type AuthError,
} from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type SupplierDueVerificationRecord = {
  token: string;
  code: string;
  expiresAt: number;
  status: "PENDING" | "CONFIRMED";
  supplierName: string;
  dueAmount: number;
  paymentAmount: number;
  paymentMethod: string;
  notes: string[];
};

const supplierDueOtps = new Map<string, SupplierDueVerificationRecord>();

type SupplierStatusValue = "ACTIVE" | "INACTIVE" | "ARCHIVED";
type PaymentMetaInput = {
  senderNumber?: string | null;
  transactionId?: string | null;
  cardHolderName?: string | null;
  cardLast4?: string | null;
  cardType?: string | null;
  approvalCode?: string | null;
};

function toDisplayStatus(status: SupplierStatusValue) {
  return status.replace(/_/g, " ");
}

function toMoney(value: unknown) {
  return Number(value ?? 0);
}

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function normalizeWhatsAppNumber(value: unknown) {
  const digits = `${value ?? ""}`.replace(/\D/g, "");

  if (!digits) {
    return "";
  }

  if (digits.length === 11 && digits.startsWith("01")) {
    return `88${digits}`;
  }

  if (digits.length === 10 && digits.startsWith("1")) {
    return `880${digits}`;
  }

  if (digits.length === 13 && digits.startsWith("880")) {
    return digits;
  }

  return digits;
}

function findSupplierRecordByToken(token: string) {
  for (const [phone, record] of supplierDueOtps.entries()) {
    if (record.token === token) {
      return { phone, record };
    }
  }

  return null;
}

export async function handleGetConfirmSupplierDue(request: Request, response: Response) {
  try {
    const token = request.params.token;
    if (typeof token !== "string") {
      return response.status(400).send("Invalid token");
    }

    const found = findSupplierRecordByToken(token);
    if (!found || Date.now() > found.record.expiresAt) {
      return response.status(400).send("Invalid link or link has expired.");
    }

    const { phone, record } = found;
    const notesHtml =
      record.notes.length > 0
        ? `
          <div class="details-title">পেমেন্ট বিবরণ:</div>
          <ul>${record.notes.map((item) => `<li>${item}</li>`).join("")}</ul>
        `
        : "";
    const statusHtml =
      record.status === "CONFIRMED"
        ? `<div class="success-banner">আপনি এই পেমেন্ট নিশ্চিত করেছেন।</div>`
        : "";

    return response.send(`
      <!doctype html>
      <html lang="bn">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Supplier Due Confirmation</title>
        <style>
          body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: linear-gradient(180deg, #eefbf8 0%, #f7faf9 100%);
            color: #163732;
          }
          .card {
            max-width: 520px;
            margin: 32px auto;
            background: white;
            border-radius: 24px;
            padding: 28px;
            box-shadow: 0 16px 40px rgba(12, 140, 103, 0.08);
          }
          .header {
            text-align: center;
            margin-bottom: 24px;
          }
          .logo {
            font-size: 24px;
            font-weight: 800;
            color: #0c8c67;
          }
          .subtitle {
            color: #5f6a66;
            font-size: 15px;
            margin-top: 8px;
          }
          .amount-section {
            background: #f7faf9;
            border: 1px solid #d9e5e1;
            border-radius: 18px;
            padding: 20px;
            text-align: center;
            margin-bottom: 18px;
          }
          .amount-label {
            color: #5f6a66;
            font-size: 14px;
            margin-bottom: 8px;
          }
          .amount-value {
            color: #b3261e;
            font-size: 32px;
            font-weight: 800;
          }
          .detail-card {
            border: 1px solid #d9e5e1;
            border-radius: 18px;
            padding: 18px;
            margin-bottom: 18px;
          }
          .detail-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 10px;
            font-size: 15px;
          }
          .detail-label {
            color: #5f6a66;
            font-weight: 700;
          }
          .details-title {
            color: #163732;
            font-size: 15px;
            font-weight: 800;
            margin: 18px 0 10px;
          }
          ul {
            margin: 0;
            padding-left: 20px;
          }
          li {
            margin-bottom: 8px;
          }
          .btn-confirm {
            display: block;
            width: 100%;
            background-color: #0c8c67;
            color: white;
            border: none;
            padding: 15px;
            font-size: 17px;
            font-weight: 700;
            border-radius: 12px;
            cursor: pointer;
            text-align: center;
            box-shadow: 0 4px 12px rgba(12,140,103,0.15);
          }
          .success-banner {
            background: #e7f5ef;
            color: #0c8c67;
            border: 1px solid #b6dfd1;
            border-radius: 14px;
            padding: 12px 14px;
            margin-bottom: 16px;
            font-weight: 700;
            text-align: center;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="header">
            <div class="logo">Dokan ERP</div>
            <div class="subtitle">সরবরাহকারী বকেয়া পেমেন্ট অনুমোদন</div>
          </div>

          ${statusHtml}

          <div class="amount-section">
            <div class="amount-label">পরিশোধের পরিমাণ</div>
            <div class="amount-value">৳${record.paymentAmount}</div>
          </div>

          <div class="detail-card">
            <div class="detail-row">
              <span class="detail-label">সরবরাহকারীর নাম:</span>
              <span>${record.supplierName}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">মোবাইল নম্বর:</span>
              <span>${phone}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">বর্তমান বকেয়া:</span>
              <span>৳${record.dueAmount}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">পেমেন্ট পদ্ধতি:</span>
              <span>${record.paymentMethod}</span>
            </div>
            ${notesHtml}
          </div>

          <form method="POST" action="/confirm-supplier-due/${token}">
            <button type="submit" class="btn-confirm">আমি এই পেমেন্ট নিশ্চিত করছি</button>
          </form>
        </div>
      </body>
      </html>
    `);
  } catch (error) {
    console.error(error);
    return response.status(500).send("Internal Server Error");
  }
}

export async function handlePostConfirmSupplierDue(request: Request, response: Response) {
  try {
    const token = request.params.token;
    if (typeof token !== "string") {
      return response.status(400).send("Invalid token");
    }

    const found = findSupplierRecordByToken(token);
    if (!found || Date.now() > found.record.expiresAt) {
      return response.status(400).send("Invalid link or link has expired.");
    }

    found.record.status = "CONFIRMED";
    supplierDueOtps.set(found.phone, found.record);

    return response.redirect(`/confirm-supplier-due/${token}`);
  } catch (error) {
    console.error(error);
    return response.status(500).send("Internal Server Error");
  }
}

function normalizeSupplierPayment(
  paymentMethodRaw: unknown,
  paymentMetaRaw: PaymentMetaInput | null | undefined,
) {
  const paymentMethod = normalizeText(paymentMethodRaw).toUpperCase() || "CASH";

  if (paymentMethod === "CASH" || paymentMethod === "BANK") {
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

  if (paymentMethod === "DUE") {
    return { error: "DUE is not a valid method for supplier payment collection." };
  }

  return { paymentMethod, paymentMeta: null as Record<string, string> | null };
}

function toBalanceType(due: number) {
  return due > 0 ? "DUE" : "CLEAR";
}

function buildSupplierCodeBase(name: string) {
  const normalized = name
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, "")
    .slice(0, 6);

  return normalized || "SUP";
}

async function createUniqueSupplierCode(name: string) {
  const base = buildSupplierCodeBase(name);

  for (let attempt = 0; attempt < 10; attempt += 1) {
    const suffix = `${Date.now()}`.slice(-4) + `${Math.floor(Math.random() * 100)}`.padStart(2, "0");
    const candidate = `${base}-${suffix}`;
    const existing = await (prisma as any).supplier.findFirst({
      where: { supplierCode: candidate },
      select: { id: true },
    });

    if (!existing) {
      return candidate;
    }
  }

  return `${base}-${Math.floor(Date.now() / 1000)}`;
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

async function resolveSupplierIdentifier(supplierIdentifier?: string | null) {
  const normalized = supplierIdentifier?.trim();

  if (!normalized) {
    return null;
  }

  return (prisma as any).supplier.findFirst({
    where: {
      deletedAt: null,
      OR: [{ id: normalized }, { supplierCode: normalized }],
    },
    select: {
      id: true,
      supplierCode: true,
      name: true,
      mobile: true,
      email: true,
      address: true,
      contactPerson: true,
      contactPersonMobile: true,
      notes: true,
      status: true,
      createdAt: true,
      updatedAt: true,
    },
  });
}

async function resolveRequestedSupplierShopIdentifier(
  request: Parameters<typeof getAuthenticatedUser>[0],
) {
  const explicitShopIdentifier =
    (typeof request.query.shopId === "string" ? request.query.shopId.trim() : "") ||
    ((request.body as { shopId?: string } | undefined)?.shopId?.trim() ?? "");

  if (explicitShopIdentifier) {
    return explicitShopIdentifier;
  }

  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return null;
  }

  if (auth.payload.appType === "MOBILE" && auth.payload.shopId) {
    return auth.payload.shopId;
  }

  return null;
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

  if (auth.payload.role !== "SHOP_OWNER") {
    return {
      status: 403,
      body: { message: "Only shop owners can access supplier app routes." },
    };
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

async function resolveFinanceShop(
  request: Parameters<typeof getAuthenticatedUser>[0],
): Promise<
  | AuthError
  | { status: number; body: { message: string } }
  | { auth: AuthenticatedUser; shop: NonNullable<Awaited<ReturnType<typeof resolveShopIdentifier>>> }
> {
  const context = await requireFinanceContext(request);

  if (isAuthError(context as AuthError)) {
    return context as AuthError;
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

async function buildSupplierFinanceSummary(supplierId: string, shopId: string) {
  const ledgerEntries = await (prisma as any).supplierLedger.findMany({
    where: { supplierId, shopId },
    select: { debit: true, credit: true, entryType: true },
  });

  const totalDebit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);
  const totalCredit = ledgerEntries.reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);

  const totalPurchase = ledgerEntries
    .filter((entry: any) => entry.entryType === "PURCHASE")
    .reduce((sum: number, entry: any) => sum + Number(entry.debit ?? 0), 0);

  const totalPaid = ledgerEntries
    .filter((entry: any) => entry.entryType === "PAYMENT")
    .reduce((sum: number, entry: any) => sum + Number(entry.credit ?? 0), 0);

  const due = Math.max(0, totalDebit - totalCredit);

  return {
    totalPurchase,
    totalPaid,
    due,
  };
}

router.post("/send-due-otp", async (request, response) => {
  try {
    const { phone, supplierName, dueAmount, paymentAmount, paymentMethod, notes } = request.body as {
      phone: string;
      supplierName: string;
      dueAmount: number;
      paymentAmount: number;
      paymentMethod?: string;
      notes?: string[];
    };

    const normalizedPhone = normalizeText(phone);
    const normalizedName = normalizeText(supplierName) || "সরবরাহকারী";
    const normalizedDueAmount = Number(dueAmount ?? 0);
    const normalizedPaymentAmount = Number(paymentAmount ?? 0);
    const normalizedPaymentMethod = normalizeText(paymentMethod) || "CASH";
    const normalizedNotes = Array.isArray(notes)
      ? notes.map((item) => normalizeText(item)).filter(Boolean)
      : [];

    if (!normalizedPhone) {
      return response.status(400).json({ message: "Mobile number is required." });
    }

    if (!Number.isFinite(normalizedPaymentAmount) || normalizedPaymentAmount <= 0) {
      return response.status(400).json({ message: "Payment amount must be greater than 0." });
    }

    const code = Math.floor(1000 + Math.random() * 9000).toString();
    const token = crypto.randomBytes(16).toString("hex");
    supplierDueOtps.set(normalizedPhone, {
      token,
      code,
      expiresAt: Date.now() + 10 * 60 * 1000,
      status: "PENDING",
      supplierName: normalizedName,
      dueAmount: normalizedDueAmount,
      paymentAmount: normalizedPaymentAmount,
      paymentMethod: normalizedPaymentMethod,
      notes: normalizedNotes,
    });

    const envBaseUrl = process.env.BASE_URL;
    let baseUrl = "";
    if (envBaseUrl && envBaseUrl.trim() !== "") {
      baseUrl = envBaseUrl.trim().replace(/\/$/, "");
    } else {
      const protocol = request.protocol;
      const host = request.get("host");
      baseUrl = `${protocol}://${host}`;
    }
    const confirmationUrl = `${baseUrl}/confirm-supplier-due/${token}`;

    const messageParts = [
      `প্রিয় ${normalizedName},`,
      `Dokan ERP থেকে আপনার বকেয়া পরিশোধের জন্য ৳${normalizedPaymentAmount} টাকা পাঠানো হচ্ছে। নিশ্চিত করতে নিচের লিংকে ক্লিক করুন:`,
      confirmationUrl,
      "",
      `বর্তমান বকেয়া: ৳${normalizedDueAmount}`,
      `পেমেন্ট পদ্ধতি: ${normalizedPaymentMethod}`,
      normalizedNotes.length === 0 ? "" : `বিবরণ:\n${normalizedNotes.map((item) => `• ${item}`).join("\n")}`,
      "",
      "এই লিংক ১০ মিনিট পর্যন্ত কার্যকর থাকবে।",
    ].filter(Boolean);
    const whatsappMessage = messageParts.join("\n");
    const whatsappNumber = normalizeWhatsAppNumber(normalizedPhone);
    const whatsappUrl = whatsappNumber
      ? `https://wa.me/${whatsappNumber}?text=${encodeURIComponent(whatsappMessage)}`
      : `https://wa.me/?text=${encodeURIComponent(whatsappMessage)}`;

    return response.json({
      message: "Supplier confirmation prepared successfully for WhatsApp.",
      channel: "WHATSAPP",
      whatsappUrl,
      otp: code,
    });
  } catch (error) {
    console.error("Failed to send supplier due confirmation request.", error);
    return response.status(500).json({ message: "Failed to send supplier confirmation request." });
  }
});

router.post("/verify-due-otp", async (request, response) => {
  try {
    const { phone, otp } = request.body as {
      phone: string;
      otp?: string;
    };

    if (!phone) {
      return response.status(400).json({ message: "Phone number is required." });
    }

    const normalizedPhone = normalizeText(phone);
    const record = supplierDueOtps.get(normalizedPhone);
    if (!record) {
      return response.status(400).json({ message: "Request not found or expired." });
    }

    if (Date.now() > record.expiresAt) {
      supplierDueOtps.delete(normalizedPhone);
      return response.status(400).json({ message: "Request has expired." });
    }

    const isWebConfirmed = record.status === "CONFIRMED";
    const isOtpCorrect = otp && otp.trim() !== "" && record.code === otp.trim();

    if (!isWebConfirmed && !isOtpCorrect) {
      return response.json({
        verified: false,
        message: "সরবরাহকারী এখনও পেমেন্ট নিশ্চিত করেননি।",
      });
    }

    supplierDueOtps.delete(normalizedPhone);

    return response.json({
      verified: true,
      message: "Confirmed successfully.",
    });
  } catch (error) {
    console.error("Failed to verify supplier confirmation request.", error);
    return response.status(500).json({ message: "Failed to verify supplier confirmation request." });
  }
});

router.get("/", async (request, response) => {
  try {
    const requestedShopIdentifier = await resolveRequestedSupplierShopIdentifier(request);

    if (requestedShopIdentifier) {
      const context = await resolveFinanceShop(request);

      if (isAuthError(context as AuthError)) {
        return sendAuthError(response, context as AuthError);
      }

      if ("status" in context) {
        return response.status(context.status).json(context.body);
      }

      const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
      const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";
      const scope = typeof request.query.scope === "string" ? request.query.scope.trim().toLowerCase() : "finance";
      const financeOnly = scope !== "all";

      const suppliers = await (prisma as any).supplier.findMany({
        where: {
          deletedAt: null,
          ...(status ? { status } : {}),
          AND: [
            ...(financeOnly
              ? [
                  {
                    OR: [
                      { purchases: { some: { shopId: context.shop.id } } },
                      { supplierPayments: { some: { shopId: context.shop.id } } },
                      { supplierLedgers: { some: { shopId: context.shop.id } } },
                    ],
                  },
                ]
              : []),
            ...(search
              ? [
                  {
                    OR: [
                      { supplierCode: { contains: search, mode: "insensitive" } },
                      { name: { contains: search, mode: "insensitive" } },
                      { mobile: { contains: search, mode: "insensitive" } },
                      { email: { contains: search, mode: "insensitive" } },
                      { contactPerson: { contains: search, mode: "insensitive" } },
                      { contactPersonMobile: { contains: search, mode: "insensitive" } },
                    ],
                  },
                ]
              : []),
          ],
        },
        include: {
          supplierLedgers: {
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

      const supplierSummaries = await Promise.all(
        suppliers.map(async (supplier: any) => {
          const summary = await buildSupplierFinanceSummary(supplier.id, context.shop.id);
          const due = toMoney(summary.due);
          const totalPurchase = toMoney(summary.totalPurchase);
          const totalPaid = toMoney(summary.totalPaid);
          const lastLedgerEntry = supplier.supplierLedgers[0] ?? null;

          return {
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
            avatarLabel: supplier.name?.charAt(0)?.toUpperCase() ?? "S",
            totalPurchase,
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
          total: supplierSummaries.length,
          active: supplierSummaries.filter((item) => item.status === "ACTIVE").length,
          inactive: supplierSummaries.filter((item) => item.status === "INACTIVE").length,
          archived: supplierSummaries.filter((item) => item.status === "ARCHIVED").length,
          totalDue: supplierSummaries.reduce((sum, item) => sum + item.due, 0),
        },
        suppliers: supplierSummaries,
      });
    }

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
    const body = request.body as {
      shopId?: string;
      supplierCode?: string;
      companyOrPersonName?: string;
      name?: string;
      mobile?: string | null;
      email?: string | null;
      address?: string | null;
      productType?: string | null;
      shortNote?: string | null;
      contactPerson?: string | null;
      contactPersonMobile?: string | null;
      notes?: string | null;
      dueAmount?: number | string | null;
      sendWhatsAppInvite?: boolean;
      status?: SupplierStatusValue;
    };

    const requestedShopIdentifier = await resolveRequestedSupplierShopIdentifier(request);
    const supplierCode = body.supplierCode?.trim();
    const name = body.name?.trim() || body.companyOrPersonName?.trim();
    const mobile = body.mobile?.trim() || null;
    const email = body.email?.trim() || null;
    const address = body.address?.trim() || null;
    const productType = body.productType?.trim() || null;
    const shortNote = body.shortNote?.trim() || null;
    const contactPerson = body.contactPerson?.trim() || productType;
    const contactPersonMobile = body.contactPersonMobile?.trim() || null;
    const notes = body.notes?.trim() || shortNote;
    const dueAmount = Number(body.dueAmount ?? 0);
    const sendWhatsAppInvite = Boolean(body.sendWhatsAppInvite);
    const status = body.status ?? "ACTIVE";

    if (!name) {
      return response.status(400).json({ message: "Supplier name is required." });
    }

    if (requestedShopIdentifier) {
      const context = await resolveFinanceShop(request);

      if (isAuthError(context as AuthError)) {
        return sendAuthError(response, context as AuthError);
      }

      if ("status" in context) {
        return response.status(context.status).json(context.body);
      }

      if (!mobile) {
        return response.status(400).json({ message: "Supplier mobile number is required." });
      }

      if (!Number.isFinite(dueAmount) || dueAmount < 0) {
        return response.status(400).json({ message: "dueAmount must be a valid positive number or 0." });
      }

      const generatedSupplierCode = supplierCode || (await createUniqueSupplierCode(name));

      const existingSupplier = await (prisma as any).supplier.findFirst({
        where: {
          deletedAt: null,
          OR: [
            { supplierCode: generatedSupplierCode },
            { mobile },
            { name },
          ],
        },
        select: {
          id: true,
          supplierCode: true,
          name: true,
          mobile: true,
          email: true,
          address: true,
          contactPerson: true,
          contactPersonMobile: true,
          notes: true,
          status: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      if (existingSupplier) {
        const alreadyLinkedToShop = await (prisma as any).supplier.findFirst({
          where: {
            id: existingSupplier.id,
            OR: [
              { purchases: { some: { shopId: context.shop.id } } },
              { supplierPayments: { some: { shopId: context.shop.id } } },
              { supplierLedgers: { some: { shopId: context.shop.id } } },
            ],
          },
          select: { id: true },
        });

        if (alreadyLinkedToShop) {
          return response.status(409).json({
            message: "Supplier already added for this shop.",
            shop: {
              id: context.shop.id,
              shopCode: context.shop.shopCode,
              shopName: context.shop.shopName,
            },
            supplier: {
              id: existingSupplier.id,
              supplierCode: existingSupplier.supplierCode,
              name: existingSupplier.name,
              companyOrPersonName: existingSupplier.name,
              mobile: existingSupplier.mobile,
            },
          });
        }

        const openingDueEntry = await (prisma as any).supplierLedger.create({
          data: {
            shopId: context.shop.id,
            supplierId: existingSupplier.id,
            entryType: "OPENING_DUE",
            referenceNo: existingSupplier.supplierCode,
            debit: dueAmount,
            credit: 0,
            notes:
              notes ||
              (dueAmount > 0
                ? "Opening due added while linking existing global supplier to shop."
                : "Existing global supplier linked to this shop."),
            entryDate: new Date(),
          },
        });

        if (sendWhatsAppInvite && mobile) {
          console.log(
            `[supplier] WhatsApp invite requested for existing supplier ${mobile} (${existingSupplier.id}) in shop ${context.shop.id}`,
          );
        }

        return response.status(200).json({
          message: "Existing global supplier linked to this shop successfully.",
          shop: {
            id: context.shop.id,
            shopCode: context.shop.shopCode,
            shopName: context.shop.shopName,
          },
          supplier: {
            id: existingSupplier.id,
            supplierCode: existingSupplier.supplierCode,
            name: existingSupplier.name,
            companyOrPersonName: existingSupplier.name,
            mobile: existingSupplier.mobile,
            email: existingSupplier.email,
            address: existingSupplier.address,
            productType: existingSupplier.contactPerson,
            shortNote: existingSupplier.notes,
            contactPerson: existingSupplier.contactPerson,
            contactPersonMobile: existingSupplier.contactPersonMobile,
            notes: existingSupplier.notes,
            status: existingSupplier.status,
            statusLabel: toDisplayStatus(existingSupplier.status),
            createdAt: existingSupplier.createdAt,
            updatedAt: existingSupplier.updatedAt,
          },
          openingDue: {
            amount: dueAmount,
            entryType: openingDueEntry.entryType,
            ledgerId: openingDueEntry.id,
          },
          sendWhatsAppInvite,
        });
      }

      const supplier = await (prisma as any).supplier.create({
        data: {
          supplierCode: generatedSupplierCode,
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

      const openingDueEntry = await (prisma as any).supplierLedger.create({
        data: {
          shopId: context.shop.id,
          supplierId: supplier.id,
          entryType: "OPENING_DUE",
          referenceNo: supplier.supplierCode,
          debit: dueAmount,
          credit: 0,
          notes: notes || (dueAmount > 0 ? "Opening due added during supplier creation." : "Supplier created for this shop."),
          entryDate: new Date(),
        },
      });

      if (sendWhatsAppInvite && mobile) {
        console.log(`[supplier] WhatsApp invite requested for ${mobile} (${supplier.id}) in shop ${context.shop.id}`);
      }

      return response.status(201).json({
        message: "Supplier created successfully.",
        shop: {
          id: context.shop.id,
          shopCode: context.shop.shopCode,
          shopName: context.shop.shopName,
        },
        supplier: {
          id: supplier.id,
          supplierCode: supplier.supplierCode,
          name: supplier.name,
          companyOrPersonName: supplier.name,
          mobile: supplier.mobile,
          email: supplier.email,
          address: supplier.address,
          productType: supplier.contactPerson,
          shortNote: supplier.notes,
          contactPerson: supplier.contactPerson,
          contactPersonMobile: supplier.contactPersonMobile,
          notes: supplier.notes,
          status: supplier.status,
          statusLabel: toDisplayStatus(supplier.status),
          createdAt: supplier.createdAt,
          updatedAt: supplier.updatedAt,
        },
        openingDue: {
          amount: dueAmount,
          entryType: openingDueEntry.entryType,
          ledgerId: openingDueEntry.id,
        },
        sendWhatsAppInvite,
      });
    }

    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    if (!supplierCode) {
      return response.status(400).json({ message: "Supplier code is required." });
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
    const requestedShopIdentifier = await resolveRequestedSupplierShopIdentifier(request);

    if (requestedShopIdentifier) {
      const context = await resolveFinanceShop(request);

      if (isAuthError(context as AuthError)) {
        return sendAuthError(response, context as AuthError);
      }

      if ("status" in context) {
        return response.status(context.status).json(context.body);
      }

      const supplier = await resolveSupplierIdentifier(request.params.id);

      if (!supplier) {
        return response.status(404).json({ message: "Supplier not found." });
      }

      const [summary, purchases, payments, ledgerEntries] = await Promise.all([
        buildSupplierFinanceSummary(supplier.id, context.shop.id),
        (prisma as any).purchase.findMany({
          where: {
            shopId: context.shop.id,
            supplierId: supplier.id,
          },
          orderBy: [{ purchaseDate: "desc" }, { createdAt: "desc" }],
          take: 5,
          select: {
            id: true,
            invoiceNo: true,
            purchaseDate: true,
            totalAmount: true,
            paidAmount: true,
            dueAmount: true,
            notes: true,
          },
        }),
        (prisma as any).supplierPayment.findMany({
          where: {
            shopId: context.shop.id,
            supplierId: supplier.id,
          },
          orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
          take: 5,
          select: {
            id: true,
            amount: true,
            paymentMethod: true,
            paymentMeta: true,
            notes: true,
            paidAt: true,
          },
        }),
        (prisma as any).supplierLedger.findMany({
          where: {
            shopId: context.shop.id,
            supplierId: supplier.id,
          },
          orderBy: [{ entryDate: "desc" }, { createdAt: "desc" }],
          take: 10,
          select: {
            id: true,
            entryType: true,
            referenceNo: true,
            debit: true,
            credit: true,
            notes: true,
            entryDate: true,
            purchaseId: true,
            supplierPaymentId: true,
            purchase: {
              select: {
                paymentMethod: true,
              },
            },
            supplierPayment: {
              select: {
                paymentMethod: true,
              },
            },
          },
        }),
      ]);

      const due = toMoney(summary.due);

      return response.json({
        shop: {
          id: context.shop.id,
          shopCode: context.shop.shopCode,
          shopName: context.shop.shopName,
        },
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
          summary: {
            totalPurchase: toMoney(summary.totalPurchase),
            totalPaid: toMoney(summary.totalPaid),
            due,
            balanceType: toBalanceType(due),
          },
          recentPurchases: purchases.map((purchase: any) => ({
            id: purchase.id,
            invoiceNo: purchase.invoiceNo,
            purchaseDate: purchase.purchaseDate,
            totalAmount: toMoney(purchase.totalAmount),
            paidAmount: toMoney(purchase.paidAmount),
            dueAmount: toMoney(purchase.dueAmount),
            notes: purchase.notes,
          })),
          recentPayments: payments.map((payment: any) => ({
            id: payment.id,
            amount: toMoney(payment.amount),
            paymentMethod: payment.paymentMethod,
            paymentDetails: payment.paymentMeta ?? null,
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
            purchaseId: entry.purchaseId,
            supplierPaymentId: entry.supplierPaymentId,
            paymentMethod: entry.purchase?.paymentMethod ?? entry.supplierPayment?.paymentMethod ?? null,
          })),
          createdAt: supplier.createdAt,
          updatedAt: supplier.updatedAt,
        },
      });
    }

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

    const supplier = await resolveSupplierIdentifier(request.params.id);

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const shop = await resolveShopIdentifier(context.shopId);

    if (!shop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const summary = await buildSupplierFinanceSummary(supplier.id, shop.id);

    return response.json({
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
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

    const supplier = await resolveSupplierIdentifier(request.params.id);

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const shop = await resolveShopIdentifier(context.shopId);

    if (!shop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const ledgerEntries = await (prisma as any).supplierLedger.findMany({
      where: {
        supplierId: supplier.id,
        shopId: shop.id,
      },
      include: {
        purchase: {
          select: {
            paymentMethod: true,
          },
        },
        supplierPayment: {
          select: {
            paymentMethod: true,
          },
        },
      },
      orderBy: [{ entryDate: "asc" }, { createdAt: "asc" }],
    });

    let balance = 0;

    return response.json({
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
      ledger: ledgerEntries.map((entry: any) => {
        balance += Number(entry.debit ?? 0) - Number(entry.credit ?? 0);
        const paymentMethod = entry.purchase?.paymentMethod ?? entry.supplierPayment?.paymentMethod ?? null;

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
          paymentMethod,
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
      paymentDetails?: PaymentMetaInput | null;
      moneyBoxId?: string | null;
      notes?: string | null;
      paidAt?: string | null;
    };

    const amount = Number(body.amount);
    const moneyBoxId = body.moneyBoxId?.trim() || null;
    const notes = body.notes?.trim() || null;
    const paidAt = body.paidAt ? new Date(body.paidAt) : new Date();

    if (!Number.isFinite(amount) || amount <= 0) {
      return response.status(400).json({ message: "A valid payment amount is required." });
    }

    const paymentInfo = normalizeSupplierPayment(body.paymentMethod, body.paymentDetails);

    if ("error" in paymentInfo) {
      return response.status(400).json({ message: paymentInfo.error });
    }

    const supplier = await resolveSupplierIdentifier(request.params.id);

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const shop = await resolveShopIdentifier(context.shopId);

    if (!shop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const payment = await (prisma as any).supplierPayment.create({
      data: {
        shopId: shop.id,
        supplierId: supplier.id,
        amount,
        paymentMethod: paymentInfo.paymentMethod,
        paymentMeta: paymentInfo.paymentMeta,
        moneyBoxId,
        notes,
        paidAt,
      },
    });

    await (prisma as any).supplierLedger.create({
      data: {
        shopId: shop.id,
        supplierId: supplier.id,
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
        paymentDetails: payment.paymentMeta ?? null,
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

    const supplier = await resolveSupplierIdentifier(request.params.id);

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const shop = await resolveShopIdentifier(context.shopId);

    if (!shop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const payments = await (prisma as any).supplierPayment.findMany({
      where: {
        supplierId: supplier.id,
        shopId: shop.id,
      },
      orderBy: [{ paidAt: "desc" }, { createdAt: "desc" }],
    });

    return response.json({
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
      payments: payments.map((payment: any) => ({
        id: payment.id,
        amount: Number(payment.amount),
        paymentMethod: payment.paymentMethod,
        paymentDetails: payment.paymentMeta ?? null,
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

    const supplier = await resolveSupplierIdentifier(request.params.id);

    if (!supplier) {
      return response.status(404).json({ message: "Supplier not found." });
    }

    const shop = await resolveShopIdentifier(context.shopId);

    if (!shop) {
      return response.status(404).json({ message: "Shop not found for the provided shopId/shopCode." });
    }

    const purchases = await (prisma as any).purchase.findMany({
      where: {
        supplierId: supplier.id,
        shopId: shop.id,
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
      supplierId: supplier.id,
      supplierCode: supplier.supplierCode,
      shopId: shop.id,
      shopCode: shop.shopCode,
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
