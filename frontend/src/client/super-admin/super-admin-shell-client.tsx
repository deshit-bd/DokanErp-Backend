"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

const ACCESS_TOKEN_REFRESH_INTERVAL_MS = 12 * 60 * 1000;

const navItems = [
  { label: "Dashboard", href: "/super-admin/dashboard", icon: "home" },
  {
    label: "Shop Management",
    href: "/super-admin/shop-management",
    icon: "shop",
    children: [
      { label: "Shops", href: "/super-admin/shop-management/shops" },
      { label: "Accounts", href: "/super-admin/shop-management/accounts" },
      { label: "Subscriptions", href: "/super-admin/shop-management/subscriptions" },
    ],
  },
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
  {
    label: "Reports & Analytics",
    href: "/super-admin/reports",
    icon: "chart",
    children: [
      { label: "Sales Report", href: "/super-admin/reports/sales-report" },
      { label: "Purchase Report", href: "/super-admin/reports/purchase-report" },
      { label: "Profit & Loss Report", href: "/super-admin/reports/profit-loss-report" },
    ],
  },
  { label: "Setting", href: "/super-admin/settings", icon: "settings" },
];

const routeLabels: Record<string, string> = {
  dashboard: "Dashboard",
  "shop-management": "Shop Management",
  shops: "Shops",
  accounts: "Accounts",
  subscriptions: "Subscription & Plans",
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
  profile: "My Profile",
  users: "User Management",
  reports: "Reports & Analytics",
  "sales-report": "Sales Report",
  "purchase-report": "Purchase Report",
  "profit-loss-report": "Profit & Loss Report",
  sales: "Sales Management",
  settings: "Setting",
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
  "system-setting": "System Setting",
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
    case "shop":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M4 9h16" />
          <path {...commonProps} d="M5.5 9V19h13V9" />
          <path {...commonProps} d="M4.5 9 6.5 5h11l2 4" />
          <path {...commonProps} d="M9 19v-5h6v5" />
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

export default function SuperAdminShellClient({ children }: { children: ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const refreshInFlightRef = useRef(false);
  const lastRefreshAtRef = useRef(Date.now());
  const [isShopManagementOpen, setIsShopManagementOpen] = useState(false);
  const [isMasterDataOpen, setIsMasterDataOpen] = useState(false);
  const [isReportsOpen, setIsReportsOpen] = useState(false);
  const [isProfileMenuOpen, setIsProfileMenuOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  const [profileName, setProfileName] = useState("Super Admin");
  const [profileEmail, setProfileEmail] = useState("superadmin@dokanerp.local");
  const [profileRole, setProfileRole] = useState("SUPER_ADMIN");
  const [profileImageUrl, setProfileImageUrl] = useState("");
  const pathSegments = pathname.split("/").filter(Boolean).slice(1);
  const rawContentSegments = pathSegments.filter((segment) => segment !== "dashboard");
  const contentSegments =
    rawContentSegments.includes("settings") && rawContentSegments[0] === "master-data"
      ? rawContentSegments.filter((segment, index) => !(index === 0 && segment === "master-data"))
      : rawContentSegments;
  const breadcrumbSegments =
    contentSegments.length === 1 && contentSegments[0] === "master-data"
      ? ["master-data-parent", "master-data"]
      : contentSegments;
  const pageTitle = formatSegment(contentSegments[contentSegments.length - 1] ?? "dashboard");
  const profileInitial = (profileName.trim()[0] ?? "S").toUpperCase();

  async function refreshSession(options?: { redirectOnFailure?: boolean }) {
    if (refreshInFlightRef.current) {
      return true;
    }

    refreshInFlightRef.current = true;

    try {
      const response = await fetch("/api/auth/refresh", {
        method: "POST",
        cache: "no-store",
      });

      if (!response.ok) {
        if (options?.redirectOnFailure) {
          router.push("/login");
          router.refresh();
        }

        return false;
      }

      lastRefreshAtRef.current = Date.now();
      return true;
    } catch {
      if (options?.redirectOnFailure) {
        router.push("/login");
        router.refresh();
      }

      return false;
    } finally {
      refreshInFlightRef.current = false;
    }
  }

  useEffect(() => {
    let isMounted = true;

    async function loadProfile() {
      try {
        const response = await fetch("/api/auth/me", {
          method: "GET",
          cache: "no-store",
        });

        if (!response.ok) {
          return;
        }

        const result = (await response.json()) as {
          user?: {
            name?: string;
            email?: string | null;
            phone?: string | null;
            profileImageUrl?: string | null;
          };
          session?: {
            role?: string;
          };
        };

        if (!isMounted || !result.user) {
          return;
        }

        setProfileName(result.user.name || "Super Admin");
        setProfileEmail(result.user.email || result.user.phone || "No contact info");
        setProfileRole(result.session?.role || "SUPER_ADMIN");
        setProfileImageUrl(result.user.profileImageUrl || "");
      } catch {
        // Keep fallback profile values if the session endpoint is unavailable.
      }
    }

    void loadProfile();

    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    const intervalId = window.setInterval(() => {
      void refreshSession();
    }, ACCESS_TOKEN_REFRESH_INTERVAL_MS);

    function handleVisibilityChange() {
      if (document.visibilityState !== "visible") {
        return;
      }

      if (Date.now() - lastRefreshAtRef.current >= ACCESS_TOKEN_REFRESH_INTERVAL_MS) {
        void refreshSession({ redirectOnFailure: true });
      }
    }

    document.addEventListener("visibilitychange", handleVisibilityChange);

    return () => {
      window.clearInterval(intervalId);
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [router]);

  async function handleLogout() {
    setIsLoggingOut(true);

    try {
      await fetch("/api/auth/logout", {
        method: "POST",
      });
    } finally {
      router.push("/login");
      router.refresh();
      setIsLoggingOut(false);
    }
  }

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
              const isOpen =
                item.href === "/super-admin/shop-management"
                  ? isShopManagementOpen
                  : item.href === "/super-admin/master-data"
                    ? isMasterDataOpen
                    : isReportsOpen;
              const toggleGroup =
                item.href === "/super-admin/shop-management"
                  ? () => setIsShopManagementOpen((current) => !current)
                  : item.href === "/super-admin/master-data"
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
                  <span className="admin-breadcrumb-group" key={`${href}-${segment}-${index}`}>
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
            <button className="admin-icon-button" type="button" aria-label="Notifications">
              <BellIcon />
              <span className="admin-icon-badge">12</span>
            </button>

            <div className="admin-profile-menu">
              <button
                className="admin-profile-chip"
                type="button"
                aria-haspopup="menu"
                aria-expanded={isProfileMenuOpen}
                onClick={() => setIsProfileMenuOpen((current) => !current)}
              >
                <div className="admin-profile-avatar">
                  {profileImageUrl ? <img src={profileImageUrl} alt={profileName} /> : profileInitial}
                </div>
                <div className="admin-profile-copy">
                  <strong>{profileName}</strong>
                  <span>{profileEmail}</span>
                </div>
                <span className={`admin-profile-caret${isProfileMenuOpen ? " admin-profile-caret-open" : ""}`}>
                  <ChevronRight />
                </span>
              </button>

              {isProfileMenuOpen ? (
                <div className="admin-profile-dropdown" role="menu">
                  <div className="admin-profile-dropdown-copy">
                    <strong>{profileName}</strong>
                    <span>{profileRole.replace(/_/g, " ")}</span>
                  </div>
                  <Link
                    className="admin-profile-dropdown-item"
                    href="/super-admin/profile"
                    role="menuitem"
                    onClick={() => setIsProfileMenuOpen(false)}
                  >
                    My Profile
                  </Link>
                  <button
                    type="button"
                    className="admin-profile-dropdown-item"
                    role="menuitem"
                    onClick={() => {
                      setIsProfileMenuOpen(false);
                      void handleLogout();
                    }}
                  >
                    {isLoggingOut ? "Logging out..." : "Logout"}
                  </button>
                </div>
              ) : null}
            </div>
          </div>
        </header>

        {children}
      </main>
    </div>
  );
}
