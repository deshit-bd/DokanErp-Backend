import type { UnitOfWork, TxClient } from "@application/shared/unit-of-work.port";

import { prisma } from "../../../infrastructure/prisma/client";

export class PrismaUnitOfWork implements UnitOfWork {
  run<T>(fn: (tx: TxClient) => Promise<T>): Promise<T> {
    return prisma.$transaction((tx) => fn(tx));
  }
}
