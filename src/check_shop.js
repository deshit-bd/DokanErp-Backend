const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const shops = await prisma.shop.findMany();
  console.log("=== SHOPS ===");
  console.log(shops);
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
