import { PrismaClient, CustomerLedgerEntryType } from "@prisma/client";
import crypto from "crypto";

const prisma = new PrismaClient();

async function run() {
  const shopId = "cmrfvgi9n01a00t9vp2qtoosx"; // Sakib's shop 'deshit'
  const shopOwnerPhone = "01762161370";      // Sakib's phone

  const user = await prisma.user.findFirst({
    where: { phone: shopOwnerPhone },
  });

  if (!user) {
    console.error("User Sakib not found!");
    return;
  }

  // 1. Create mock customers
  const customersData = [
    { name: "আব্দুর রহমান", mobile: "01700000001", customerCode: "CUST-001" },
    { name: "মো: করিম", mobile: "01700000002", customerCode: "CUST-002" },
    { name: "সাদিয়া ইসলাম", mobile: "01700000003", customerCode: "CUST-003" },
    { name: "নাসরিন আক্তার", mobile: "01700000004", customerCode: "CUST-004" },
    { name: "কামাল হোসেন", mobile: "01700000005", customerCode: "CUST-005" },
  ];

  console.log("Upserting mock customers...");
  const customers = [];
  for (const c of customersData) {
    const cust = await prisma.customer.upsert({
      where: { customerCode: c.customerCode },
      update: {},
      create: {
        name: c.name,
        mobile: c.mobile,
        customerCode: c.customerCode,
        status: "ACTIVE",
      },
    });
    customers.push(cust);
  }

  // 2. Fetch shop products for deshit
  const shopProducts = await prisma.shopProduct.findMany({
    where: { shopId },
    include: { masterProduct: true },
  });

  if (shopProducts.length === 0) {
    console.error("No shop products found for shop deshit!");
    return;
  }

  console.log(`Found ${shopProducts.length} shop products. Generating 25 transactions...`);

  // Clear existing sales to make it fresh and correct
  await prisma.customerLedger.deleteMany({ where: { shopId } });
  await prisma.customerSaleItem.deleteMany({
    where: { customerSale: { shopId } }
  });
  await prisma.customerSale.deleteMany({ where: { shopId } });
  await prisma.stockMovement.deleteMany({ where: { shopId } });

  const paymentMethods = ["CASH", "BKASH", "CARD", "DUE"];

  for (let i = 0; i < 25; i++) {
    // Select random customer
    const customer = customers[Math.floor(Math.random() * customers.length)];
    
    // Generate sale date in the last 7 days
    const dateOffset = Math.floor(Math.random() * 7); // 0 to 6 days ago
    const hourOffset = Math.floor(Math.random() * 12) + 9; // 9 AM to 9 PM
    const minOffset = Math.floor(Math.random() * 60);
    const saleDate = new Date();
    saleDate.setDate(saleDate.getDate() - dateOffset);
    saleDate.setHours(hourOffset, minOffset, 0, 0);

    const invoiceNo = `INV-${saleDate.getFullYear()}${(saleDate.getMonth() + 1).toString().padStart(2, "0")}${saleDate.getDate().toString().padStart(2, "0")}-${1000 + i}`;
    const paymentMethod = paymentMethods[Math.floor(Math.random() * paymentMethods.length)];

    // Pick 1 to 3 random items
    const numItems = Math.floor(Math.random() * 3) + 1;
    const selectedProducts = [];
    const shoptProductsCopy = [...shopProducts];
    
    for (let j = 0; j < numItems && shoptProductsCopy.length > 0; j++) {
      const idx = Math.floor(Math.random() * shoptProductsCopy.length);
      selectedProducts.push(shoptProductsCopy.splice(idx, 1)[0]);
    }

    let totalAmount = 0;
    const saleItemsData = [];

    for (const shopProd of selectedProducts) {
      const quantity = Math.floor(Math.random() * 4) + 1; // 1 to 4
      const salePrice = Number(shopProd.salePrice ?? 100);
      const purchasePrice = Number(shopProd.purchasePrice ?? 80);
      const itemTotal = salePrice * quantity;

      totalAmount += itemTotal;
      saleItemsData.push({
        shopProductId: shopProd.id,
        masterProductId: shopProd.masterProductId!,
        quantity,
        salePrice,
        purchasePrice,
        totalAmount: itemTotal,
      });
    }

    let paidAmount = totalAmount;
    let dueAmount = 0;
    let status = "PAID";

    if (paymentMethod === "DUE") {
      paidAmount = 0;
      dueAmount = totalAmount;
      status = "UNPAID";
    }

    // Create the Sale
    const sale = await prisma.customerSale.create({
      data: {
        shopId,
        customerId: customer.id,
        createdByUserId: user.id,
        invoiceNo,
        saleDate,
        totalAmount,
        paidAmount,
        dueAmount,
        paymentMethod,
        status,
        items: {
          create: saleItemsData.map((item) => ({
            masterProductId: item.masterProductId,
            quantity: item.quantity,
            salePrice: item.salePrice,
            purchasePrice: item.purchasePrice,
            totalAmount: item.totalAmount,
          })),
        },
      },
    });

    // Create StockMovements and Ledger entries
    for (const item of saleItemsData) {
      await prisma.stockMovement.create({
        data: {
          shopId,
          shopProductId: item.shopProductId,
          masterProductId: item.masterProductId,
          movementType: "SALE",
          quantityDelta: -item.quantity,
          stockBefore: 100,
          stockAfter: 100 - item.quantity,
          purchasePrice: item.purchasePrice,
          salePrice: item.salePrice,
          unitPrice: item.salePrice,
          referenceType: "CUSTOMER_SALE",
          referenceId: sale.id,
          referenceNo: invoiceNo,
          note: `Sold via Invoice ${invoiceNo}`,
          createdByUserId: user.id,
          createdAt: saleDate,
        },
      });
    }

    // Ledger Entry for dues
    if (paymentMethod === "DUE") {
      await prisma.customerLedger.create({
        data: {
          shopId,
          customerId: customer.id,
          entryType: CustomerLedgerEntryType.SALE,
          customerSaleId: sale.id,
          referenceNo: invoiceNo,
          debit: totalAmount,
          credit: 0,
          notes: `Due sale via Invoice ${invoiceNo}`,
          entryDate: saleDate,
          createdAt: saleDate,
        },
      });
    }
  }

  console.log("Seeding mock sales history complete!");
  const totalSales = await prisma.customerSale.count({ where: { shopId } });
  const totalItems = await prisma.customerSaleItem.count({
    where: { customerSale: { shopId } }
  });
  console.log(`Verified total sales created: ${totalSales} orders with ${totalItems} items.`);

  await prisma.$disconnect();
}

run();
