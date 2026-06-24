import cors from "cors";
import express from "express";
import path from "node:path";
import { AppType } from "@prisma/client";

import { getAuthenticatedUser, isAuthError, sendAuthError } from "./auth/current-user";
import { startOtpAutoRenewalJob } from "./auth/otp-renewal";
import authRoutes from "./routes/auth";
import bankAccountRoutes from "./routes/bank-accounts";
import brandRoutes from "./routes/brands";
import categoryRoutes from "./routes/categories";
import customerRoutes from "./routes/customers";
import expenseRoutes from "./routes/expenses";
import inventoryRoutes from "./routes/inventory";
import moneyBoxRoutes from "./routes/money-boxes";
import productRoutes from "./routes/products";
import productTemplateRoutes from "./routes/product-templates";
import purchaseRoutes from "./routes/purchases";
import shopRoutes from "./routes/shops";
import subscriptionRoutes from "./routes/subscriptions";
import supplierRoutes from "./routes/suppliers";
import unitRoutes from "./routes/units";
import reportsRoutes from "./routes/reports";
import staffRoutes from "./routes/staff";
import notificationRoutes from "./routes/notifications";
import settingsRoutes from "./routes/settings";
import { evaluateSalesmanTrialAccess, evaluateShopSubscriptionAccess } from "./subscription/access";

const app = express();

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

  scopedRouter.use("/auth", authRoutes);
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
  scopedRouter.use("/reports", reportsRoutes);
  scopedRouter.use("/notifications", notificationRoutes);
  scopedRouter.use("/settings", settingsRoutes);

  app.use(prefix, scopedRouter);
}

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.resolve(process.cwd(), "uploads")));

app.get("/health", (_request, response) => {
  response.json({
    service: "mudi-erp-api",
    status: "ok",
  });
});

mountApiScope("/web/api", AppType.WEB);
mountApiScope("/app/api", AppType.MOBILE);

startOtpAutoRenewalJob();

export default app;
