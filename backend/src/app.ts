import cors from "cors";
import express from "express";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import path from "node:path";
import { AppType } from "@prisma/client";

import { env } from "./config/env";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "./auth/current-user";
import { startOtpAutoRenewalJob } from "./auth/otp-renewal";
import authRoutes from "./routes/auth";
import bankAccountRoutes from "./routes/bank-accounts";
import brandRoutes from "./routes/brands";
import categoryRoutes from "./routes/categories";
import customerRoutes, { handleGetConfirmDue, handlePostConfirmDue } from "./routes/customers";
import expenseRoutes from "./routes/expenses";
import inventoryRoutes from "./routes/inventory";
import moneyBoxRoutes from "./routes/money-boxes";
import productRoutes from "./routes/products";
import productTemplateRoutes from "./routes/product-templates";
import purchaseRoutes from "./routes/purchases";
import shopRoutes from "./routes/shops";
import subscriptionRoutes from "./routes/subscriptions";
import supplierRoutes, {
  handleGetConfirmSupplierDue,
  handlePostConfirmSupplierDue,
} from "./routes/suppliers";
import unitRoutes from "./routes/units";
import reportsRoutes from "./routes/reports";
import staffRoutes from "./routes/staff";
import notificationRoutes from "./routes/notifications";
import settingsRoutes from "./routes/settings";
import { evaluateSalesmanTrialAccess, evaluateShopSubscriptionAccess } from "./subscription/access";

const app = express();

// Throttle authentication endpoints to blunt brute-force / credential-stuffing.
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 50,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: "Too many attempts. Please try again later." },
});

function mountApiScope(prefix: string, appType: AppType) {
  const scopedRouter = express.Router();

  scopedRouter.use((request, _response, next) => {
    (request as express.Request & { apiClientAppType?: AppType }).apiClientAppType = appType;
    next();
  });

  if (appType === AppType.MOBILE) {
    scopedRouter.use(async (request, response, next) => {
      if (request.path.startsWith("/auth") || request.path.startsWith("/subscriptions")) {
        return next();
      }

      const auth = await getAuthenticatedUser(request);

      if (isAuthError(auth)) {
        return sendAuthError(response, auth);
      }

      if (auth.payload.appType !== AppType.MOBILE || !auth.payload.shopId) {
        return next();
      }

      const access = await evaluateShopSubscriptionAccess(auth.payload.shopId);

      if (!access.allowed) {
        if (auth.payload.role === "SALESMAN") {
          const salesmanTrial = await evaluateSalesmanTrialAccess(auth.payload.shopId, auth.user.id);

          if (salesmanTrial.allowed) {
            return next();
          }
        }

        return response.status(402).json({
          message: access.message,
          subscription: access,
        });
      }

      return next();
    });
  }

  scopedRouter.use("/auth", authLimiter, authRoutes);
  scopedRouter.use("/bank-accounts", bankAccountRoutes);
  scopedRouter.use("/brands", brandRoutes);
  scopedRouter.use("/categories", categoryRoutes);
  scopedRouter.use("/customers", customerRoutes);
  scopedRouter.use("/expenses", expenseRoutes);
  scopedRouter.use("/inventory", inventoryRoutes);
  scopedRouter.use("/money-boxes", moneyBoxRoutes);
  scopedRouter.use("/products", productRoutes);
  scopedRouter.use("/product-templates", productTemplateRoutes);
  scopedRouter.use("/purchases", purchaseRoutes);
  scopedRouter.use("/shops", shopRoutes);
  scopedRouter.use("/subscriptions", subscriptionRoutes);
  scopedRouter.use("/suppliers", supplierRoutes);
  scopedRouter.use("/staff", staffRoutes);
  scopedRouter.use("/add-suppliers", supplierRoutes);
  scopedRouter.use("/units", unitRoutes);
  scopedRouter.get("/dashboard*", (request, response, next) => {
    if (request.path === "/dashboard/activity") {
      return response.json([]);
    }
    const queryStart = request.url.indexOf("?");
    request.url = queryStart >= 0
      ? `/reports/dashboard${request.url.slice(queryStart)}`
      : "/reports/dashboard";
    next();
  });
  scopedRouter.use("/reports", reportsRoutes);
  scopedRouter.use("/notifications", notificationRoutes);
  scopedRouter.use("/settings", settingsRoutes);

  app.use(prefix, scopedRouter);
}

// Security headers. CSP is for HTML pages (this is a JSON API), and resource
// policy is relaxed so cross-origin clients (mobile web build) can read responses.
app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginResourcePolicy: { policy: "cross-origin" },
  }),
);

// In production, restrict origins to the configured allow-list; in dev, stay open.
app.use(
  cors(
    env.corsAllowedOrigins.length > 0
      ? { origin: env.corsAllowedOrigins, credentials: true }
      : undefined,
  ),
);
app.use(express.json());
app.use("/uploads", express.static(path.resolve(process.cwd(), "uploads")));

app.get("/confirm-due/:token", handleGetConfirmDue);
app.post("/confirm-due/:token", handlePostConfirmDue);
app.get("/confirm-supplier-due/:token", handleGetConfirmSupplierDue);
app.post("/confirm-supplier-due/:token", handlePostConfirmSupplierDue);

app.get("/health", (_request, response) => {
  response.json({
    service: "mudi-erp-api",
    status: "ok",
  });
});

mountApiScope("/web/api", AppType.WEB);
mountApiScope("/app/api", AppType.MOBILE);

// Central error handler: log the detail, never leak stack traces to clients.
app.use((error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
  console.error("Unhandled error:", error);
  if (response.headersSent) {
    return;
  }
  response.status(500).json({ message: "Internal server error." });
});

startOtpAutoRenewalJob();

export default app;
