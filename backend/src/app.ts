import cors from "cors";
import express from "express";
import path from "node:path";
import { AppType } from "@prisma/client";

import { startOtpAutoRenewalJob } from "./auth/otp-renewal";
import authRoutes from "./routes/auth";
import bankAccountRoutes from "./routes/bank-accounts";
import brandRoutes from "./routes/brands";
import categoryRoutes from "./routes/categories";
import moneyBoxRoutes from "./routes/money-boxes";
import productRoutes from "./routes/products";
import productTemplateRoutes from "./routes/product-templates";
import purchaseRoutes from "./routes/purchases";
import shopRoutes from "./routes/shops";
import supplierRoutes from "./routes/suppliers";
import unitRoutes from "./routes/units";

const app = express();

function mountApiScope(prefix: string, appType: AppType) {
  const scopedRouter = express.Router();

  scopedRouter.use((request, _response, next) => {
    (request as express.Request & { apiClientAppType?: AppType }).apiClientAppType = appType;
    next();
  });

  scopedRouter.use("/auth", authRoutes);
  scopedRouter.use("/bank-accounts", bankAccountRoutes);
  scopedRouter.use("/brands", brandRoutes);
  scopedRouter.use("/categories", categoryRoutes);
  scopedRouter.use("/money-boxes", moneyBoxRoutes);
  scopedRouter.use("/products", productRoutes);
  scopedRouter.use("/product-templates", productTemplateRoutes);
  scopedRouter.use("/purchases", purchaseRoutes);
  scopedRouter.use("/shops", shopRoutes);
  scopedRouter.use("/suppliers", supplierRoutes);
  scopedRouter.use("/add-suppliers", supplierRoutes);
  scopedRouter.use("/units", unitRoutes);

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
