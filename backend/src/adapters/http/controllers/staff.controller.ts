import type { Request, Response } from "express";

import { GetSalesmanOwnPerformanceUseCase } from "@application/staff/use-cases/get-salesman-own-performance.use-case";
import { GetStaffMemberUseCase } from "@application/staff/use-cases/get-staff-member.use-case";
import { ListStaffUseCase } from "@application/staff/use-cases/list-staff.use-case";
import { ResetStaffPinUseCase } from "@application/staff/use-cases/reset-staff-pin.use-case";
import { ResolveOwnerShopContextUseCase } from "@application/staff/use-cases/resolve-owner-shop-context.use-case";
import { UpdateStaffPermissionsUseCase } from "@application/staff/use-cases/update-staff-permissions.use-case";
import { UpdateStaffStatusUseCase } from "@application/staff/use-cases/update-staff-status.use-case";

import { PrismaStaffRepository } from "../../persistence/prisma/staff.repository";

const staffRepository = new PrismaStaffRepository();
const resolveOwnerShopContextUseCase = new ResolveOwnerShopContextUseCase(staffRepository);
const getSalesmanOwnPerformanceUseCase = new GetSalesmanOwnPerformanceUseCase(staffRepository);
const listStaffUseCase = new ListStaffUseCase(staffRepository);
const getStaffMemberUseCase = new GetStaffMemberUseCase(staffRepository);
const updateStaffPermissionsUseCase = new UpdateStaffPermissionsUseCase(staffRepository);
const resetStaffPinUseCase = new ResetStaffPinUseCase(staffRepository);
const updateStaffStatusUseCase = new UpdateStaffStatusUseCase(staffRepository);

async function requireOwnerShop(request: Request) {
  const context = request.context!;
  return resolveOwnerShopContextUseCase.execute({ appType: context.appType, role: context.role, shopId: context.shopId, userId: context.userId });
}

export const staffController = {
  async getOwnPerformance(request: Request, response: Response) {
    const context = request.context!;
    const result = await getSalesmanOwnPerformanceUseCase.execute(context.shopId, context.userId);
    response.json(result);
  },

  async list(request: Request, response: Response) {
    const shop = await requireOwnerShop(request);
    const result = await listStaffUseCase.execute(shop.id);
    response.json({ shop: { id: shop.id, shopCode: shop.shopCode, shopName: shop.shopName }, ...result });
  },

  async getOne(request: Request, response: Response) {
    const shop = await requireOwnerShop(request);
    const result = await getStaffMemberUseCase.execute(shop.id, String(request.params.staffUserId ?? ""));
    response.json(result);
  },

  async updatePermissions(request: Request, response: Response) {
    const shop = await requireOwnerShop(request);
    const staff = await updateStaffPermissionsUseCase.execute(shop.id, String(request.params.staffUserId ?? ""), request.body ?? {});
    response.json({ message: "Staff permissions updated successfully.", staff });
  },

  async resetPin(request: Request, response: Response) {
    const shop = await requireOwnerShop(request);
    await resetStaffPinUseCase.execute(shop.id, String(request.params.staffUserId ?? ""));
    response.json({ message: "PIN reset has been requested. The salesman must set a new PIN on next PIN flow." });
  },

  async updateStatus(request: Request, response: Response) {
    const shop = await requireOwnerShop(request);
    const body = request.body as { status?: string };
    const result = await updateStaffStatusUseCase.execute(shop.id, String(request.params.staffUserId ?? ""), body.status);
    response.json({ message: `Staff account ${result.staff.isActive ? "activated" : "deactivated"} successfully.`, ...result });
  },
};
