ALTER TABLE "purchases"
ADD COLUMN IF NOT EXISTS "payment_meta" JSONB;

ALTER TABLE "supplier_payments"
ADD COLUMN IF NOT EXISTS "payment_meta" JSONB;
