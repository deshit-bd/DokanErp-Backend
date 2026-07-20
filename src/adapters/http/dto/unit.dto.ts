import { UnitStatus, UnitType } from "@prisma/client";
import { z } from "zod";

export const CreateUnitDto = z.object({
  name: z.string().optional(),
  shortName: z.string().optional(),
  type: z.enum(UnitType).optional(),
  description: z.string().nullish(),
  status: z.enum(UnitStatus).optional(),
});

export const UpdateUnitDto = CreateUnitDto;
