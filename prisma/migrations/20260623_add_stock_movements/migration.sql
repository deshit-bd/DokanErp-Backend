CREATE TABLE "stock_movements" (
  "id" TEXT NOT NULL,
  "shop_id" TEXT NOT NULL,
  "shop_product_id" TEXT NOT NULL,
  "master_product_id" TEXT,
  "movement_type" VARCHAR(40) NOT NULL,
  "quantity_delta" DECIMAL(12, 3) NOT NULL DEFAULT 0,
  "stock_before" DECIMAL(12, 3),
  "stock_after" DECIMAL(12, 3),
  "purchase_price" DECIMAL(10, 2),
  "sale_price" DECIMAL(10, 2),
  "unit_price" DECIMAL(10, 2),
  "reference_type" VARCHAR(40),
  "reference_id" TEXT,
  "reference_no" VARCHAR(80),
  "note" TEXT,
  "metadata" JSONB,
  "created_by_user_id" TEXT,
  "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "stock_movements_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "stock_movements_shop_id_shop_product_id_created_at_idx"
ON "stock_movements"("shop_id", "shop_product_id", "created_at");

CREATE INDEX "stock_movements_shop_id_master_product_id_created_at_idx"
ON "stock_movements"("shop_id", "master_product_id", "created_at");
