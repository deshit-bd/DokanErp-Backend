import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "DokanERP",
  description: "Retail ERP for shops, staff, and super admins",
};

type RootLayoutProps = Readonly<{
  children: React.ReactNode;
}>;

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body suppressHydrationWarning>{children}</body>
    </html>
  );
}
