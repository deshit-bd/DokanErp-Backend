const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const jwt = require('jsonwebtoken');

// Get JWT secret from environment/code
const JWT_SECRET = process.env.AUTH_JWT_SECRET || "dev-only-auth-secret";

async function main() {
  // Let's find the user and shop
  const user = await prisma.user.findFirst();
  const shop = await prisma.shop.findFirst();
  
  if (!user || !shop) {
    console.error("No user or shop found in database.");
    return;
  }

  // Find userShop to get user's role in the shop
  const userShop = await prisma.userShop.findFirst({
    where: { userId: user.id, shopId: shop.id }
  });

  const payload = {
    sub: user.id,
    shopId: shop.id,
    shopCode: shop.shopCode,
    role: userShop ? userShop.role : "SHOP_OWNER",
    appType: "MOBILE"
  };

  const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '1d' });
  console.log("Mock Token:", token);
  console.log("Mock Payload:", payload);

  // We can query using fetch locally
  const response = await fetch(`http://localhost:4000/app/api/products`, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  console.log("Response Status:", response.status);
  const data = await response.json();
  console.log("Response Data:", JSON.stringify(data, null, 2));

  await prisma.$disconnect();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
