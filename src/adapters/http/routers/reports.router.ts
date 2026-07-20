import { Router } from "express";

import { reportsController } from "../controllers/reports.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/dashboard", asyncHandler(reportsController.getDashboard));
router.get("/sales/daily", asyncHandler(reportsController.getDailySales));
router.get("/purchases/summary", asyncHandler(reportsController.getPurchaseSummary));
router.get("/dues/summary", asyncHandler(reportsController.getDuesSummary));
router.get("/expenses/summary", asyncHandler(reportsController.getExpenseSummary));
router.get("/profit-loss", asyncHandler(reportsController.getProfitLoss));
router.get("/stock-value", asyncHandler(reportsController.getStockValue));

export default router;
