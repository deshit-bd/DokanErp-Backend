import { Router } from "express";
import { UserStatus } from "@prisma/client";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

function mapStaffMember(member: {
  id: string;
  createdAt: Date;
  user: {
    id: string;
    name: string;
    phone: string | null;
    email: string | null;
    status: UserStatus;
    createdAt: Date;
    lastLoginAt: Date | null;
  };
  salesmanPermission: {
    canSell: boolean;
    canViewStock: boolean;
    canViewReports: boolean;
    canChangePrice: boolean;
    canCollectDue: boolean;
  } | null;
}) {
  return {
    id: member.user.id,
    shopUserId: member.id,
    name: member.user.name,
    mobile: member.user.phone,
    email: member.user.email,
    status: member.user.status,
    isActive: member.user.status === UserStatus.ACTIVE,
    joinedAt: member.createdAt,
    createdAt: member.user.createdAt,
    lastLoginAt: member.user.lastLoginAt,
    permissions: {
      canSell: member.salesmanPermission?.canSell ?? false,
      canViewStock: member.salesmanPermission?.canViewStock ?? false,
      canViewReports: member.salesmanPermission?.canViewReports ?? false,
      canChangePrice: member.salesmanPermission?.canChangePrice ?? false,
      canCollectDue: member.salesmanPermission?.canCollectDue ?? false,
    },
  };
}

function buildStaffSummary(staff: Array<ReturnType<typeof mapStaffMember>>) {
  return {
    total: staff.length,
    active: staff.filter((item) => item.isActive).length,
    inactive: staff.filter((item) => !item.isActive).length,
    canSell: staff.filter((item) => item.permissions.canSell).length,
    canCollectDue: staff.filter((item) => item.permissions.canCollectDue).length,
  };
}

function getDayRange(source = new Date()) {
  const start = new Date(source);
  start.setHours(0, 0, 0, 0);
  const end = new Date(start);
  end.setDate(end.getDate() + 1);
  return { start, end };
}

function getMonthRange(source = new Date()) {
  const start = new Date(source.getFullYear(), source.getMonth(), 1);
  const end = new Date(source.getFullYear(), source.getMonth() + 1, 1);
  return { start, end };
}

function getWeekRange(source = new Date()) {
  const end = new Date(source);
  const start = new Date(source);
  start.setHours(0, 0, 0, 0);
  start.setDate(start.getDate() - 6);
  const nextDay = new Date(source);
  nextDay.setHours(0, 0, 0, 0);
  nextDay.setDate(nextDay.getDate() + 1);
  return { start, end: nextDay };
}

type SalesReportSale = {
  id: string;
  invoiceNo: string | null;
  saleDate: Date;
  totalAmount: unknown;
  discountAmount: unknown;
  taxAmount: unknown;
  chargeAmount: unknown;
  customerId: string;
  customer: {
    name: string;
  } | null;
  items: Array<{
    masterProductId: string;
    quantity: unknown;
    totalAmount: unknown;
    masterProduct: {
      name: string;
    } | null;
  }>;
};

function toNumber(value: unknown) {
  return Number(value ?? 0);
}

function getNetSaleAmount(sale: Pick<SalesReportSale, "totalAmount" | "discountAmount" | "taxAmount" | "chargeAmount">) {
  return Number(
    (
      toNumber(sale.totalAmount) -
      toNumber(sale.discountAmount) +
      toNumber(sale.taxAmount) +
      toNumber(sale.chargeAmount)
    ).toFixed(2),
  );
}

