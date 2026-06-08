import { Router } from "express";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "../auth/current-user";
import { prisma } from "../config/prisma";

const router = Router();

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

export default router;
