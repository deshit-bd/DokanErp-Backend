"use client";

import { useState, type ReactNode } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  { label: "Dashboard", href: "/super-admin/dashboard", icon: "home" },
  { label: "Inventory Management", href: "/super-admin/inventory", icon: "box" },
  {
    label: "Master Data",
    href: "/super-admin/master-data",
    icon: "database",
    children: [
      { label: "Master Data Dashboard", href: "/super-admin/master-data" },
      { label: "Product Category", href: "/super-admin/master-data/product-category" },
      { label: "Product Catalog", href: "/super-admin/master-data/product-catalog" },
      { label: "Brand", href: "/super-admin/master-data/brand" },
      { label: "Unit", href: "/super-admin/master-data/unit" },
      { label: "Barcode Database", href: "/super-admin/master-data/barcode-database" },
      { label: "Import / Export", href: "/super-admin/master-data/import-export" },
      { label: "Money Box", href: "/super-admin/master-data/money-box" },
      { label: "Supplier Data", href: "/super-admin/master-data/supplier-data" },
      { label: "Bank Account", href: "/super-admin/master-data/bank-account" },
      { label: "Product Template", href: "/super-admin/master-data/product-template" },
    ],
  },
  { label: "Subscription & Plans", href: "/super-admin/subscriptions", icon: "card" },
  { label: "User Management", href: "/super-admin/users", icon: "users" },
  {
    label: "Reports & Analytics",
    href: "/super-admin/reports",
    icon: "chart",
    children: [
      { label: "Reports Dashboard", href: "/super-admin/reports" },
      { label: "Purchase Report", href: "/super-admin/reports/purchase-report" },
    ],
  },
  { label: "Sales Management", href: "/super-admin/sales", icon: "cart" },
  { label: "System Settings", href: "/super-admin/settings", icon: "settings" },
  { label: "Support Center", href: "/super-admin/support", icon: "headset" },
];

const routeLabels: Record<string, string> = {
  dashboard: "Dashboard",
  inventory: "Inventory Management",
  "master-data": "Master Data Dashboard",
  "product-category": "Product Category",
  "product-catalog": "Product Catalog",
  brand: "Brand",
  unit: "Unit",
  "barcode-database": "Barcode Database",
  "import-export": "Import / Export",
  "money-box": "Money Box",
  "supplier-data": "Supplier Data",
  "bank-account": "Bank Account",
  "product-template": "Product Template",
  subscriptions: "Subscription & Plans",
  users: "User Management",
  reports: "Reports & Analytics",
  "purchase-report": "Purchase Report",
  sales: "Sales Management",
  settings: "System Settings",
  support: "Support Center",
  general: "General Settings",
  "payment-gateway": "Payment Gateway Settings",
  subscription: "Subscription Settings",
  "sms-otp": "SMS & OTP Settings",
  notifications: "Notification Settings",
  "feature-toggle": "Feature Toggle Settings",
  "inventory-rules": "Inventory Rule Settings",
  security: "Security Settings",
  backup: "Backup Settings",
  theme: "Theme Settings",
  pin: "Pin Settings",
  branding: "Branding Settings",
  "subscription-rules": "Subscription Rule Settings",
  "roles-permissions": "Role & Permission Settings",
  language: "System Language Settings",
  "tax-vat": "Tax & VAT Settings",
  "activity-log": "Activity Log Settings",
  "shop-registration": "Shop Registration Setting",
};

function formatSegment(segment: string) {
  return routeLabels[segment] ?? segment.replace(/-/g, " ").replace(/\b\w/g, (char) => char.toUpperCase());
}

function formatBreadcrumbSegment(segment: string, index: number, total: number) {
  if (segment === "master-data-parent") {
    return "Master Data";
  }

  if (segment === "master-data") {
    return index === total - 1 ? "Master Data Dashboard" : "Master Data";
  }

  return formatSegment(segment);
}

function SidebarIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "home":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4 10.5 12 4l8 6.5" />
          <path {...commonProps} d="M6.5 9.5V20h11V9.5" />
          <path {...commonProps} d="M10 20v-5h4v5" />
        </svg>
      );
    case "box":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" />
          <path {...commonProps} d="M12 12 4 7.5" />
          <path {...commonProps} d="M12 12l8-4.5" />
          <path {...commonProps} d="M12 12v9" />
        </svg>
      );
    case "card":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="4" y="3.5" width="16" height="17" rx="2.5" />
          <path {...commonProps} d="M8 8.5h8" />
          <path {...commonProps} d="M8 12h8" />
          <path {...commonProps} d="M8 15.5h5" />
        </svg>
      );
    case "database":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <ellipse {...commonProps} cx="12" cy="6.5" rx="6.5" ry="2.8" />
          <path {...commonProps} d="M5.5 6.5v5c0 1.5 2.9 2.8 6.5 2.8s6.5-1.3 6.5-2.8v-5" />
          <path {...commonProps} d="M5.5 11.5v5c0 1.5 2.9 2.8 6.5 2.8s6.5-1.3 6.5-2.8v-5" />
        </svg>
      );
    case "users":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M15.5 9.5a2.5 2.5 0 1 0 0-5" />
          <path {...commonProps} d="M4.5 19a4.5 4.5 0 0 1 9 0" />
          <path {...commonProps} d="M14 17a3.5 3.5 0 0 1 5.5-2.8" />
        </svg>
      );
    case "chart":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 20V10" />
          <path {...commonProps} d="M12 20V5" />
          <path {...commonProps} d="M19 20v-8" />
          <path {...commonProps} d="M3.5 20h17" />
        </svg>
      );
    case "cart":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4 5h2l2 9h9l2-7H7.5" />
          <circle {...commonProps} cx="10" cy="18.5" r="1.3" />
          <circle {...commonProps} cx="17" cy="18.5" r="1.3" />
        </svg>
      );
    case "settings":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path
            {...commonProps}
            d="M12 8.5A3.5 3.5 0 1 1 8.5 12 3.5 3.5 0 0 1 12 8.5Z"
          />
          <path
            {...commonProps}
            d="M19 12a7.6 7.6 0 0 0-.1-1l2-1.5-2-3.5-2.4 1a7.4 7.4 0 0 0-1.7-1l-.3-2.6h-4l-.3 2.6a7.4 7.4 0 0 0-1.7 1l-2.4-1-2 3.5 2 1.5a7.6 7.6 0 0 0 0 2l-2 1.5 2 3.5 2.4-1a7.4 7.4 0 0 0 1.7 1l.3 2.6h4l.3-2.6a7.4 7.4 0 0 0 1.7-1l2.4 1 2-3.5-2-1.5c.1-.3.1-.7.1-1Z"
          />
        </svg>
      );
    default:
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 4a8 8 0 1 0 8 8 8 8 0 0 0-8-8Z" />
          <path {...commonProps} d="M12 8v4l2.5 2.5" />
        </svg>
      );
  }
}

function ChevronRight() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="m9 6 6 6-6 6" />
    </svg>
  );
}

function BellIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="M12 5a4 4 0 0 0-4 4v2.7c0 .7-.2 1.4-.6 2l-1 1.5h11.2l-1-1.5c-.4-.6-.6-1.3-.6-2V9a4 4 0 0 0-4-4Z" />
      <path d="M10 18a2 2 0 0 0 4 0" />
    </svg>
  );
}

