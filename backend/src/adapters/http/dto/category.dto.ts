import { CategoryStatus } from "@prisma/client";
import { z } from "zod";

export const CreateCategoryDto = z.object({
  name: z.string().optional(),
  description: z.string().nullish(),
  status: z.enum(CategoryStatus).optional(),
});

export const UpdateCategoryDto = CreateCategoryDto;

export const ImportCategoriesDto = z.object({
  categories: z
    .array(
      z.object({
        name: z.string().optional(),
        description: z.string().nullish(),
        status: z.enum(CategoryStatus).optional(),
      }),
    )
    .optional(),
});