function summarizeSales(sales: SalesReportSale[]) {
  const customerCount = new Set(sales.map((sale) => sale.customerId).filter(Boolean)).size;
  const totalQty = Number(
    sales
      .reduce(
        (sum, sale) =>
          sum +
          sale.items.reduce((itemSum, item) => itemSum + toNumber(item.quantity), 0),
        0,
      )
      .toFixed(3),
  );
  const orderedSales = sales
    .slice()
    .sort((a, b) => a.saleDate.getTime() - b.saleDate.getTime());
  const firstSaleAt = orderedSales[0]?.saleDate ?? null;
  const lastSaleAt = orderedSales[orderedSales.length - 1]?.saleDate ?? null;

  return {
    totalSalesAmount: Number(sales.reduce((sum, sale) => sum + getNetSaleAmount(sale), 0).toFixed(2)),
    salesCount: sales.length,
    totalQty,
    customerCount,
    firstSaleAt,
    lastSaleAt,
  };
}

function buildRecentSales(sales: SalesReportSale[], limit = 3) {
  return sales
    .slice()
    .sort((a, b) => b.saleDate.getTime() - a.saleDate.getTime())
    .slice(0, limit)
    .map((sale) => ({
      id: sale.id,
      invoiceNo: sale.invoiceNo,
      customerName: sale.customer?.name ?? null,
      amount: getNetSaleAmount(sale),
      soldAt: sale.saleDate,
    }));
}

function buildTopProducts(sales: SalesReportSale[], limit = 3) {
  const productMap = new Map<string, { productId: string; name: string; quantity: number; value: number }>();

  sales.forEach((sale) => {
    sale.items.forEach((item) => {
      const current = productMap.get(item.masterProductId) ?? {
        productId: item.masterProductId,
        name: item.masterProduct?.name ?? "Unknown",
        quantity: 0,
        value: 0,
      };

      current.quantity += toNumber(item.quantity);
      current.value += toNumber(item.totalAmount);
      productMap.set(item.masterProductId, current);
    });
  });

  return Array.from(productMap.values())
    .sort((a, b) => (b.quantity === a.quantity ? b.value - a.value : b.quantity - a.quantity))
    .slice(0, limit)
    .map((item, index) => ({
      rank: index + 1,
      productId: item.productId,
      name: item.name,
      quantity: Number(item.quantity.toFixed(3)),
      value: Number(item.value.toFixed(2)),
    }));
}

function buildTodayTrend(sales: SalesReportSale[]) {
  const buckets = [
    { key: "morning", label: "সকাল", startHour: 6, endHour: 12, value: 0 },
    { key: "noon", label: "দুপুর", startHour: 12, endHour: 16, value: 0 },
    { key: "evening", label: "বিকাল", startHour: 16, endHour: 20, value: 0 },
    { key: "night", label: "রাত", startHour: 20, endHour: 24, value: 0 },
  ];

  sales.forEach((sale) => {
    const saleHour = sale.saleDate.getHours();
    const bucket = buckets.find((item) => saleHour >= item.startHour && saleHour < item.endHour) ?? buckets[0];
    bucket.value += getNetSaleAmount(sale);
  });

  return buckets.map((bucket) => ({
    key: bucket.key,
    label: bucket.label,
    value: Number(bucket.value.toFixed(2)),
  }));
}

function buildWeekTrend(sales: SalesReportSale[], rangeStart: Date) {
  return Array.from({ length: 7 }, (_, index) => {
    const bucketDate = new Date(rangeStart);
    bucketDate.setDate(rangeStart.getDate() + index);
    const bucketDay = bucketDate.toDateString();
    const value = sales
      .filter((sale) => sale.saleDate.toDateString() === bucketDay)
      .reduce((sum, sale) => sum + getNetSaleAmount(sale), 0);

    return {
      key: bucketDate.toISOString(),
      label: bucketDate.toLocaleDateString("bn-BD", { weekday: "short" }),
      value: Number(value.toFixed(2)),
    };
  });
}

