import {
  BarcodeStatus,
  BrandStatus,
  CategoryLogAction,
  CategoryStatus,
  MasterProductStatus,
  PlatformRole,
  PrismaClient,
  ShopRole,
  ShopStatus,
  UnitStatus,
  UnitType,
  UserStatus,
} from "@prisma/client";

const prisma = new PrismaClient();

type SeedUserInput = {
  name: string;
  email?: string;
  phone?: string;
  passwordHash: string;
  status?: UserStatus;
  createdByUserId?: string;
};

async function upsertUserByEmailOrPhone(data: SeedUserInput) {
  if (data.email) {
    const existingByEmail = await prisma.user.findUnique({
      where: { email: data.email },
    });

    if (existingByEmail) {
      return prisma.user.update({
        where: { id: existingByEmail.id },
        data,
      });
    }
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

  return prisma.user.create({
    data: {
      ...data,
      status: data.status ?? UserStatus.ACTIVE,
    },
  });
}

async function main() {
  const superAdmin = await upsertUserByEmailOrPhone({
    name: "Demo Super Admin",
    email: "superadmin@dokanerp.local",
    phone: "+8801000000000",
    passwordHash: "12345678",
  });

  await prisma.platformUser.upsert({
    where: { userId: superAdmin.id },
    update: {
      role: PlatformRole.SUPER_ADMIN,
    },
    create: {
      userId: superAdmin.id,
      role: PlatformRole.SUPER_ADMIN,
    },
  });

  const admin = await upsertUserByEmailOrPhone({
    name: "Demo Admin",
    email: "admin@dokanerp.local",
    phone: "+8801000000009",
    passwordHash: "change-me-before-production",
    createdByUserId: superAdmin.id,
  });

  await prisma.platformUser.upsert({
    where: { userId: admin.id },
    update: {
      role: PlatformRole.ADMIN,
    },
    create: {
      userId: admin.id,
      role: PlatformRole.ADMIN,
    },
  });

  const shopOwner = await upsertUserByEmailOrPhone({
    name: "Demo Store Owner",
    email: "owner@dokanerp.local",
    phone: "+8801000000001",
    passwordHash: "change-me-before-production",
    createdByUserId: superAdmin.id,
  });

  const salesman = await upsertUserByEmailOrPhone({
    name: "Demo Salesman",
    email: "salesman@dokanerp.local",
    phone: "+8801000000002",
    passwordHash: "change-me-before-production",
    createdByUserId: admin.id,
  });

  const shop = await prisma.shop.upsert({
    where: { id: "00000000-0000-0000-0000-000000000001" },
    update: {
      shopName: "Dokan Demo Store",
      ownerUserId: shopOwner.id,
      phone: "+8801999999999",
      email: "shop@dokanerp.local",
      address: "Mirpur, Dhaka, Bangladesh",
      district: "Dhaka",
      status: ShopStatus.ACTIVE,
    },
    create: {
      id: "00000000-0000-0000-0000-000000000001",
      shopName: "Dokan Demo Store",
      ownerUserId: shopOwner.id,
      phone: "+8801999999999",
      email: "shop@dokanerp.local",
      address: "Mirpur, Dhaka, Bangladesh",
      district: "Dhaka",
      status: ShopStatus.ACTIVE,
    },
  });

  await prisma.shopUser.upsert({
    where: {
      shopId_userId: {
        shopId: shop.id,
        userId: shopOwner.id,
      },
    },
    update: {
      role: ShopRole.SHOP_OWNER,
      isBillable: true,
    },
    create: {
      shopId: shop.id,
      userId: shopOwner.id,
      role: ShopRole.SHOP_OWNER,
      isBillable: true,
    },
  });

  await prisma.shopUser.upsert({
    where: {
      shopId_userId: {
        shopId: shop.id,
        userId: salesman.id,
      },
    },
    update: {
      role: ShopRole.SALESMAN,
      isBillable: true,
    },
    create: {
      shopId: shop.id,
      userId: salesman.id,
      role: ShopRole.SALESMAN,
      isBillable: true,
    },
  });

  const beveragesCategory = await prisma.productCategory.upsert({
    where: { name: "Beverages" },
    update: {
      description: "Soft drinks, juices, energy drinks, and bottled water.",
      status: CategoryStatus.ACTIVE,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
    create: {
      name: "Beverages",
      description: "Soft drinks, juices, energy drinks, and bottled water.",
      status: CategoryStatus.ACTIVE,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
  });

  const snacksCategory = await prisma.productCategory.upsert({
    where: { name: "Snacks" },
    update: {
      description: "Biscuits, chips, noodles, and packaged snack items.",
      status: CategoryStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
    create: {
      name: "Snacks",
      description: "Biscuits, chips, noodles, and packaged snack items.",
      status: CategoryStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
  });

  const seasonalCategory = await prisma.productCategory.upsert({
    where: { name: "Seasonal Items" },
    update: {
      description: "Special campaigns, festive bundles, and time-based items.",
      status: CategoryStatus.INACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
    create: {
      name: "Seasonal Items",
      description: "Special campaigns, festive bundles, and time-based items.",
      status: CategoryStatus.INACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
  });

  const pranBrand = await prisma.brand.upsert({
    where: { name: "PRAN" },
    update: {
      description: "Food & Beverage Products",
      status: BrandStatus.ACTIVE,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
    create: {
      name: "PRAN",
      description: "Food & Beverage Products",
      status: BrandStatus.ACTIVE,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
  });

  const freshBrand = await prisma.brand.upsert({
    where: { name: "Fresh" },
    update: {
      description: "Dairy & Grocery Products",
      status: BrandStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
    create: {
      name: "Fresh",
      description: "Dairy & Grocery Products",
      status: BrandStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
  });

  const radhuniBrand = await prisma.brand.upsert({
    where: { name: "Radhuni" },
    update: {
      description: "Spices & Cooking Essentials",
      status: BrandStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
    create: {
      name: "Radhuni",
      description: "Spices & Cooking Essentials",
      status: BrandStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
  });

  const unitSeedData = [
    {
      name: "Piece",
      shortName: "pcs",
      type: UnitType.COUNTABLE,
      description: "Count products individually as pieces.",
      status: UnitStatus.ACTIVE,
    },
    {
      name: "Kilogram",
      shortName: "kg",
      type: UnitType.WEIGHT,
      description: "Measure heavy goods by kilogram.",
      status: UnitStatus.ACTIVE,
    },
    {
      name: "Gram",
      shortName: "gm",
      type: UnitType.WEIGHT,
      description: "Measure smaller weight quantities.",
      status: UnitStatus.ACTIVE,
    },
    {
      name: "Liter",
      shortName: "ltr",
      type: UnitType.VOLUME,
      description: "Measure liquid products by liter.",
      status: UnitStatus.ACTIVE,
    },
    {
      name: "Box",
      shortName: "box",
      type: UnitType.PACKAGING,
      description: "Bundle items in a single box.",
      status: UnitStatus.INACTIVE,
    },
  ] as const;

  for (const unit of unitSeedData) {
    await prisma.unit.upsert({
      where: { name: unit.name },
      update: unit,
      create: unit,
    });
  }

  const pieceUnit = await prisma.unit.findUnique({
    where: { name: "Piece" },
  });

  const kilogramUnit = await prisma.unit.findUnique({
    where: { name: "Kilogram" },
  });

  const literUnit = await prisma.unit.findUnique({
    where: { name: "Liter" },
  });

  const orangeJuice = await prisma.masterProduct.upsert({
    where: { sku: "PRD-0001" },
    update: {
      name: "Orange Juice 1L",
      description: "Natural fruit drink for demo catalog data.",
      categoryId: beveragesCategory.id,
      brandId: pranBrand.id,
      unitId: literUnit?.id,
      price: 125,
      suggestedPrice: 130,
      packageSize: "1 L",
      status: MasterProductStatus.ACTIVE,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
    create: {
      sku: "PRD-0001",
      name: "Orange Juice 1L",
      description: "Natural fruit drink for demo catalog data.",
      categoryId: beveragesCategory.id,
      brandId: pranBrand.id,
      unitId: literUnit?.id,
      price: 125,
      suggestedPrice: 130,
      packageSize: "1 L",
      status: MasterProductStatus.ACTIVE,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
  });

  const chips = await prisma.masterProduct.upsert({
    where: { sku: "PRD-0002" },
    update: {
      name: "Potato Chips Family Pack",
      description: "Demo snack product linked with the Snacks category.",
      categoryId: snacksCategory.id,
      brandId: freshBrand.id,
      unitId: pieceUnit?.id,
      price: 120,
      suggestedPrice: 125,
      packageSize: "12 pcs",
      status: MasterProductStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
    create: {
      sku: "PRD-0002",
      name: "Potato Chips Family Pack",
      description: "Demo snack product linked with the Snacks category.",
      categoryId: snacksCategory.id,
      brandId: freshBrand.id,
      unitId: pieceUnit?.id,
      price: 120,
      suggestedPrice: 125,
      packageSize: "12 pcs",
      status: MasterProductStatus.ACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
  });

  const giftBox = await prisma.masterProduct.upsert({
    where: { sku: "PRD-0003" },
    update: {
      name: "Festival Gift Box",
      description: "Demo archived-style catalog item for seasonal workflows.",
      categoryId: seasonalCategory.id,
      brandId: radhuniBrand.id,
      unitId: kilogramUnit?.id,
      price: 1950,
      suggestedPrice: 2050,
      packageSize: "25 KG",
      status: MasterProductStatus.INACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
    create: {
      sku: "PRD-0003",
      name: "Festival Gift Box",
      description: "Demo archived-style catalog item for seasonal workflows.",
      categoryId: seasonalCategory.id,
      brandId: radhuniBrand.id,
      unitId: kilogramUnit?.id,
      price: 1950,
      suggestedPrice: 2050,
      packageSize: "25 KG",
      status: MasterProductStatus.INACTIVE,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
  });

  const barcodeSeedData = [
    {
      masterProductId: orangeJuice.id,
      barcode: "8901234567001",
      packSize: "1 L",
      status: BarcodeStatus.MAPPED,
      createdByUserId: superAdmin.id,
      updatedByUserId: superAdmin.id,
    },
    {
      masterProductId: chips.id,
      barcode: "8901234567002",
      packSize: "12 pcs",
      status: BarcodeStatus.MAPPED,
      createdByUserId: admin.id,
      updatedByUserId: admin.id,
    },
    {
      masterProductId: giftBox.id,
      barcode: "8901234567003",
      packSize: "25 KG",
      status: BarcodeStatus.MAPPED,
      createdByUserId: admin.id,
      updatedByUserId: superAdmin.id,
    },
  ] as const;

  for (const barcode of barcodeSeedData) {
    const existingBarcode = await prisma.masterProductBarcode.findUnique({
      where: { barcode: barcode.barcode },
    });

    if (existingBarcode) {
      await prisma.masterProductBarcode.update({
        where: { id: existingBarcode.id },
        data: barcode,
      });
      continue;
    }

    await prisma.masterProductBarcode.create({
      data: barcode,
    });
  }

  const existingCategoryLogs = await prisma.categoryLog.count();

  if (existingCategoryLogs === 0) {
    await prisma.categoryLog.createMany({
      data: [
        {
          categoryId: beveragesCategory.id,
          action: CategoryLogAction.CREATED,
          newData: {
            name: "Beverages",
            status: CategoryStatus.ACTIVE,
          },
          performedById: superAdmin.id,
        },
        {
          categoryId: snacksCategory.id,
          action: CategoryLogAction.CREATED,
          newData: {
            name: "Snacks",
            status: CategoryStatus.ACTIVE,
          },
          performedById: admin.id,
        },
        {
          categoryId: seasonalCategory.id,
          action: CategoryLogAction.STATUS_CHANGED,
          oldData: {
            status: CategoryStatus.ACTIVE,
          },
          newData: {
            status: CategoryStatus.INACTIVE,
          },
          performedById: superAdmin.id,
        },
      ],
    });
  }

  console.log("Seed completed.");
  console.log("Super admin login: superadmin@dokanerp.local");
  console.log("Admin login: admin@dokanerp.local");
  console.log("Shop owner login: owner@dokanerp.local");
  console.log("Salesman login: salesman@dokanerp.local");
  console.log("Demo categories: Beverages, Snacks, Seasonal Items");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
