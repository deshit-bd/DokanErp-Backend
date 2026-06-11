import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";
import { canAddProductsToShop, countDistinctShopProducts, FREE_TIER_PRODUCT_LIMIT } from "../subscription/access";

const router = Router();

function toMoney(value: unknown) {
  return Number(value ?? 0);
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
        shopName: true,
        status: true,
      },
      orderBy: [{ shopName: "asc" }],
    });

    return response.json({
      shops: shops.map((shop) => ({
        id: shop.id,
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
        where: { shopId: context.shop.id },
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

export default router;