function buildMonthTrend(sales: SalesReportSale[], source = new Date()) {
  const daysInMonth = new Date(source.getFullYear(), source.getMonth() + 1, 0).getDate();
  return Array.from({ length: 4 }, (_, index) => {
    const startDay = index * 7 + 1;
    const endDay = index === 3 ? daysInMonth : Math.min(daysInMonth, startDay + 6);
    const value = sales
      .filter((sale) => {
        const saleDay = sale.saleDate.getDate();
        return saleDay >= startDay && saleDay <= endDay;
      })
      .reduce((sum, sale) => sum + getNetSaleAmount(sale), 0);

    return {
      key: `month-week-${index + 1}`,
      label: `${startDay}-${endDay}`,
      value: Number(value.toFixed(2)),
    };
  });
}

function buildSalesmanReportPayload(todaySales: SalesReportSale[], weekSales: SalesReportSale[], monthSales: SalesReportSale[], source = new Date()) {
  const weekRange = getWeekRange(source);

  return {
    today: {
      summary: summarizeSales(todaySales),
      trend: buildTodayTrend(todaySales),
      recentSales: buildRecentSales(todaySales),
      topProducts: buildTopProducts(todaySales),
    },
    week: {
      summary: summarizeSales(weekSales),
      trend: buildWeekTrend(weekSales, weekRange.start),
      recentSales: buildRecentSales(weekSales),
      topProducts: buildTopProducts(weekSales),
    },
    month: {
      summary: summarizeSales(monthSales),
      trend: buildMonthTrend(monthSales, source),
      recentSales: buildRecentSales(monthSales),
      topProducts: buildTopProducts(monthSales),
    },
  };
}

router.get("/me/performance", async (request, response) => {
  try {
    const auth = await getAuthenticatedUser(request);
    if (isAuthError(auth)) {
      return sendAuthError(response, auth);
    }
    const shopId = auth.payload.shopId;
    const userId = auth.user.id;
    if (!shopId) {
      return response.status(451).json({ message: "Shop ID not associated with user." });
    }

    const member = await prisma.shopUser.findFirst({
      where: {
        shopId,
        userId,
      },
      select: {
        id: true,
        createdAt: true,
        isBillable: true,
        role: true,
        user: {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            status: true,
            createdAt: true,
            lastLoginAt: true,
          },
        },
        salesmanPermission: {
          select: {
            canSell: true,
            canViewStock: true,
            canViewReports: true,
            canChangePrice: true,
            canCollectDue: true,
          },
        },
      },
    });

    if (!member) {
      return response.status(404).json({ message: "Staff user not found in this shop." });
    }

    const now = new Date();
    const today = getDayRange(now);
    const week = getWeekRange(now);
    const month = getMonthRange(now);

    const salesClient = prisma.customerSale;

    const saleSelect = {
      id: true,
      invoiceNo: true,
      saleDate: true,
      totalAmount: true,
      discountAmount: true,
      taxAmount: true,
      chargeAmount: true,
      customerId: true,
      customer: {
        select: {
          name: true,
        },
      },
      items: {
        select: {
          masterProductId: true,
          quantity: true,
          totalAmount: true,
          masterProduct: {
            select: {
              name: true,
            },
          },
        },
      },
    } as const;

    const [todaySales, weekSales, monthSales, allSalesCount] = await Promise.all([
      salesClient.findMany({
        where: {
          shopId,
          createdByUserId: userId,
          saleDate: { gte: today.start, lt: today.end },
          status: "ACTIVE",
        },
        select: saleSelect,
      }),
      salesClient.findMany({
        where: {
          shopId,
          createdByUserId: userId,
          saleDate: { gte: week.start, lt: week.end },
          status: "ACTIVE",
        },
        select: saleSelect,
      }),
      salesClient.findMany({
        where: {
          shopId,
          createdByUserId: userId,
          saleDate: { gte: month.start, lt: month.end },
          status: "ACTIVE",
        },
        select: saleSelect,
      }),
      salesClient.count({
        where: {
          shopId,
          createdByUserId: userId,
          status: "ACTIVE",
        },
      }),
    ]);

    const staff = mapStaffMember(member);
    const report = buildSalesmanReportPayload(todaySales as SalesReportSale[], weekSales as SalesReportSale[], monthSales as SalesReportSale[], now);
    const todayActivities = report.today.recentSales;
    const todaySummary = report.today.summary;
    const monthSummary = report.month.summary;

    return response.json({
      staff: {
        ...staff,
        isBillable: member.isBillable,
        todaySalesCount: todaySummary.salesCount,
        monthSalesCount: monthSummary.salesCount,
      },
      summary: {
        todaySalesAmount: todaySummary.totalSalesAmount,
        monthSalesAmount: monthSummary.totalSalesAmount,
        totalSalesCount: allSalesCount,
      },
      todayActivities,
      report,
    });
  } catch (error: any) {
    console.error("Failed to load salesman performance.", error);
    return response.status(500).json({ message: error.message || "Internal server error" });
  }
});

