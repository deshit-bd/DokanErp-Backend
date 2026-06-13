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
    const context = await requireOwnerShopContext(request);

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

export default router;
