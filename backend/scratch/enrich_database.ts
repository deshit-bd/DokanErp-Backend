import { PrismaClient, ShopProductSource } from "@prisma/client";

const prisma = new PrismaClient();

async function run() {
  const shopId = "cmrfvgi9n01a00t9vp2qtoosx"; // Sakib's shop 'deshit'
  const salesmanId = "cmrg2uygs001y0tzld77zqz3p"; // Salesman 'haland'
  const ownerId = "cmrfvgi81019y0t9vtl0ov4oz"; // Owner 'sakib'

  console.log("Starting database enrichment for shop: deshit...");

  // 1. Find or create default inventory bin, zone, rack, and shelf
  console.log("Locating default general inventory bin...");
  let bin = await prisma.inventoryBin.findFirst({
    where: { shopId },
  });

  if (!bin) {
    console.log("No existing bin found. Creating default inventory hierarchy...");
    const zone = await prisma.inventoryZone.create({
      data: {
        shopId,
        name: "General Zone",
        sortOrder: 1,
      },
    });

    const rack = await prisma.inventoryRack.create({
      data: {
        shopId,
        zoneId: zone.id,
        name: "General Rack",
        shelfCount: 1,
        sortOrder: 1,
      },
    });

    const shelf = await prisma.inventoryShelf.create({
      data: {
        shopId,
        zoneId: zone.id,
        rackId: rack.id,
        name: "General Shelf",
        sortOrder: 1,
      },
    });

    bin = await prisma.inventoryBin.create({
      data: {
        shop: { connect: { id: shopId } },
        zone: { connect: { id: zone.id } },
        rack: { connect: { id: rack.id } },
        shelf: { connect: { id: shelf.id } },
        code: "GEN-BIN-01",
        productName: "General Bin",
        status: "FULL",
        sortOrder: 1,
      },
    });
  }

  console.log(`Using inventory bin ID: ${bin.id}`);

  // 2. Fetch the 200 shop products
  const shopProducts = await prisma.shopProduct.findMany({
    where: { shopId },
    include: { masterProduct: true },
  });

  console.log(`Found ${shopProducts.length} shop products. Seeding stock and alerts...`);

  // Clear existing bin items and damage movements to avoid duplicates
  await prisma.inventoryBinItem.deleteMany({ where: { shopId } });
  await prisma.stockMovement.deleteMany({
    where: { shopId, movementType: { in: ["DAMAGE", "ADJUSTMENT"] } }
  });

  // 3. Populate stock & set low stock limits
  const binItemsToCreate = [];
  const damageMovementsToCreate = [];

  for (let i = 0; i < shopProducts.length; i++) {
    const shopProd = shopProducts[i];
    const purchasePrice = Number(shopProd.purchasePrice ?? 80);
    const salePrice = Number(shopProd.salePrice ?? 100);

    let quantity = 50; // default healthy stock
    let lowStockLimit = 5;

    // Make 25 products have LOW STOCK (e.g. quantity = 2, limit = 5)
    if (i < 25) {
      quantity = 2;
      lowStockLimit = 5;
    }

    // Set low stock limit on ShopProduct
    await prisma.shopProduct.update({
      where: { id: shopProd.id },
      data: { lowStockLimit },
    });

    // Add bin item for stock
    binItemsToCreate.push({
      shopId,
      binId: bin.id,
      masterProductId: shopProd.masterProductId!,
      quantity,
      purchasePrice,
      salePrice,
      batchNo: `BATCH-${100 + i}`,
    });

    // Make 10 products have some DAMAGE records
    if (i >= 30 && i < 40) {
      damageMovementsToCreate.push({
        shopId,
        shopProductId: shopProd.id,
        masterProductId: shopProd.masterProductId!,
        movementType: "DAMAGE",
        quantityDelta: -3,
        stockBefore: 50,
        stockAfter: 47,
        purchasePrice,
        salePrice,
        unitPrice: salePrice,
        referenceType: "MANUAL_ADJUSTMENT",
        note: "ক্ষতিগ্রস্ত বা নষ্ট পণ্য",
        createdByUserId: ownerId,
      });
    }
  }

  console.log("Inserting bin items...");
  await prisma.inventoryBinItem.createMany({
    data: binItemsToCreate,
  });

  console.log("Inserting damage stock movements...");
  if (damageMovementsToCreate.length > 0) {
    await prisma.stockMovement.createMany({
      data: damageMovementsToCreate,
    });
  }

  // 4. Create Today's Expenses
  console.log("Clearing and creating today's expenses...");
  await prisma.expense.deleteMany({ where: { shopId } });
  
  const today = new Date();
  await prisma.expense.createMany({
    data: [
      {
        shopId,
        category: "Utility",
        amount: 1500,
        expenseDate: today,
        description: "বিদ্যুৎ বিল (আজ পরিশোধিত)",
        paymentMethod: "CASH",
        status: "ACTIVE",
      },
      {
        shopId,
        category: "Salary",
        amount: 3000,
        expenseDate: today,
        description: "সহকারী কর্মচারীর বেতন",
        paymentMethod: "CASH",
        status: "ACTIVE",
      },
      {
        shopId,
        category: "Others",
        amount: 350,
        expenseDate: today,
        description: "কাস্টমারদের আপ্যায়ন খরচ",
        paymentMethod: "CASH",
        status: "ACTIVE",
      },
    ],
  });

  // 5. Add Salesman Sales (Haland)
  console.log("Creating 10 sales created by Salesman Haland...");
  const customers = await prisma.customer.findMany();
  
  for (let i = 0; i < 10; i++) {
    const customer = customers[Math.floor(Math.random() * customers.length)];
    const saleDate = new Date(); // Today's sales
    const invoiceNo = `INV-SLS-${saleDate.getFullYear()}${(saleDate.getMonth() + 1).toString().padStart(2, "0")}${saleDate.getDate().toString().padStart(2, "0")}-${2000 + i}`;

    // Select 1 random product
    const shopProd = shopProducts[Math.floor(Math.random() * shopProducts.length)];
    const quantity = Math.floor(Math.random() * 2) + 1;
    const salePrice = Number(shopProd.salePrice ?? 100);
    const purchasePrice = Number(shopProd.purchasePrice ?? 80);
    const totalAmount = salePrice * quantity;

    const sale = await prisma.customerSale.create({
      data: {
        shopId,
        customerId: customer.id,
        createdByUserId: salesmanId, // Created by Salesman
        invoiceNo,
        saleDate,
        totalAmount,
        paidAmount: totalAmount,
        dueAmount: 0,
        paymentMethod: "CASH",
        status: "PAID",
        items: {
          create: [
            {
              masterProductId: shopProd.masterProductId!,
              quantity,
              salePrice,
              purchasePrice,
              totalAmount,
            },
          ],
        },
      },
    });

    // Stock Movement for salesman sale
    await prisma.stockMovement.create({
      data: {
        shopId,
        shopProductId: shopProd.id,
        masterProductId: shopProd.masterProductId!,
        movementType: "SALE",
        quantityDelta: -quantity,
        stockBefore: 50,
        stockAfter: 50 - quantity,
        purchasePrice,
        salePrice,
        unitPrice: salePrice,
        referenceType: "CUSTOMER_SALE",
        referenceId: sale.id,
        referenceNo: invoiceNo,
        note: "Sold by Salesman Haland",
        createdByUserId: salesmanId,
        createdAt: saleDate,
      },
    });
  }

  console.log("Database enrichment successfully completed!");
  
  const totalBinItems = await prisma.inventoryBinItem.count({ where: { shopId } });
  const totalExpenses = await prisma.expense.count({ where: { shopId } });
  const totalSales = await prisma.customerSale.count({ where: { shopId } });
  
  console.log(`Enrichment Summary: Bin Items: ${totalBinItems}, Today's Expenses: ${totalExpenses}, Total Sales: ${totalSales}`);

  await prisma.$disconnect();
}

run();
