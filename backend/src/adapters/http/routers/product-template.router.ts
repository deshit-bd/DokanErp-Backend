import { Router } from "express";

import { productTemplateController } from "../controllers/product-template.controller";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware, requireRole } from "../middleware/auth.middleware";

const router = Router();

router.use(authMiddleware, requireRole("SUPER_ADMIN", "ADMIN"));

router.get("/", asyncHandler(productTemplateController.list));
router.post("/", asyncHandler(productTemplateController.create));
router.put("/:id", asyncHandler(productTemplateController.update));
router.delete("/:id", asyncHandler(productTemplateController.remove));
router.put("/:id/products", asyncHandler(productTemplateController.setProducts));
router.delete("/:id/products/:productId", asyncHandler(productTemplateController.removeProduct));

export default router;