async function requireOwnerShopContext(request: Parameters<typeof getAuthenticatedUser>[0]) {
  const auth = await getAuthenticatedUser(request);

  if (isAuthError(auth)) {
    return auth;
  }

  if (auth.payload.appType !== "MOBILE" || auth.payload.role !== "SHOP_OWNER" || !auth.payload.shopId) {
    return {
      status: 403,
      body: { message: "Only shop owners can manage staff accounts." },
    };
  }

  const shop = await prisma.shop.findUnique({
    where: { id: auth.payload.shopId },
    select: {
      id: true,
      shopCode: true,
      shopName: true,
      status: true,
      ownerUserId: true,
    },
  });

  if (!shop) {
    return {
      status: 404,
      body: { message: "Shop not found." },
    };
  }

  if (shop.ownerUserId !== auth.user.id) {
    return {
      status: 403,
      body: { message: "You can only manage staff for your own shop." },
    };
  }

  return { auth, shop };
}

router.get("/", async (request, response) => {
  const context = await requireOwnerShopContext(request);

  if ("status" in context) {
    return sendAuthError(response, context);
  }

  const members = await prisma.shopUser.findMany({
    where: {
      shopId: context.shop.id,
      role: "SALESMAN",
    },
    select: {
      id: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          createdAt: true,
          lastLoginAt: true,
        },
      },
      salesmanPermission: {
        select: {
          canSell: true,
          canViewStock: true,
          canViewReports: true,
          canChangePrice: true,
          canCollectDue: true,
        },
      },
    },
    orderBy: [{ user: { status: "asc" } }, { createdAt: "desc" }],
  });

  const staff = members.map(mapStaffMember);

  return response.json({
    shop: {
      id: context.shop.id,
      shopCode: context.shop.shopCode,
      shopName: context.shop.shopName,
    },
    summary: buildStaffSummary(staff),
    staff,
  });
});

