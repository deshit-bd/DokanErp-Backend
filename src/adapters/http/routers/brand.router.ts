import { Router } from "express";

import { brandController } from "../controllers/brand.controller";
import { BulkDeleteBrandsDto, CreateBrandDto, UpdateBrandDto } from "../dto/brand.dto";
import { asyncHandler } from "../middleware/async-handler";
import { authMiddleware, requireRole } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate-request.middleware";

const router = Router();

const requireBrandManager = requireRole("SUPER_ADMIN", "ADMIN");

router.use(authMiddleware, requireBrandManager);

router.get("/", asyncHandler(brandController.list));
router.post("/", validate({ body: CreateBrandDto }), asyncHandler(brandController.create));
router.put("/:id", validate({ body: UpdateBrandDto }), asyncHandler(brandController.update));
router.delete("/", validate({ body: BulkDeleteBrandsDto }), asyncHandler(brandController.bulkRemove));
router.delete("/:id", asyncHandler(brandController.remove));

export default router;
