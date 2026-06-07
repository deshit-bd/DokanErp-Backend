import cors from "cors";
import express from "express";
import path from "node:path";

import authRoutes from "./routes/auth";
import brandRoutes from "./routes/brands";
import categoryRoutes from "./routes/categories";
import productRoutes from "./routes/products";
import unitRoutes from "./routes/units";

const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static(path.resolve(process.cwd(), "uploads")));

app.get("/health", (_request, response) => {
  response.json({
    service: "mudi-erp-api",
    status: "ok",
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/brands", brandRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/products", productRoutes);
app.use("/api/units", unitRoutes);

export default app;
