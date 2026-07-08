import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();
async function main() {
  const shop = await prisma.shop.findUnique({
    where: { id: "cmrbi29xh0002w8ne4rbmj6ue" }
  });
  console.log("Current Shop Details:", shop);
}
main().finally(() => prisma.$disconnect());
