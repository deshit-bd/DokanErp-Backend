import { prisma } from "./config/prisma";

async function main() {
  const shopProductId = "cmqq73og9000wlx0avpgzj14r";
  console.log("Querying stock movements for shopProductId:", shopProductId);

  const movements = await (prisma as any).stockMovement.findMany({
    where: { shopProductId },
    orderBy: { createdAt: "desc" },
  });

  console.log("Movements count:", movements.length);
  for (const m of movements) {
    console.log({
      id: m.id,
      movementType: m.movementType,
      quantityDelta: Number(m.quantityDelta),
      stockBefore: m.stockBefore ? Number(m.stockBefore) : null,
      stockAfter: m.stockAfter ? Number(m.stockAfter) : null,
      note: m.note,
      createdAt: m.createdAt,
    });
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
