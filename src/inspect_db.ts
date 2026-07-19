import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function run() {
  const hash = await bcrypt.hash("1234", 10);
  console.log("Bcrypt hash for '1234' is:", hash);

  console.log("Updating all users' password hash to the bcrypt hash of '1234'...");
  const updateResult = await prisma.user.updateMany({
    data: {
      passwordHash: hash
    }
  });

  console.log(`Successfully updated ${updateResult.count} users in the database!`);
  await prisma.$disconnect();
}

run();