router.get("/:staffUserId", async (request, response) => {
  const context = await requireOwnerShopContext(request);

  if ("status" in context) {
    return sendAuthError(response, context);
  }

  const staffUserId = `${request.params.staffUserId ?? ""}`.trim();

  if (!staffUserId) {
    return response.status(400).json({ message: "Staff user id is required." });
  }

  const member = await prisma.shopUser.findFirst({
    where: {
      shopId: context.shop.id,
      userId: staffUserId,
      role: "SALESMAN",
    },
    select: {
      id: true,
      createdAt: true,
      isBillable: true,
      user: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          createdAt: true,
          lastLoginAt: true,
        },
      },
      salesmanPermission: {
        select: {
          canSell: true,
          canViewStock: true,
          canViewReports: true,
          canChangePrice: true,
          canCollectDue: true,
        },
      },
    },
  });

  if (!member) {
    return response.status(404).json({ message: "Staff account not found in this shop." });
  }

  const now = new Date();
  const today = getDayRange(now);
  const month = getMonthRange(now);

  const salesClient = prisma.customerSale;

  const [todaySales, monthSales, allSalesCount, todayActivities] = await Promise.all([
    salesClient.findMany({
      where: {
        shopId: context.shop.id,
        createdByUserId: member.user.id,
        saleDate: { gte: today.start, lt: today.end },
        status: "ACTIVE",
      },
      select: {
        id: true,
        totalAmount: true,
      },
    }),
    salesClient.findMany({
      where: {
        shopId: context.shop.id,
        createdByUserId: member.user.id,
        saleDate: { gte: month.start, lt: month.end },
        status: "ACTIVE",
      },
      select: {
        id: true,
        totalAmount: true,
      },
    }),
    salesClient.count({
      where: {
        shopId: context.shop.id,
        createdByUserId: member.user.id,
        status: "ACTIVE",
      },
    }),
    salesClient.findMany({
      where: {
        shopId: context.shop.id,
        createdByUserId: member.user.id,
        saleDate: { gte: today.start, lt: today.end },
        status: "ACTIVE",
      },
      select: {
        id: true,
        invoiceNo: true,
        saleDate: true,
        totalAmount: true,
        customer: {
          select: {
            name: true,
          },
        },
      },
      orderBy: [{ saleDate: "desc" }, { createdAt: "desc" }],
      take: 10,
    }),
  ]);

  const staff = mapStaffMember(member);

  return response.json({
    staff: {
      ...staff,
      isBillable: member.isBillable,
      todaySalesCount: todaySales.length,
      monthSalesCount: monthSales.length,
    },
    summary: {
      todaySalesAmount: Number(todaySales.reduce((sum: number, sale: any) => sum + Number(sale.totalAmount ?? 0), 0).toFixed(2)),
      monthSalesAmount: Number(monthSales.reduce((sum: number, sale: any) => sum + Number(sale.totalAmount ?? 0), 0).toFixed(2)),
      totalSalesCount: allSalesCount,
    },
    todayActivities: todayActivities.map((sale: any) => ({
      id: sale.id,
      invoiceNo: sale.invoiceNo,
      customerName: sale.customer?.name ?? null,
      amount: Number(sale.totalAmount ?? 0),
      soldAt: sale.saleDate,
    })),
  });
});

router.patch("/:staffUserId/permissions", async (request, response) => {
  const context = await requireOwnerShopContext(request);

  if ("status" in context) {
    return sendAuthError(response, context);
  }

  const staffUserId = `${request.params.staffUserId ?? ""}`.trim();

  if (!staffUserId) {
    return response.status(400).json({ message: "Staff user id is required." });
  }

  const permissions = request.body as {
    canSell?: boolean;
    canViewStock?: boolean;
    canViewReports?: boolean;
    canChangePrice?: boolean;
    canCollectDue?: boolean;
  };

  const member = await prisma.shopUser.findFirst({
    where: {
      shopId: context.shop.id,
      userId: staffUserId,
      role: "SALESMAN",
    },
    select: {
      id: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          createdAt: true,
          lastLoginAt: true,
        },
      },
    },
  });

  if (!member) {
    return response.status(404).json({ message: "Staff account not found in this shop." });
  }

  await prisma.salesmanPermission.upsert({
    where: { shopUserId: member.id },
    update: {
      canSell: !!permissions.canSell,
      canViewStock: !!permissions.canViewStock,
      canViewReports: !!permissions.canViewReports,
      canChangePrice: !!permissions.canChangePrice,
      canCollectDue: !!permissions.canCollectDue,
    },
    create: {
      shopUserId: member.id,
      canSell: !!permissions.canSell,
      canViewStock: !!permissions.canViewStock,
      canViewReports: !!permissions.canViewReports,
      canChangePrice: !!permissions.canChangePrice,
      canCollectDue: !!permissions.canCollectDue,
    },
  });

  const refreshedMember = await prisma.shopUser.findUnique({
    where: { id: member.id },
    select: {
      id: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          createdAt: true,
          lastLoginAt: true,
        },
      },
      salesmanPermission: {
        select: {
          canSell: true,
          canViewStock: true,
          canViewReports: true,
          canChangePrice: true,
          canCollectDue: true,
        },
      },
    },
  });

  return response.json({
    message: "Staff permissions updated successfully.",
    staff: refreshedMember ? mapStaffMember(refreshedMember) : null,
  });
});

