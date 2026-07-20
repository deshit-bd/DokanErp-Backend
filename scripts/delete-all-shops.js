const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('Starting deletion of all shops, owners, and salesmen...');

  // 1. Get platform users to avoid deleting them
  const platformUsers = await prisma.platformUser.findMany({
    select: { userId: true },
  });
  const platformUserIds = platformUsers.map((pu) => pu.userId);
  console.log('Platform user IDs to protect (Super Admin/Admin):', platformUserIds);

  // 2. Perform deletion of dependent models in correct order to avoid foreign key violations
  await prisma.$transaction(async (tx) => {
    // Delete payments and invoices
    await tx.payment.deleteMany({});
    await tx.invoice.deleteMany({});
    await tx.subscription.deleteMany({});

    // Delete purchase and sale transactions
    await tx.purchaseItem.deleteMany({});
    await tx.purchaseReturnItem.deleteMany({});
    await tx.customerSaleItem.deleteMany({});
    await tx.purchaseReturn.deleteMany({});
    await tx.purchase.deleteMany({});
    await tx.customerSale.deleteMany({});
    await tx.customerPayment.deleteMany({});
    await tx.supplierPayment.deleteMany({});
    await tx.supplierLedger.deleteMany({});
    await tx.customerLedger.deleteMany({});
    await tx.stockMovement.deleteMany({});
    await tx.expense.deleteMany({});

    // Delete inventory and settings
    await tx.inventoryBinItem.deleteMany({});
    await tx.inventoryBin.deleteMany({});
    await tx.inventoryShelf.deleteMany({});
    await tx.inventoryRack.deleteMany({});
    await tx.inventoryZone.deleteMany({});
    await tx.shopInventorySetting.deleteMany({});

    // Delete master product requests and shop products
    await tx.shopProduct.deleteMany({});
    await tx.masterProductRequest.deleteMany({});

    // Delete other shop dependencies
    await tx.moneyBox.deleteMany({});
    await tx.bankAccount.deleteMany({});
    await tx.supplier.deleteMany({});
    await tx.customer.deleteMany({});
    await tx.shopTax.deleteMany({});
    await tx.shopCharge.deleteMany({});
    await tx.notificationSetting.deleteMany({});
    await tx.inAppNotification.deleteMany({});
    await tx.shopReceiptSetting.deleteMany({});

    // Delete auth and registrations
    await tx.otpVerification.deleteMany({});
    await tx.passwordResetRequest.deleteMany({});
    await tx.ownerRegistrationDraft.deleteMany({});

    // Delete non-global product categories and units
    await tx.categoryLog.deleteMany({});
    await tx.productCategory.deleteMany({
      where: {
        isGlobal: false,
      },
    });
    await tx.unit.deleteMany({
      where: {
        isGlobal: false,
      },
    });

    // Delete shop users and permissions
    await tx.salesmanPermission.deleteMany({});
    await tx.shopUser.deleteMany({});

    // Delete all shops
    const deletedShopsCount = await tx.shop.deleteMany({});
    console.log(`Deleted ${deletedShopsCount.count} shops.`);

    // Delete users that are NOT platform users
    // First delete user pins and refresh tokens for these users
    await tx.userPin.deleteMany({
      where: {
        userId: {
          notIn: platformUserIds,
        },
      },
    });

    await tx.refreshToken.deleteMany({
      where: {
        userId: {
          notIn: platformUserIds,
        },
      },
    });

    const deletedUsersCount = await tx.user.deleteMany({
      where: {
        id: {
          notIn: platformUserIds,
        },
      },
    });
    console.log(`Deleted ${deletedUsersCount.count} users (owners/salesmen).`);
  });

  console.log('Deletion completed successfully.');
}

main()
  .catch((e) => {
    console.error('Error during deletion:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
