import { Router } from "express";

import { categoryController } from "../controllers/category.controller";
import { CreateCategoryDto, ImportCategoriesDto, UpdateCategoryDto } from "../dto/category.dto";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware, requireRole } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate-request.middleware";

const router = Router();

const requireCategoryManager = requireRole("SUPER_ADMIN", "ADMIN", "SHOP_OWNER");
const requireAdmin = requireRole("SUPER_ADMIN", "ADMIN");

router.use(authMiddleware);

router.get("/", requireCategoryManager, asyncHandler(categoryController.list));
router.post("/", requireCategoryManager, validate({ body: CreateCategoryDto }), asyncHandler(categoryController.create));
router.post("/import", requireAdmin, validate({ body: ImportCategoriesDto }), asyncHandler(categoryController.import));
router.patch("/:id", requireCategoryManager, validate({ body: UpdateCategoryDto }), asyncHandler(categoryController.update));
router.delete("/:id", requireCategoryManager, asyncHandler(categoryController.archiveOrDelete));
router.post("/:id/approve", requireAdmin, asyncHandler(categoryController.approve));

export default router;
