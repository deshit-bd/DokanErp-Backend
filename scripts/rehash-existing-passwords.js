const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();
const SALT_ROUNDS = 10;

function isBcryptHash(value) {
  return typeof value === 'string' && /^\$2[aby]\$\d{2}\$/.test(value);
}

async function main() {
  const users = await prisma.user.findMany({ select: { id: true, name: true, passwordHash: true } });
  let rehashed = 0, alreadyHashed = 0;

  for (const user of users) {
    if (isBcryptHash(user.passwordHash)) {
      alreadyHashed++;
      continue;
    }
    const newHash = await bcrypt.hash(user.passwordHash, SALT_ROUNDS);
    await prisma.user.update({ where: { id: user.id }, data: { passwordHash: newHash } });
    console.log(`Rehashed password for user ${user.id} (${user.name})`);
    rehashed++;
  }

  console.log('--- DONE ---');
  console.log({ totalUsers: users.length, rehashed, alreadyHashed });
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