router.post("/:staffUserId/pin-reset", async (request, response) => {
  const context = await requireOwnerShopContext(request);

  if ("status" in context) {
    return sendAuthError(response, context);
  }

  const staffUserId = `${request.params.staffUserId ?? ""}`.trim();

  if (!staffUserId) {
    return response.status(400).json({ message: "Staff user id is required." });
  }

  const member = await prisma.shopUser.findFirst({
    where: {
      shopId: context.shop.id,
      userId: staffUserId,
      role: "SALESMAN",
    },
    select: {
      userId: true,
    },
  });

  if (!member) {
    return response.status(404).json({ message: "Staff account not found in this shop." });
  }

  await prisma.userPin.upsert({
    where: { userId: member.userId },
    update: {
      status: "RESET_REQUIRED",
      failedAttempts: 0,
      lockedUntil: null,
      lastChangedAt: new Date(),
    },
    create: {
      userId: member.userId,
      pinHash: "",
      status: "RESET_REQUIRED",
    },
  });

  return response.json({
    message: "PIN reset has been requested. The salesman must set a new PIN on next PIN flow.",
  });
});

router.patch("/:staffUserId/status", async (request, response) => {
  const context = await requireOwnerShopContext(request);

  if ("status" in context) {
    return sendAuthError(response, context);
  }

  const staffUserId = `${request.params.staffUserId ?? ""}`.trim();
  const statusInput = `${(request.body as { status?: string }).status ?? ""}`.trim().toUpperCase();

  if (!staffUserId) {
    return response.status(400).json({ message: "Staff user id is required." });
  }

  if (statusInput !== UserStatus.ACTIVE && statusInput !== UserStatus.INACTIVE) {
    return response.status(400).json({ message: "Status must be ACTIVE or INACTIVE." });
  }

  const member = await prisma.shopUser.findFirst({
    where: {
      shopId: context.shop.id,
      userId: staffUserId,
      role: "SALESMAN",
    },
    select: {
      id: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          createdAt: true,
          lastLoginAt: true,
        },
      },
      salesmanPermission: {
        select: {
          canSell: true,
          canViewStock: true,
          canViewReports: true,
          canChangePrice: true,
          canCollectDue: true,
        },
      },
    },
  });

  if (!member) {
    return response.status(404).json({ message: "Staff account not found in this shop." });
  }

  const updatedUser = await prisma.user.update({
    where: { id: member.user.id },
    data: {
      status: statusInput as UserStatus,
    },
    select: {
      id: true,
      name: true,
      phone: true,
      email: true,
      status: true,
      createdAt: true,
      lastLoginAt: true,
    },
  });

  const updatedStaff = mapStaffMember({
    ...member,
    user: updatedUser,
  });

  const summaryRows = await prisma.shopUser.findMany({
    where: {
      shopId: context.shop.id,
      role: "SALESMAN",
    },
    select: {
      id: true,
      createdAt: true,
      user: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          createdAt: true,
          lastLoginAt: true,
        },
      },
      salesmanPermission: {
        select: {
          canSell: true,
          canViewStock: true,
          canViewReports: true,
          canChangePrice: true,
          canCollectDue: true,
        },
      },
    },
  });

  return response.json({
    message: `Staff account ${updatedStaff.isActive ? "activated" : "deactivated"} successfully.`,
    staff: updatedStaff,
    summary: buildStaffSummary(summaryRows.map(mapStaffMember)),
  });
});

export default router;
