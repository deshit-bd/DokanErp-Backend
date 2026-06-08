import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

type MoneyBoxStatusValue = "ACTIVE" | "INACTIVE";
type MoneyBoxTypeValue = "CASH" | "BKASH" | "NAGAD";

function toDisplayLabel(value: string) {
  return value.replace(/_/g, " ");
}

async function requirePlatformUser(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (!["SUPER_ADMIN", "ADMIN"].includes(auth.payload.role)) {
    return {
      status: 403,
      body: { message: "You do not have permission to manage money boxes." },
    };
  }

  return auth;
}

router.get("/", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const search = typeof request.query.search === "string" ? request.query.search.trim() : "";
    const shopId = typeof request.query.shopId === "string" ? request.query.shopId.trim() : "";
    const status = typeof request.query.status === "string" ? request.query.status.trim().toUpperCase() : "";

    const moneyBoxes = await (prisma as any).moneyBox.findMany({
      where: {
        ...(shopId ? { shopId } : {}),
        ...(status ? { status } : {}),
        ...(search
          ? {
              OR: [
                { boxName: { contains: search, mode: "insensitive" } },
                { code: { contains: search, mode: "insensitive" } },
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
      orderBy: [{ createdAt: "desc" }, { boxName: "asc" }],
    });

    const totalBalance = moneyBoxes.reduce(
      (sum: number, item: { currentBalance: unknown }) => sum + Number(item.currentBalance ?? 0),
      0,
    );

    return response.json({
      stats: {
        total: moneyBoxes.length,
        active: moneyBoxes.filter((item: { status: MoneyBoxStatusValue }) => item.status === "ACTIVE").length,
        inactive: moneyBoxes.filter((item: { status: MoneyBoxStatusValue }) => item.status === "INACTIVE").length,
        totalBalance,
      },
      moneyBoxes: moneyBoxes.map((moneyBox: any) => ({
        id: moneyBox.id,
        shopId: moneyBox.shopId,
        shopName: moneyBox.shop?.shopName ?? "Unknown Shop",
        boxName: moneyBox.boxName,
        code: moneyBox.code,
        type: moneyBox.type,
        typeLabel: toDisplayLabel(moneyBox.type),
        openingBalance: Number(moneyBox.openingBalance ?? 0),
        currentBalance: Number(moneyBox.currentBalance ?? 0),
        details: moneyBox.details,
        status: moneyBox.status,
        statusLabel: toDisplayLabel(moneyBox.status),
        createdAt: moneyBox.createdAt,
        updatedAt: moneyBox.updatedAt,
      })),
    });
  } catch (error) {
    console.error("Failed to load money boxes.", error);

    return response.status(503).json({
      message:
        "Money boxes are not available yet because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
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
      boxName?: string;
      code?: string;
      type?: MoneyBoxTypeValue;
      openingBalance?: number | string;
      details?: string | null;
      status?: MoneyBoxStatusValue;
    };

    const shopId = body.shopId?.trim();
    const boxName = body.boxName?.trim();
    const code = body.code?.trim();
    const type = body.type;
    const details = body.details?.trim() || null;
    const status = body.status ?? "ACTIVE";
    const openingBalance = Number(body.openingBalance ?? 0);

    if (!shopId) {
      return response.status(400).json({ message: "Shop is required." });
    }
    if (!boxName) {
      return response.status(400).json({ message: "Money box name is required." });
    }
    if (!code) {
      return response.status(400).json({ message: "Money box code is required." });
    }
    if (!type) {
      return response.status(400).json({ message: "Money box type is required." });
    }
    if (Number.isNaN(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const [shop, existingCode] = await Promise.all([
      prisma.shop.findUnique({
        where: { id: shopId },
        select: { id: true, shopName: true },
      }),
      (prisma as any).moneyBox.findUnique({
        where: { code },
        select: { id: true },
      }),
    ]);

    if (!shop) {
      return response.status(404).json({ message: "Selected shop was not found." });
    }

    if (existingCode) {
      return response.status(409).json({ message: "Money box code already exists." });
    }

    const moneyBox = await (prisma as any).moneyBox.create({
      data: {
        shopId,
        boxName,
        code,
        type,
        openingBalance,
        currentBalance: openingBalance,
        details,
        status,
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

    return response.status(201).json({
      message: "Money box created successfully.",
      moneyBox: {
        id: moneyBox.id,
        shopId: moneyBox.shopId,
        shopName: moneyBox.shop.shopName,
        boxName: moneyBox.boxName,
        code: moneyBox.code,
        type: moneyBox.type,
        typeLabel: toDisplayLabel(moneyBox.type),
        openingBalance: Number(moneyBox.openingBalance ?? 0),
        currentBalance: Number(moneyBox.currentBalance ?? 0),
        details: moneyBox.details,
        status: moneyBox.status,
        statusLabel: toDisplayLabel(moneyBox.status),
        createdAt: moneyBox.createdAt,
        updatedAt: moneyBox.updatedAt,
      },
    });
  } catch (error) {
    console.error("Failed to create money box.", error);

    return response.status(503).json({
      message:
        "Money box could not be created because the database schema is not applied or the database is offline. Start PostgreSQL, then run backend prisma push and seed.",
    });
  }
});

router.put("/:id", async (request, response) => {
  try {
    const auth = await requirePlatformUser(request);

    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }

    const existingMoneyBox = await (prisma as any).moneyBox.findUnique({
      where: { id: request.params.id },
      select: { id: true },
    });

    if (!existingMoneyBox) {
      return response.status(404).json({ message: "Money box not found." });
    }

    const body = request.body as {
      shopId?: string;
      boxName?: string;
      code?: string;
      type?: MoneyBoxTypeValue;
      openingBalance?: number | string;
      details?: string | null;
      status?: MoneyBoxStatusValue;
    };

    const shopId = body.shopId?.trim();
    const boxName = body.boxName?.trim();
    const code = body.code?.trim();
    const type = body.type;
    const details = body.details?.trim() || null;
    const status = body.status ?? "ACTIVE";
    const openingBalance = Number(body.openingBalance ?? 0);

    if (!shopId || !boxName || !code || !type) {
      return response.status(400).json({ message: "Shop, name, code, and type are required." });
    }

    if (Number.isNaN(openingBalance)) {
      return response.status(400).json({ message: "Opening balance must be a valid number." });
    }

    const [shop, duplicateCode] = await Promise.all([
      prisma.shop.findUnique({
        where: { id: shopId },
        select: { id: true },
      }),
      (prisma as any).moneyBox.findFirst({
        where: {
          code,
          id: { not: request.params.id },
        },
        select: { id: true },
      }),
    ]);

    if (!shop) {
      return response.status(404).json({ message: "Selected shop was not found." });
    }

    if (duplicateCode) {
      return response.status(409).json({ message: "Money box code already exists." });
    }

    const updatedMoneyBox = await (prisma as any).moneyBox.update({
      where: { id: request.params.id },
      data: {
        shopId,
        boxName,
        code,
        type,
        openingBalance,
        details,
        status,
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

    return response.json({
      message: "Money box updated successfully.",
      moneyBox: {
        id: updatedMoneyBox.id,
        shopId: updatedMoneyBox.shopId,
        shopName: updatedMoneyBox.shop.shopName,
        boxName: updatedMoneyBox.boxName,
        code: updatedMoneyBox.code,
        type: updatedMoneyBox.type,
        typeLabel: toDisplayLabel(updatedMoneyBox.type),
        openingBalance: Number(updatedMoneyBox.openingBalance ?? 0),
        currentBalance: Number(updatedMoneyBox.currentBalance ?? 0),
        details: updatedMoneyBox.details,
        status: updatedMoneyBox.status,
        statusLabel: toDisplayLabel(updatedMoneyBox.status),
        createdAt: updatedMoneyBox.createdAt,
        updatedAt: updatedMoneyBox.updatedAt,
      },
    });
  } catch (error) {
    console.error("Failed to update money box.", error);

    return response.status(503).json({
      message: "Money box could not be updated right now.",
    });
  }
});

export default router;
