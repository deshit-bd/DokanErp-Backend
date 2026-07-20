import { BrandStatus } from "@prisma/client";
import { z } from "zod";

export const CreateBrandDto = z.object({
  name: z.string().optional(),
  description: z.string().nullish(),
  logoUrl: z.string().nullish(),
  status: z.enum(BrandStatus).optional(),
});

export const UpdateBrandDto = CreateBrandDto;

// `ids` is intentionally left as `unknown` here (not `z.array(z.string())`):
// the original endpoint's own Array.isArray check produces a specific
// "Invalid or empty brand IDs." message for any malformed input, which a
// strict zod array schema would instead reject with a generic validation
// error before the use case ever runs.
export const BulkDeleteBrandsDto = z.object({
  ids: z.unknown().optional(),
});