export default function SuperAdminShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const [isMasterDataOpen, setIsMasterDataOpen] = useState(false);
  const [isReportsOpen, setIsReportsOpen] = useState(false);
  const pathSegments = pathname.split("/").filter(Boolean).slice(1);
  const contentSegments = pathSegments.filter((segment) => segment !== "dashboard");
  const breadcrumbSegments =
    contentSegments.length === 1 && contentSegments[0] === "master-data"
      ? ["master-data-parent", "master-data"]
      : contentSegments;
  const pageTitle = formatSegment(contentSegments[contentSegments.length - 1] ?? "dashboard");

  return (
    <div className="admin-shell">
      <aside className="admin-sidebar">
        <div className="admin-sidebar-brand">
          <div className="admin-sidebar-brand-mark">M</div>
          <div>
            <strong>Mudi ERP</strong>
            <span>Admin Panel</span>
          </div>
        </div>

        <nav className="admin-sidebar-nav" aria-label="Super admin navigation">
          {navItems.map((item) => {
            if (item.children) {
              const isActive =
                pathname === item.href || item.children.some((child) => pathname === child.href || pathname.startsWith(`${child.href}/`));
              const isOpen = item.href === "/super-admin/master-data" ? isMasterDataOpen : isReportsOpen;
              const toggleGroup =
                item.href === "/super-admin/master-data"
                  ? () => setIsMasterDataOpen((current) => !current)
                  : () => setIsReportsOpen((current) => !current);

              return (
                <div className="admin-sidebar-group" key={item.label}>
                  <button
                    type="button"
                    className={`admin-sidebar-link admin-sidebar-link-group${isActive ? " admin-sidebar-link-active" : ""}`}
                    onClick={toggleGroup}
                    aria-expanded={isOpen}
                  >
                    <span className="admin-sidebar-link-icon">
                      <SidebarIcon type={item.icon} />
                    </span>
                    <span className="admin-sidebar-link-text">{item.label}</span>
                    <span
                      className={`admin-sidebar-link-arrow admin-sidebar-link-arrow-open${
                        isOpen ? " admin-sidebar-link-arrow-expanded" : ""
                      }`}
                    >
                      <ChevronRight />
                    </span>
                  </button>

                  {isOpen ? (
                    <div className="admin-sidebar-subnav">
                      {item.children.map((child) => {
                        const isChildActive =
                          child.href === item.href
                            ? pathname === child.href
                            : pathname === child.href || pathname.startsWith(`${child.href}/`);

                        return (
                          <Link
                            className={`admin-sidebar-sublink${isChildActive ? " admin-sidebar-sublink-active" : ""}`}
                            href={child.href}
                            key={child.href}
                          >
                            {child.label}
                          </Link>
                        );
                      })}
                    </div>
                  ) : null}
                </div>
              );
            }

            const isActive = pathname === item.href || pathname.startsWith(`${item.href}/`);

            return (
              <Link
                className={`admin-sidebar-link${isActive ? " admin-sidebar-link-active" : ""}`}
                href={item.href}
                key={item.label}
              >
                <span className="admin-sidebar-link-icon">
                  <SidebarIcon type={item.icon} />
                </span>
                <span className="admin-sidebar-link-text">{item.label}</span>
                <span className="admin-sidebar-link-arrow">+</span>
              </Link>
            );
          })}
        </nav>

        <div className="admin-sidebar-support">
          <div className="admin-sidebar-support-icon">
            <SidebarIcon type="headset" />
          </div>
          <strong>Need support?</strong>
          <p>Contact our support team anytime.</p>
          <button type="button">Support Chat</button>
        </div>
      </aside>

      <main className="admin-main">
        <header className="admin-topbar">
          <div className="admin-topbar-copy">
            <h1>{pageTitle}</h1>
            <div className="admin-breadcrumb">
              {breadcrumbSegments.map((segment, index) => {
                const href =
                  segment === "master-data-parent" ? "/super-admin/master-data" : `/super-admin/${contentSegments.slice(0, index + 1).join("/")}`;
                const isLast = index === breadcrumbSegments.length - 1;

                return (
                  <span className="admin-breadcrumb-group" key={href}>
                    {index > 0 ? (
                      <span className="admin-breadcrumb-separator">
                        <ChevronRight />
                      </span>
                    ) : null}
                    {isLast ? (
                      <span>{formatBreadcrumbSegment(segment, index, breadcrumbSegments.length)}</span>
                    ) : (
                      <Link href={href}>{formatBreadcrumbSegment(segment, index, breadcrumbSegments.length)}</Link>
                    )}
                  </span>
                );
              })}
            </div>
          </div>

          <div className="admin-topbar-actions">
            <div className="admin-date-chip">1 may 2024 - 31 may 2024</div>

            <button className="admin-icon-button" type="button" aria-label="Notifications">
              <BellIcon />
              <span className="admin-icon-badge">12</span>
            </button>

            <button className="admin-profile-chip" type="button">
              <div className="admin-profile-avatar">S</div>
              <div className="admin-profile-copy">
                <strong>Super Admin</strong>
                <span>admin@mudierp.com</span>
              </div>
              <span className="admin-profile-caret">
                <ChevronRight />
              </span>
            </button>
          </div>
        </header>

        {children}
      </main>
    </div>
  );
}
