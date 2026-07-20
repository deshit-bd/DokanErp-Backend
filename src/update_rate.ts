import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
  const result = await prisma.subscription.updateMany({
    data: {
      dailyRatePerAccount: 10,
    }
  });
  console.log('Successfully updated subscriptions rate in database. Rows affected:', result.count);
}
main().catch(console.error).finally(() => prisma.$disconnect());
