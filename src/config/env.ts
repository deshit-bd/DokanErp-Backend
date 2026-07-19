import "dotenv/config";
import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  PORT: z.coerce.number().int().positive().default(4000),
  DATABASE_URL: z.string().min(1, "DATABASE_URL is required"),
  // Optional here so local/dev can start without it; enforced below in production.
  AUTH_JWT_SECRET: z.string().min(16, "AUTH_JWT_SECRET must be at least 16 chars").optional(),
  // Comma-separated allow-list of origins for CORS (e.g. "https://app.example.com").
  CORS_ALLOWED_ORIGINS: z.string().optional(),
});

const parsed = schema.safeParse(process.env);

if (!parsed.success) {
  console.error(
    "Invalid environment configuration:",
    JSON.stringify(parsed.error.flatten().fieldErrors, null, 2),
  );
  process.exit(1);
}

const isProd = parsed.data.NODE_ENV === "production";

// Fail fast: never silently fall back to a public secret in production.
if (isProd && !parsed.data.AUTH_JWT_SECRET) {
  console.error(
    "AUTH_JWT_SECRET must be set in production. Refusing to start with an insecure default.",
  );
  process.exit(1);
}

export const env = {
  ...parsed.data,
  isProd,
  // Dev convenience only; production is guaranteed to have a real secret by the check above.
  AUTH_JWT_SECRET: parsed.data.AUTH_JWT_SECRET ?? "dev-only-auth-secret",
  corsAllowedOrigins:
    parsed.data.CORS_ALLOWED_ORIGINS?.split(",")
      .map((value) => value.trim())
      .filter(Boolean) ?? [],
};
