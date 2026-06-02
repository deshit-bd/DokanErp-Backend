import {
  BillingStatus,
  PrismaClient,
  ShopStatus,
  ShopUserStatus,
  UserStatus,
  UserType,
} from "@prisma/client";

const prisma = new PrismaClient();

type SeedUserInput = {
  name: string;
  email: string;
  phone?: string;
  passwordHash: string;
  pinHash?: string;
  userType: UserType;
  status: UserStatus;
};

async function upsertUserByEmailOrPhone(data: SeedUserInput) {
  const existingByEmail = await prisma.user.findUnique({
    where: { email: data.email },
  });

  if (existingByEmail) {
    return prisma.user.update({
      where: { email: data.email },
      data,
    });
  }

  if (data.phone) {
    const existingByPhone = await prisma.user.findUnique({
      where: { phone: data.phone },
    });

    if (existingByPhone) {
      return prisma.user.update({
        where: { id: existingByPhone.id },
        data,
      });
    }
  }

  return prisma.user.create({ data });
}

async function main() {
  const permissionSeeds = [
    { key: "can_sell", name: "Can Sell" },
    { key: "can_purchase", name: "Can Purchase" },
    { key: "can_edit_inventory", name: "Can Edit Inventory" },
    { key: "can_view_reports", name: "Can View Reports" },
    { key: "can_manage_staff", name: "Can Manage Staff" },
    { key: "can_collect_due", name: "Can Collect Due" },
  ];

  for (const permissionSeed of permissionSeeds) {
    await prisma.permission.upsert({
      where: { key: permissionSeed.key },
      update: { name: permissionSeed.name },
      create: permissionSeed,
    });
  }

  const superAdmin = await upsertUserByEmailOrPhone({
    name: "Super Admin",
    email: "admin@deshit",
    phone: "+8801000000000",
    passwordHash: "12345678",
    userType: UserType.SUPER_ADMIN,
    status: UserStatus.ACTIVE,
  });

  const storeOwner = await upsertUserByEmailOrPhone({
    name: "Demo Store Owner",
    email: "owner@dokanerp.local",
    phone: "+8801000000001",
    passwordHash: "change-me-before-production",
    userType: UserType.SHOP_OWNER,
    status: UserStatus.ACTIVE,
  });

  const staffUser = await upsertUserByEmailOrPhone({
    name: "Demo Staff",
    email: "staff@dokanerp.local",
    phone: "+8801000000002",
    passwordHash: "change-me-before-production",
    pinHash: "1234",
    userType: UserType.STAFF,
    status: UserStatus.ACTIVE,
  });

  await upsertUserByEmailOrPhone({
    name: "Demo Supplier",
    email: "supplier@dokanerp.local",
    phone: "+8801000000003",
    passwordHash: "change-me-before-production",
    pinHash: "5678",
    userType: UserType.SUPPLIER,
    status: UserStatus.ACTIVE,
  });

  const shop = await prisma.shop.upsert({
    where: { id: "shop_dokan_demo" },
    update: {
      shopName: "Dokan Demo Store",
      status: ShopStatus.ACTIVE,
      ownerUserId: storeOwner.id,
      district: "Dhaka",
    },
    create: {
      id: "shop_dokan_demo",
      shopName: "Dokan Demo Store",
      shopType: "grocery",
      phone: "+8801999999999",
      address: "Mirpur, Dhaka, Bangladesh",
      district: "Dhaka",
      status: ShopStatus.ACTIVE,
      ownerUserId: storeOwner.id,
    },
  });

  let ownerRole = await prisma.role.findFirst({
    where: { shopId: shop.id, name: "owner" },
  });

  if (!ownerRole) {
    ownerRole = await prisma.role.create({
      data: {
        shopId: shop.id,
        name: "owner",
        isSystemRole: true,
      },
    });
  }

  let managerRole = await prisma.role.findFirst({
    where: { shopId: shop.id, name: "manager" },
  });

  if (!managerRole) {
    managerRole = await prisma.role.create({
      data: {
        shopId: shop.id,
        name: "manager",
        isSystemRole: true,
      },
    });
  }

  let cashierRole = await prisma.role.findFirst({
    where: { shopId: shop.id, name: "cashier" },
  });

  if (!cashierRole) {
    cashierRole = await prisma.role.create({
      data: {
        shopId: shop.id,
        name: "cashier",
        isSystemRole: true,
      },
    });
  }

  let salesmanRole = await prisma.role.findFirst({
    where: { shopId: shop.id, name: "salesman" },
  });

  if (!salesmanRole) {
    salesmanRole = await prisma.role.create({
      data: {
        shopId: shop.id,
        name: "salesman",
        isSystemRole: true,
      },
    });
  }

  const allPermissions = await prisma.permission.findMany();
  const ownerPermissionIds = allPermissions.map((permission) => permission.id);
  const salesmanPermissionIds = allPermissions
    .filter((permission) => ["can_sell", "can_collect_due", "can_view_reports"].includes(permission.key))
    .map((permission) => permission.id);

  for (const permissionId of ownerPermissionIds) {
    await prisma.rolePermission.upsert({
      where: {
        roleId_permissionId: {
          roleId: ownerRole.id,
          permissionId,
        },
      },
      update: {},
      create: {
        roleId: ownerRole.id,
        permissionId,
      },
    });
  }

  for (const permissionId of salesmanPermissionIds) {
    await prisma.rolePermission.upsert({
      where: {
        roleId_permissionId: {
          roleId: salesmanRole.id,
          permissionId,
        },
      },
      update: {},
      create: {
        roleId: salesmanRole.id,
        permissionId,
      },
    });
  }

  await prisma.shopUser.upsert({
    where: {
      shopId_userId: {
        shopId: shop.id,
        userId: storeOwner.id,
      },
    },
    update: {
      roleId: ownerRole.id,
      status: ShopUserStatus.ACTIVE,
      billingStatus: BillingStatus.BILLABLE,
    },
    create: {
      shopId: shop.id,
      userId: storeOwner.id,
      roleId: ownerRole.id,
      status: ShopUserStatus.ACTIVE,
      billingStatus: BillingStatus.BILLABLE,
    },
  });

  await prisma.shopUser.upsert({
    where: {
      shopId_userId: {
        shopId: shop.id,
        userId: staffUser.id,
      },
    },
    update: {
      roleId: salesmanRole.id,
      status: ShopUserStatus.ACTIVE,
      billingStatus: BillingStatus.FREE,
    },
    create: {
      shopId: shop.id,
      userId: staffUser.id,
      roleId: salesmanRole.id,
      status: ShopUserStatus.ACTIVE,
      billingStatus: BillingStatus.FREE,
    },
  });

  console.log("Seed completed.");
  console.log("Admin login: admin@deshit");
  console.log("Store owner login: owner@dokanerp.local");
  console.log("Staff login: staff@dokanerp.local");
  console.log("Supplier login: supplier@dokanerp.local");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
