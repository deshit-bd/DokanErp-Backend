const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

async function main() {
  const purchase = await prisma.purchase.findUnique({
    where: { id: "cmr2ydudi003nw8zbiqw0bnz2" }
  });
  console.log("Purchase ShopID:", purchase.shopId);
  console.log("Purchase Status:", purchase.status);
  console.log("Purchase Date:", purchase.purchaseDate.toISOString());
  console.log("Purchase CreatedAt:", purchase.createdAt.toISOString());
}

main()
  .catch((e) => console.error(e))
  .finally(() => prisma.$disconnect());
