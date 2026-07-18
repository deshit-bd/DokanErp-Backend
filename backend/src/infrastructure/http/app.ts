import cors from "cors";
import express from "express";
import helmet from "helmet";
import rateLimit from "express-rate-limit";
import path from "node:path";
import { AppType } from "@prisma/client";

import { env } from "../../config/env";

import { errorHandlerMiddleware } from "../../adapters/http/middleware/error-handler.middleware";
import { getAuthenticatedUser, isAuthError, sendAuthError } from "../../auth/current-user";
import authRoutes from "../../adapters/http/routers/auth.router";
import bankAccountRoutes from "../../adapters/http/routers/bank-account.router";
import brandRoutes from "../../adapters/http/routers/brand.router";
import categoryRoutes from "../../adapters/http/routers/category.router";
import customerRoutes from "../../adapters/http/routers/customer.router";
import { handleGetConfirmDue, handlePostConfirmDue } from "../../adapters/http/controllers/customer.controller";
import expenseRoutes from "../../adapters/http/routers/expense.router";
import inventoryRoutes from "../../adapters/http/routers/inventory.router";
import moneyBoxRoutes from "../../adapters/http/routers/money-box.router";
import productRoutes from "../../adapters/http/routers/product.router";
import productTemplateRoutes from "../../adapters/http/routers/product-template.router";
import purchaseRoutes from "../../adapters/http/routers/purchase.router";
import shopRoutes from "../../adapters/http/routers/shop-profile.router";
import subscriptionRoutes from "../../adapters/http/routers/subscription-billing.router";
import supplierRoutes from "../../adapters/http/routers/supplier.router";
import { handleGetConfirmSupplierDue, handlePostConfirmSupplierDue } from "../../adapters/http/controllers/supplier.controller";
import unitRoutes from "../../adapters/http/routers/unit.router";
import reportsRoutes from "../../adapters/http/routers/reports.router";
import staffRoutes from "../../adapters/http/routers/staff.router";
import notificationRoutes from "../../adapters/http/routers/notification.router";
import settingsRoutes from "../../routes/settings";
import { evaluateSalesmanTrialAccess, evaluateShopSubscriptionAccess } from "../../subscription/access";

const app = express();
app.set("trust proxy", true);

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
      if (request.path.startsWith("/auth") || request.path.startsWith("/subscriptions") || request.path.startsWith("/debug-error")) {
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

  scopedRouter.post("/debug-error", (request, response) => {
    console.error("=================== CLIENT EXCEPTION ===================");
    console.error("Message:", request.body.message);
    console.error("Stacktrace:", request.body.stacktrace);
    console.error("========================================================");
    return response.json({ ok: true });
  });

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

// Some hosting layers in front of this API reject the verbs PUT/PATCH/DELETE
// outright. The clients therefore send those requests as POST carrying an
// `X-HTTP-Method-Override` header; restore the real verb here, before routing,
// so every existing route keeps working unchanged.
app.use((request, _response, next) => {
  const override = request.headers["x-http-method-override"];
  if (request.method === "POST" && typeof override === "string") {
    const verb = override.toUpperCase();
    if (verb === "PUT" || verb === "PATCH" || verb === "DELETE") {
      request.method = verb;
    }
  }
  next();
});

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

// Central error handler: maps thrown AppError subclasses (migrated modules)
// to their status code, and never leaks stack traces for anything else
// (legacy routes still send their own responses directly and rarely reach
// this handler, same as before the migration).
app.use(errorHandlerMiddleware);

export default app;
