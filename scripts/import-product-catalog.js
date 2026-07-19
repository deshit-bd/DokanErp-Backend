const { PrismaClient } = require('@prisma/client');
const xlsx = require('xlsx');
const path = require('path');

const prisma = new PrismaClient();

const FILE_PATH = 'C:/Users/sajib/Downloads/product-catalog-FILLED/product-catalog-FILLED/URL_product-catalog-FILLED 1-7252.xlsx';

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

async function main() {
  const wb = xlsx.readFile(FILE_PATH);
  const rows = xlsx.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]], { defval: null });
  console.log(`Read ${rows.length} rows from ${path.basename(FILE_PATH)}`);

  // --- 1. Ensure all categories exist ---
  const sheetCatNames = [...new Set(rows.map(r => String(r['Category']).trim()))];
  const existingCats = await prisma.productCategory.findMany({ select: { id: true, name: true } });
  const catByLowerName = new Map(existingCats.map(c => [c.name.trim().toLowerCase(), c]));

  const missingCatNames = sheetCatNames.filter(n => !catByLowerName.has(n.toLowerCase()));
  for (const name of missingCatNames) {
    const created = await prisma.productCategory.create({
      data: { name, status: 'ACTIVE', isGlobal: true, isApproved: true },
    });
    catByLowerName.set(name.toLowerCase(), created);
  }
  console.log(`Categories: ${sheetCatNames.length} in sheet, ${missingCatNames.length} newly created.`);

  // --- 2. Ensure all brands exist ---
  const sheetBrandNames = [...new Set(rows.map(r => String(r['Brand']).trim()))];
  const existingBrands = await prisma.brand.findMany({ select: { id: true, name: true } });
  const brandByLowerName = new Map(existingBrands.map(b => [b.name.trim().toLowerCase(), b]));

  const missingBrandNames = sheetBrandNames.filter(n => !brandByLowerName.has(n.toLowerCase()));
  for (const name of missingBrandNames) {
    const created = await prisma.brand.create({
      data: { name, status: 'ACTIVE' },
    });
    brandByLowerName.set(name.toLowerCase(), created);
  }
  console.log(`Brands: ${sheetBrandNames.length} in sheet, ${missingBrandNames.length} newly created.`);

  // --- 3. Map units (all sheet units are expected to already exist by shortName) ---
  const sheetUnitNames = [...new Set(rows.map(r => String(r['Unit']).trim()))];
  const existingUnits = await prisma.unit.findMany({ select: { id: true, shortName: true } });
  const unitByShortName = new Map(existingUnits.map(u => [u.shortName.trim().toLowerCase(), u]));

  const missingUnitNames = sheetUnitNames.filter(n => !unitByShortName.has(n.toLowerCase()));
  if (missingUnitNames.length > 0) {
    console.warn('WARNING: unmapped units found (will be created as COUNTABLE):', missingUnitNames);
    for (const shortName of missingUnitNames) {
      const created = await prisma.unit.create({
        data: { name: shortName, shortName, type: 'COUNTABLE', status: 'ACTIVE', isGlobal: true, isApproved: true },
      });
      unitByShortName.set(shortName.toLowerCase(), created);
    }
  }

  // --- 4. Upsert products + barcodes ---
  let created = 0, updated = 0, skipped = 0;
  const skippedRows = [];

  const batches = chunk(rows, 25);
  let processed = 0;
  for (const batch of batches) {
    await Promise.all(batch.map(async (r) => {
      const sku = r['SKU'] ? String(r['SKU']).trim() : null;
      const name = r['Product name'] ? String(r['Product name']).trim() : null;
      const catName = r['Category'] ? String(r['Category']).trim() : null;
      const brandName = r['Brand'] ? String(r['Brand']).trim() : null;
      const unitName = r['Unit'] ? String(r['Unit']).trim() : null;

      if (!sku || !name) {
        skipped++;
        skippedRows.push({ row: r, reason: 'missing sku/name' });
        return;
      }

      const category = catName ? catByLowerName.get(catName.toLowerCase()) : null;
      const brand = brandName ? brandByLowerName.get(brandName.toLowerCase()) : null;
      const unit = unitName ? unitByShortName.get(unitName.toLowerCase()) : null;

      if (catName && !category) {
        skipped++;
        skippedRows.push({ row: r, reason: `category not resolved: ${catName}` });
        return;
      }

      const price = r['Price'] != null ? Number(r['Price']) : null;
      const suggestedPrice = r['Suggested selling price'] != null ? Number(r['Suggested selling price']) : null;
      const packageSize = r['package Size'] != null ? String(r['package Size']).trim() : null;
      const pictureUrl = r['Image URL'] != null ? String(r['Image URL']).trim() : null;
      const description = r['Additional Information'] != null ? String(r['Additional Information']).trim() : null;
      const status = r['Status'] === 'INACTIVE' ? 'INACTIVE' : 'ACTIVE';
      const barcode = r['Barcode'] != null ? String(r['Barcode']).trim() : null;

      const data = {
        name,
        description,
        categoryId: category ? category.id : null,
        brandId: brand ? brand.id : null,
        unitId: unit ? unit.id : null,
        price,
        suggestedPrice,
        packageSize,
        pictureUrl,
        status,
      };

      const product = await prisma.masterProduct.upsert({
        where: { sku },
        create: { sku, ...data },
        update: data,
      });

      if (product.createdAt.getTime() === product.updatedAt.getTime()) created++; else updated++;

      if (barcode) {
        const existingBarcode = await prisma.masterProductBarcode.findUnique({ where: { barcode } });
        if (!existingBarcode) {
          await prisma.masterProductBarcode.create({
            data: { barcode, masterProductId: product.id, packSize: packageSize, status: 'MAPPED' },
          });
        } else if (existingBarcode.masterProductId !== product.id) {
          await prisma.masterProductBarcode.update({
            where: { barcode },
            data: { masterProductId: product.id, packSize: packageSize, status: 'MAPPED' },
          });
        }
      }
    }));
    processed += batch.length;
    if (processed % 500 === 0 || processed === rows.length) {
      console.log(`Processed ${processed}/${rows.length}...`);
    }
  }

  console.log('--- DONE ---');
  console.log({ created, updated, skipped });
  if (skippedRows.length > 0) {
    console.log('Skipped rows sample:', JSON.stringify(skippedRows.slice(0, 10), null, 2));
  }

  const finalCounts = {
    categories: await prisma.productCategory.count(),
    brands: await prisma.brand.count(),
    units: await prisma.unit.count(),
    products: await prisma.masterProduct.count(),
    barcodes: await prisma.masterProductBarcode.count(),
  };
  console.log('Final DB counts:', finalCounts);
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
