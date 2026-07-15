// The real PrismaClient singleton now lives in src/infrastructure/prisma/client.ts
// (the only place the raw client may be instantiated, per the Clean Architecture
// migration). This file remains as a re-export so the not-yet-migrated
// src/routes/* files can keep importing "../config/prisma" unchanged until each
// of them is migrated module-by-module; do not add new imports of this path in
// migrated code — import "@infrastructure/prisma/client" directly instead.
export { prisma } from "../infrastructure/prisma/client";
