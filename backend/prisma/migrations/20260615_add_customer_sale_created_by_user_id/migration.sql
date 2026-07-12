ALTER TABLE "customer_sales"
ADD COLUMN "created_by_user_id" TEXT;

ALTER TABLE "customer_sales"
ADD CONSTRAINT "customer_sales_created_by_user_id_fkey"
FOREIGN KEY ("created_by_user_id") REFERENCES "users"("id")
ON DELETE SET NULL
ON UPDATE CASCADE;

CREATE INDEX "customer_sales_created_by_user_id_idx"
ON "customer_sales"("created_by_user_id");
