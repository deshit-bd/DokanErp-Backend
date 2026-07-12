import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type BankAccountTypeValue = "CURRENT" | "SAVINGS";
type BankAccountStatusValue = "ACTIVE" | "INACTIVE" | "CLOSED";

function toDisplayLabel(value: string) {
  return value.replace(/_/g, " ");
}

function maskAccountNumber(value: string) {
  const trimmed = value.trim();

  if (trimmed.length <= 4) {
    return trimmed;
  }

  return `${"*".repeat(Math.max(trimmed.length - 4, 0))}${trimmed.slice(-4)}`;
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage bank accounts." },
    };
  }

  return auth;
}

function mapBankAccount(bankAccount: any) {
  return {
    id: bankAccount.id,
    shopId: bankAccount.shopId,
    shopName: bankAccount.shop?.shopName ?? "Unknown Shop",
    accountName: bankAccount.accountName,
    bankName: bankAccount.bankName,
    branchName: bankAccount.branchName,
    accountNumber: bankAccount.accountNumber,
    accountNumberMasked: maskAccountNumber(bankAccount.accountNumber),
    accountType: bankAccount.accountType,
    accountTypeLabel: toDisplayLabel(bankAccount.accountType),
    openingBalance: Number(bankAccount.openingBalance ?? 0),
    currentBalance: Number(bankAccount.currentBalance ?? 0),
    currency: bankAccount.currency,
    status: bankAccount.status,
    statusLabel: toDisplayLabel(bankAccount.status),
    isDefault: Boolean(bankAccount.isDefault),
    notes: bankAccount.notes,
    createdAt: bankAccount.createdAt,
    updatedAt: bankAccount.updatedAt,
  };
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
    const shopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
    const bankName = typeof request.query.bankName === "string" ? request.query.bankName.trim() : "";
    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

    const bankAccounts = await (prisma as any).bankAccount.findMany({
      where: {
        ...(shopId ? { shopId } : {}),
        ...(bankName ? { bankName } : {}),
        ...(status ? { status } : {}),
        ...(search
          ? {
              OR: [
                { accountName: { contains: search, mode: "insensitive" } },
                { bankName: { contains: search, mode: "insensitive" } },
                { branchName: { contains: search, mode: "insensitive" } },
                { accountNumber: { contains: search, mode: "insensitive" } },
                { shop: { shopName: { contains: search, mode: "insensitive" } } },
              ],
            }
          : {}),
      },
      include: {
        shop: {
          select: {
            id: true,
            shopName: true,
          },
        },
      },
      orderBy: [{ isDefault: "desc" }, { updatedAt: "desc" }, { accountName: "asc" }],
    });

    const banks = Array.from(
      new Set(
        bankAccounts
          .map((bankAccount: any) => bankAccount.bankName?.trim())
          .filter((value: string | undefined): value is string => Boolean(value)),
      ),
    ) as string[];

    banks.sort((left, right) => left.localeCompare(right));

    const totalBalance = bankAccounts.reduce(
      (sum: number, item: { currentBalance: unknown }) => sum + Number(item.currentBalance ?? 0),
      0,
    );

    return response.json({
      stats: {
        total: bankAccounts.length,
        active: bankAccounts.filter((item: { status: BankAccountStatusValue }) => item.status === "ACTIVE").length,
        inactive: bankAccounts.filter((item: { status: BankAccountStatusValue }) => item.status === "INACTIVE").length,
        totalBalance,
      },
      banks,
      bankAccounts: bankAccounts.map(mapBankAccount),
    });
  } catch (error) {
    console.error("Failed to load bank accounts.", error);

    return response.status(503).json({
      message:
        "Bank accounts are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
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
      shopId?: string;
      accountName?: string;
      bankName?: string;
      branchName?: string | null;
      accountNumber?: string;
      accountType?: BankAccountTypeValue;
      openingBalance?: number | string;
      currency?: string;
      status?: BankAccountStatusValue;
      isDefault?: boolean;
      notes?: string | null;
    };

    const shopId = body.shopId?.trim();
    const accountName = body.accountName?.trim();
    const bankName = body.bankName?.trim();
    const branchName = body.branchName?.trim() || null;
    const accountNumber = body.accountNumber?.trim();
    const accountType = body.accountType;
    const openingBalance = Number(body.openingBalance ?? 0);
    const currency = body.currency?.trim().toUpperCase() || "BDT";
    const status = body.status ?? "ACTIVE";
    const isDefault = Boolean(body.isDefault);
    const notes = body.notes?.trim() || null;

    if (!shopId || !accountName || !bankName || !accountNumber || !accountType) {
      return response.status(400).json({
        message: "Shop, account name, bank name, account number, and account type are required.",
      });
    }

    if (Number.isNaN(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const [shop, existingAccount] = await Promise.all([
      prisma.shop.findUnique({
        where: { id: shopId },
        select: { id: true, shopName: true },
      }),
      (prisma as any).bankAccount.findFirst({
        where: {
          bankName,
          accountNumber,
        },
        select: { id: true },
      }),
    ]);

    if (!shop) {
      return response.status(404).json({ message: "Selected shop was not found." });
    }

    if (existingAccount) {
      return response.status(409).json({ message: "A bank account with this bank and account number already exists." });
    }

    const createdBankAccount = await prisma.$transaction(async (transaction) => {
      if (isDefault) {
        await (transaction as any).bankAccount.updateMany({
          where: { shopId },
          data: { isDefault: false },
        });
      }

      return (transaction as any).bankAccount.create({
        data: {
          shopId,
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
        include: {
          shop: {
            select: {
              id: true,
              shopName: true,
            },
          },
        },
      });
    });

    return response.status(201).json({
      message: "Bank account created successfully.",
      bankAccount: mapBankAccount(createdBankAccount),
    });
  } catch (error) {
    console.error("Failed to create bank account.", error);

    return response.status(503).json({
      message:
        "Bank account could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.put("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const existingBankAccount = await (prisma as any).bankAccount.findUnique({
      where: { id: request.params.id },
      select: {
        id: true,
        shopId: true,
        openingBalance: true,
        currentBalance: true,
      },
    });

    if (!existingBankAccount) {
      return response.status(404).json({ message: "Bank account not found." });
    }

    const body = request.body as {
      shopId?: string;
      accountName?: string;
      bankName?: string;
      branchName?: string | null;
      accountNumber?: string;
      accountType?: BankAccountTypeValue;
      openingBalance?: number | string;
      currency?: string;
      status?: BankAccountStatusValue;
      isDefault?: boolean;
      notes?: string | null;
    };

    const shopId = body.shopId?.trim();
    const accountName = body.accountName?.trim();
    const bankName = body.bankName?.trim();
    const branchName = body.branchName?.trim() || null;
    const accountNumber = body.accountNumber?.trim();
    const accountType = body.accountType;
    const openingBalance = Number(body.openingBalance ?? 0);
    const currency = body.currency?.trim().toUpperCase() || "BDT";
    const status = body.status ?? "ACTIVE";
    const isDefault = Boolean(body.isDefault);
    const notes = body.notes?.trim() || null;

    if (!shopId || !accountName || !bankName || !accountNumber || !accountType) {
      return response.status(400).json({
        message: "Shop, account name, bank name, account number, and account type are required.",
      });
    }

    if (Number.isNaN(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const [shop, duplicateAccount] = await Promise.all([
      prisma.shop.findUnique({
        where: { id: shopId },
        select: { id: true, shopName: true },
      }),
      (prisma as any).bankAccount.findFirst({
        where: {
          bankName,
          accountNumber,
          id: { not: request.params.id },
        },
        select: { id: true },
      }),
    ]);

    if (!shop) {
      return response.status(404).json({ message: "Selected shop was not found." });
    }

    if (duplicateAccount) {
      return response.status(409).json({ message: "A bank account with this bank and account number already exists." });
    }

    const updatedBankAccount = await prisma.$transaction(async (transaction) => {
      if (isDefault) {
        await (transaction as any).bankAccount.updateMany({
          where: { shopId },
          data: { isDefault: false },
        });
      }

      const openingDelta = openingBalance - Number(existingBankAccount.openingBalance ?? 0);

      return (transaction as any).bankAccount.update({
        where: { id: request.params.id },
        data: {
          shopId,
          accountName,
          bankName,
          branchName,
          accountNumber,
          accountType,
          openingBalance,
          currentBalance: Number(existingBankAccount.currentBalance ?? 0) + openingDelta,
          currency,
          status,
          isDefault,
          notes,
        },
        include: {
          shop: {
            select: {
              id: true,
              shopName: true,
            },
          },
        },
      });
    });

    return response.json({
      message: "Bank account updated successfully.",
      bankAccount: mapBankAccount(updatedBankAccount),
    });
  } catch (error) {
    console.error("Failed to update bank account.", error);

    return response.status(503).json({
      message:
        "Bank account could not be updated because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

export default router;
