import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const backendRoot = path.resolve(scriptDir, "..");

function runStep(step) {
  execFileSync("npm", ["run", step], {
    cwd: backendRoot,
    stdio: "inherit",
  });
}

try {
  runStep("prisma:generate");
  runStep("prisma:push");
  console.log("Prisma client generated and database schema synced before dev startup.");
} catch (error) {
  console.error("Backend dev startup stopped because Prisma schema sync failed.");
  process.exit(error?.status ?? 1);
}
