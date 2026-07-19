import { Router } from "express";

import { subscriptionBillingController } from "../controllers/subscription-billing.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/", asyncHandler(subscriptionBillingController.getAdminView));
router.get("/me", asyncHandler(subscriptionBillingController.getOwn));
router.post("/payments", asyncHandler(subscriptionBillingController.recordPayment));

export default router;
