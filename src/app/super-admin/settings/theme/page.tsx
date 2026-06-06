import { redirect } from "next/navigation";

export default function ThemeSettingsRedirectPage() {
  redirect("/super-admin/settings/system-setting");
}
