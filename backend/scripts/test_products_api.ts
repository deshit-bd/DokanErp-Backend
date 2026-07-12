import { PrismaClient } from "@prisma/client";
import { signAccessToken } from "../src/auth/jwt";
import { getAuthSecret } from "../src/auth/session";

const prisma = new PrismaClient();

async function main() {
  const shopProduct = await prisma.shopProduct.findFirst();
  if (!shopProduct) {
    console.error("No shop product found.");
    return;
  }

  const shopId = shopProduct.shopId;
  const shop = await prisma.shop.findUnique({ where: { id: shopId } });
  const user = await prisma.user.findFirst();
  
  if (!user || !shop) {
    console.error("No user or shop found in database.");
    return;
  }

  const shopUser = await prisma.shopUser.findFirst({
    where: { userId: user.id, shopId: shop.id }
  });

  const payload = {
    sub: user.id,
    shopId: shop.id,
    shopCode: shop.shopCode,
    role: (shopUser?.role ?? "SHOP_OWNER") as any,
    appType: "MOBILE" as const,
    sessionFamily: "test-session"
  };

  const token = signAccessToken(payload, getAuthSecret(), 86400);
  console.log("Mock Token:", token);
  console.log("Mock Payload:", payload);

  const res1 = await fetch("http://localhost:4000/app/api/products", {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  console.log("/app/api/products status:", res1.status);
  const data1 = await res1.json();
  console.log("/app/api/products size:", data1.products?.length || data1.data?.length);

  const res2 = await fetch("http://localhost:4000/app/api/shops/products", {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  console.log("/app/api/shops/products status:", res2.status);
  const data2 = await res2.json();
  console.log("/app/api/shops/products size:", data2.products?.length || data2.data?.length);

  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
