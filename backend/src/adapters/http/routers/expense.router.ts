import { Router } from "express";

import { expenseController } from "../controllers/expense.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware);

router.get("/summary", asyncHandler(expenseController.summary));
router.get("/", asyncHandler(expenseController.list));
router.post("/", asyncHandler(expenseController.create));
router.patch("/:id", asyncHandler(expenseController.update));
router.delete("/:id", asyncHandler(expenseController.remove));

export default router;
