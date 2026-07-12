ALTER TABLE "inventory_bin_items"
ADD COLUMN "purchase_price" DECIMAL(10, 2),
ADD COLUMN "sale_price" DECIMAL(10, 2);

ALTER TABLE "customer_sale_items"
ADD COLUMN "batch_no" VARCHAR(80);
