import Link from "next/link";

const settingGroups = [
  {
    title: "General Settings",
    description: "Manage system name, logo, language, timezone, currency, & general setup.",
    accent: "blue",
    icon: "gear",
    href: "/super-admin/settings/general",
  },
  {
    title: "Payment Gateway Settings",
    description: "Set up bKash, Nagad, Rocket, SSLCommerz, card & other payment methods.",
    accent: "red",
    icon: "wallet",
    href: "/super-admin/settings/payment-gateway",
  },
  {
    title: "Subscription Settings",
    description: "Manage feature plans, pricing, trials, expiry, grace period & late fee settings.",
    accent: "green",
    icon: "crown",
    href: "/super-admin/settings/subscription",
  },
  {
    title: "SMS & OTP Settings",
    description: "Manage SMS provider, API key, sender ID & OTP configuration settings.",
    accent: "indigo",
    icon: "message",
    href: "/super-admin/settings/sms-otp",
  },
  {
    title: "Notification Settings",
    description: "Configure various notifications, email alerts & user alert preferences.",
    accent: "orange",
    icon: "bell",
    href: "/super-admin/settings/notifications",
  },
  {
    title: "Feature Toggle Settings",
    description: "Turn system features on/off globally and control feature availability.",
    accent: "violet",
    icon: "toggle",
    href: "/super-admin/settings/feature-toggle",
  },
  {
    title: "Inventory Rule Settings",
    description: "Set negative stock, barcode, duplicate product & inventory rules.",
    accent: "cyan",
    icon: "box",
    href: "/super-admin/settings/inventory-rules",
  },
  {
    title: "Security Settings",
    description: "Set up 2FA, login alerts, session timeout & IP restriction rules.",
    accent: "purple",
    icon: "shield",
    href: "/super-admin/settings/security",
  },
  {
    title: "Backup Settings",
    description: "Configure auto backup, cloud backup, database export & restore options.",
    accent: "pink",
    icon: "cloud",
    href: "/super-admin/settings/backup",
  },
  {
    title: "System Setting",
    description: "Change everything here, from colors to fonts and logos, to your liking.",
    accent: "yellow",
    icon: "brush",
    href: "/super-admin/settings/system-setting",
  },
  {
    title: "Pin Settings",
    description: "2FA PIN usage, login security and authorization settings.",
    accent: "lime",
    icon: "lock",
    href: "/super-admin/settings/pin",
  },
  {
    title: "Subscription Rule Settings",
    description: "Set payment cycle, auto-renewal, expiry rules & invoice configurations.",
    accent: "blue",
    icon: "card",
    href: "/super-admin/settings/subscription-rules",
  },
  {
    title: "Role & Permission Settings",
    description: "Manage admin & staff roles, permissions & access control settings.",
    accent: "teal",
    icon: "users",
    href: "/super-admin/settings/roles-permissions",
  },
  {
    title: "Tax & VAT Settings",
    description: "Set tax rate, VAT rate, tax number & specific tax configurations.",
    accent: "indigo",
    icon: "receipt",
    href: "/super-admin/settings/tax-vat",
  },
  {
    title: "Activity Log Settings",
    description: "Configure system logs, user logs, API logs & log retention policy.",
    accent: "orange",
    icon: "clock",
    href: "/super-admin/settings/activity-log",
  },
  {
    title: "Shop Registration Setting",
    description: "Shop Registration Procedure and Verification Requirement Settings.",
    accent: "violet",
    icon: "store",
    href: "/super-admin/settings/shop-registration",
  },
];

function SettingsIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "gear":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 8.7A3.3 3.3 0 1 1 8.7 12 3.3 3.3 0 0 1 12 8.7Z" />
          <path
            {...commonProps}
            d="M19 12a7.3 7.3 0 0 0-.1-.9l1.8-1.4-1.8-3.1-2.2.9a6.5 6.5 0 0 0-1.5-.9L15 4h-6l-.2 2.6a6.5 6.5 0 0 0-1.5.9l-2.2-.9-1.8 3.1 1.8 1.4a7.3 7.3 0 0 0 0 1.8l-1.8 1.4 1.8 3.1 2.2-.9a6.5 6.5 0 0 0 1.5.9L9 20h6l.2-2.6a6.5 6.5 0 0 0 1.5-.9l2.2.9 1.8-3.1-1.8-1.4c.1-.3.1-.6.1-.9Z"
          />
        </svg>
      );
    case "wallet":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 7.5h12.5A1.5 1.5 0 0 1 19 9v8.5A1.5 1.5 0 0 1 17.5 19h-13A1.5 1.5 0 0 1 3 17.5v-9A2.5 2.5 0 0 1 5.5 6H17" />
          <path {...commonProps} d="M16 12.5h5v3h-5a1.5 1.5 0 0 1 0-3Z" />
          <path {...commonProps} d="M17.8 14h.2" />
        </svg>
      );
    case "crown":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="m5 18 1.6-8 5.4 4 5.4-4L19 18H5Z" />
          <path {...commonProps} d="M6.6 10 4 6l4 1 4-3 4 3 4-1-2.6 4" />
        </svg>
      );
    case "message":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 6h14v10H9l-4 3V6Z" />
          <path {...commonProps} d="M8 10h8" />
          <path {...commonProps} d="M8 13h5" />
        </svg>
      );
    case "bell":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 5a4 4 0 0 0-4 4v2.7c0 .7-.2 1.4-.6 2l-1 1.5h11.2l-1-1.5c-.4-.6-.6-1.3-.6-2V9a4 4 0 0 0-4-4Z" />
          <path {...commonProps} d="M10 18a2 2 0 0 0 4 0" />
        </svg>
      );
    case "toggle":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="3" y="7" width="18" height="10" rx="5" />
          <circle {...commonProps} cx="9" cy="12" r="3" />
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
    case "shield":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z" />
          <path {...commonProps} d="M10 12.5 11.5 14 14.5 10.5" />
        </svg>
      );
    case "cloud":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M7 18h10a4 4 0 0 0 .6-8A5.5 5.5 0 0 0 7 8.7 3.8 3.8 0 0 0 7 18Z" />
          <path {...commonProps} d="M12 10v7" />
          <path {...commonProps} d="m9.5 14.5 2.5 2.5 2.5-2.5" />
        </svg>
      );
    case "brush":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="m14 4 6 6" />
          <path {...commonProps} d="m12.5 5.5 6 6L10 20H4v-6l8.5-8.5Z" />
        </svg>
      );
    case "lock":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="5" y="11" width="14" height="10" rx="2" />
          <path {...commonProps} d="M8 11V8a4 4 0 0 1 8 0v3" />
        </svg>
      );
    case "tag":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M20 10 12 18 4 10l6-6h6l4 4Z" />
          <path {...commonProps} d="M14 8h.01" />
        </svg>
      );
    case "card":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="4" y="5.5" width="16" height="13" rx="2.2" />
          <path {...commonProps} d="M4 10h16" />
          <path {...commonProps} d="M8 14.5h4" />
        </svg>
      );
    case "users":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M15.5 10a2.5 2.5 0 1 0 0-5" />
          <path {...commonProps} d="M4.5 19a4.5 4.5 0 0 1 9 0" />
          <path {...commonProps} d="M14.5 18a3.5 3.5 0 0 1 5-2.3" />
        </svg>
      );
    case "globe":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="M3.8 12h16.4" />
          <path {...commonProps} d="M12 3.5a13 13 0 0 1 0 17" />
          <path {...commonProps} d="M12 3.5a13 13 0 0 0 0 17" />
        </svg>
      );
    case "receipt":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M7 4h10v16l-2-1.5-2 1.5-2-1.5-2 1.5-2-1.5-2 1.5V4Z" />
          <path {...commonProps} d="M9 9h6" />
          <path {...commonProps} d="M9 12.5h6" />
        </svg>
      );
    case "clock":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <circle {...commonProps} cx="12" cy="12" r="8.5" />
          <path {...commonProps} d="M12 8v4l2.5 2" />
        </svg>
      );
    case "store":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M5 9.5h14l-1-4H6l-1 4Z" />
          <path {...commonProps} d="M6 9.5V19h12V9.5" />
          <path {...commonProps} d="M10 19v-4h4v4" />
        </svg>
      );
    default:
      return null;
  }
}

export default function SuperAdminSettingsPage() {
  return (
    <section className="settings-page settings-page-gallery">
      <div className="settings-grid">
        {settingGroups.map((setting) => (
          <article className="settings-card" key={setting.title}>
            <div className={`settings-card-icon settings-card-icon-${setting.accent}`}>
              <SettingsIcon type={setting.icon} />
            </div>
            <div className="settings-card-content">
              <h2>{setting.title}</h2>
              <p>{setting.description}</p>
              <Link href={setting.href}>Configure Settings</Link>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
