import type { ReactNode } from "react";

import SuperAdminShellClient from "@/client/super-admin/super-admin-shell-client";

export default function SuperAdminShell({ children }: { children: ReactNode }) {
  return <SuperAdminShellClient>{children}</SuperAdminShellClient>;
}
