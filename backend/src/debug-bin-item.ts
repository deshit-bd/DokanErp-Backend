import { prisma } from "./config/prisma";

async function main() {
  const item = await (prisma as any).inventoryBinItem.findUnique({
    where: { id: "cmqq8jhnt003ilx0az679pk68" },
    include: {
      purchaseItem: {
        include: {
          purchase: true
        }
      }
    }
  });
  console.log("InventoryBinItem Details:", item);
}

main().catch(console.error).finally(() => prisma.$disconnect());
