"use client";

import Link from "next/link";
import { useState } from "react";

const toggleOptions = [
  {
    label: "Multiple language",
    description: "Toggle whether users can switch and use multiple system languages.",
    checked: true,
  },
  {
    label: "Dark mode enable",
    description: "Enable dark mode support across the admin and public views.",
    checked: true,
  },
  {
    label: "Maintenance mode",
    description: "When enabled, users can only access the system in maintenance view.",
    checked: false,
  },
  {
    label: "New registration permission",
    description: "Allow new shops and users to create registration requests.",
    checked: true,
  },
  {
    label: "Email notification",
    description: "Enable email-based notification delivery for system events.",
    checked: true,
  },
];

const paymentGateways = [
  {
    id: "bkash",
    name: "bKash",
    description: "bKash payment gateway integration setup",
    accent: "pink",
    status: "Active",
    enabled: true,
    mark: "bK",
  },
  {
    id: "nagad",
    name: "Nagad",
    description: "Nagad payment gateway integration setup",
    accent: "orange",
    status: "Active",
    enabled: true,
    mark: "N",
  },
  {
    id: "rocket",
    name: "Rocket",
    description: "Rocket payment gateway integration setup",
    accent: "violet",
    status: "Active",
    enabled: true,
    mark: "R",
  },
  {
    id: "sslcommerz",
    name: "SSLCommerz",
    description: "SSLCommerz payment gateway integration setup",
    accent: "blue",
    status: "Active",
    enabled: true,
    mark: "S",
  },
  {
    id: "card",
    name: "Card Payment (Visa/MasterCard)",
    description: "Credit/debit card payment gateway setup",
    accent: "navy",
    status: "Inactive",
    enabled: false,
    mark: "C",
  },
];

const recentLogs = [
  {
    id: "log-1",
    date: "03 Mar, 2024 11:35 AM",
    mobile: "+880 1712-345678",
    type: "OTP",
    message: "Your OTP Code: 245754",
    status: "Success",
    note: "Message sent successfully",
  },
  {
    id: "log-2",
    date: "03 Mar, 2024 11:35 AM",
    mobile: "+880 1712-345678",
    type: "OTP",
    message: "Your OTP Code: 245754",
    status: "Success",
    note: "Message sent successfully",
  },
  {
    id: "log-3",
    date: "03 Mar, 2024 11:35 AM",
    mobile: "+880 1712-345678",
    type: "OTP",
    message: "Your OTP Code: 245754",
    status: "Success",
    note: "Message sent successfully",
  },
];

function ToggleRow({
  label,
  description,
  checked = true,
}: {
  label: string;
  description?: string;
  checked?: boolean;
}) {
  const [enabled, setEnabled] = useState(checked);

  return (
    <div className="general-settings-toggle-row">
      <div className="general-settings-toggle-copy">
        <strong>{label}</strong>
        {description ? <span>{description}</span> : null}
      </div>
      <button
        type="button"
        className={`general-settings-toggle${enabled ? " general-settings-toggle-active" : ""}`}
        aria-pressed={enabled}
        aria-label={label}
        onClick={() => setEnabled((current) => !current)}
      >
        <span />
      </button>
    </div>
  );
}

function PaymentGatewayIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M4.5 7.5h12.5A1.5 1.5 0 0 1 18.5 9v8.5A1.5 1.5 0 0 1 17 19H4.5A1.5 1.5 0 0 1 3 17.5v-8.5A1.5 1.5 0 0 1 4.5 7.5Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path d="M7 11h7" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M7 14.5h4" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path
        d="M15.5 5h4A1.5 1.5 0 0 1 21 6.5v7A1.5 1.5 0 0 1 19.5 15h-3"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path d="M16 10.5h3" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
    </svg>
  );
}

function TableActionIcon({ type }: { type: "settings" | "delete" | "info" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "delete") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 7h14" />
        <path {...commonProps} d="M9 7V5h6v2" />
        <path {...commonProps} d="M8 7l1 11h6l1-11" />
        <path {...commonProps} d="M10.5 11v4" />
        <path {...commonProps} d="M13.5 11v4" />
      </svg>
    );
  }

  if (type === "info") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8.5" />
        <path {...commonProps} d="M12 10.2V16" />
        <path {...commonProps} d="M12 7.8h.01" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="M12 8.5A3.5 3.5 0 1 1 8.5 12 3.5 3.5 0 0 1 12 8.5Z" />
      <path
        {...commonProps}
        d="M19 12a7.6 7.6 0 0 0-.1-1l2-1.5-2-3.5-2.4 1a7.4 7.4 0 0 0-1.7-1l-.3-2.6h-4l-.3 2.6a7.4 7.4 0 0 0-1.7 1l-2.4-1-2 3.5 2 1.5a7.6 7.6 0 0 0 0 2l-2 1.5 2 3.5 2.4-1a7.4 7.4 0 0 0 1.7 1l.3 2.6h4l.3-2.6a7.4 7.4 0 0 0 1.7-1l2.4 1 2-3.5-2-1.5c.1-.3.1-.7.1-1Z"
      />
    </svg>
  );
}

function StatusBadge({ label }: { label: string }) {
  return <span className="sms-status-badge">{label}</span>;
}

function PaymentGatewayToggle({
  enabled = true,
}: {
  enabled?: boolean;
}) {
  const [isEnabled, setIsEnabled] = useState(enabled);

  return (
    <div className="payment-gateway-status">
      <span
        className={`payment-gateway-badge${
          isEnabled ? " payment-gateway-badge-active" : " payment-gateway-badge-inactive"
        }`}
      >
        {isEnabled ? "Active" : "Inactive"}
      </span>
      <button
        type="button"
        className={`payment-gateway-toggle${isEnabled ? " payment-gateway-toggle-active" : ""}`}
        aria-pressed={isEnabled}
        onClick={() => setIsEnabled((current) => !current)}
      >
        <span />
      </button>
    </div>
  );
}

function ToggleSwitch({ checked = true }: { checked?: boolean }) {
  const [enabled, setEnabled] = useState(checked);

  return (
    <button
      type="button"
      className={`sms-toggle${enabled ? " sms-toggle-active" : ""}`}
      aria-pressed={enabled}
      onClick={() => setEnabled((current) => !current)}
    >
      <span />
    </button>
  );
}

function NotificationFeedbackButton({
  className,
  defaultLabel,
  activeLabel,
}: {
  className: string;
  defaultLabel: string;
  activeLabel: string;
}) {
  const [label, setLabel] = useState(defaultLabel);

  return (
    <button
      type="button"
      className={className}
      onClick={() => {
        setLabel(activeLabel);
        window.setTimeout(() => setLabel(defaultLabel), 1200);
      }}
    >
      {label}
    </button>
  );
}

function NotificationIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 5a4 4 0 0 0-4 4v2.7c0 .7-.2 1.4-.6 2l-1 1.5h11.2l-1-1.5c-.4-.6-.6-1.3-.6-2V9a4 4 0 0 0-4-4Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M10 18a2 2 0 0 0 4 0"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function SecuritySettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M10 12.5 11.5 14 14.5 10.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function BackupSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M7 18h10a4 4 0 0 0 .6-8A5.5 5.5 0 0 0 7 8.7 3.8 3.8 0 0 0 7 18Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 10v7"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="m9.5 14.5 2.5 2.5 2.5-2.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ThemeSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="m14 4 6 6"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="m12.5 5.5 6 6L10 20H4v-6l8.5-8.5Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M7.5 16.5h3"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function PinSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 3 6 5.5v5.2c0 4 2.3 6.8 6 8.8 3.7-2 6-4.8 6-8.8V5.5L12 3Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 9v5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="M12 16.5h.01"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function SubscriptionRuleSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <rect
        x="4"
        y="4.5"
        width="16"
        height="15"
        rx="2.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M8 8.5h8"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="M8 12h8"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="M8 15.5h5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function SubscriptionRuleRowIcon({
  type,
}: {
  type: "alert" | "doc" | "lock" | "shield";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "alert") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z" />
        <path {...commonProps} d="M12 8v4" />
        <path {...commonProps} d="M12 16h.01" />
      </svg>
    );
  }

  if (type === "doc") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M7 4.5h7l4 4v11H7z" />
        <path {...commonProps} d="M14 4.5v4h4" />
        <path {...commonProps} d="M9 11h6" />
        <path {...commonProps} d="M9 14.5h4" />
      </svg>
    );
  }

  if (type === "lock") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="5" y="11" width="14" height="10" rx="2" />
        <path {...commonProps} d="M8 11V8a4 4 0 0 1 8 0v3" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z" />
      <path {...commonProps} d="M8.8 12.2 11 14.4l4.5-4.5" />
    </svg>
  );
}

function SubscriptionPlanActionIcon({ type }: { type: "edit" | "more" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "more") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="6" r="1.1" />
        <circle {...commonProps} cx="12" cy="12" r="1.1" />
        <circle {...commonProps} cx="12" cy="18" r="1.1" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z" />
      <path {...commonProps} d="m12.8 6.7 3.5 3.5" />
    </svg>
  );
}

function RolePermissionSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle cx="10" cy="8" r="3.2" fill="none" stroke="currentColor" strokeWidth="1.9" />
      <path
        d="M4.8 19c1.1-2.8 3.2-4.2 5.2-4.2s4.1 1.4 5.2 4.2"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M15.8 12.8l1.6 1.6 3.2-3.2"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function TaxVatSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M9.5 12.2 11.3 14l3.2-3.7"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ActivityLogSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 6v6l4 2"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M20 12a8 8 0 1 1-2.3-5.7"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M16.8 4.2H21v4.2"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ShopRegistrationSettingsIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M7 10.5V19h10v-8.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M5 10.5 12 5l7 5.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M10 13.5h4"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="M12 11.5v4"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function ShopRegistrationRadioIcon({ selected }: { selected?: boolean }) {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle
        cx="12"
        cy="12"
        r="8"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        opacity={selected ? 1 : 0.78}
      />
      {selected ? <circle cx="12" cy="12" r="4" fill="currentColor" /> : null}
    </svg>
  );
}

function ShopRegistrationCheckIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <rect x="4.5" y="4.5" width="15" height="15" rx="2" fill="none" stroke="currentColor" strokeWidth="1.9" />
      <path
        d="m8.4 12 2.3 2.3 4.9-5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function ActivityLogUserAvatarIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle cx="12" cy="8.5" r="4" fill="currentColor" opacity="0.92" />
      <path
        d="M5.5 19c1.5-3 3.8-4.5 6.5-4.5s5 1.5 6.5 4.5"
        fill="currentColor"
        opacity="0.55"
      />
    </svg>
  );
}

function ActivityLogModuleIcon({
  type,
}: {
  type: "users" | "inventory" | "sales" | "settings" | "accounting";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "inventory") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="m12 3 7 4v10l-7 4-7-4V7l7-4Z" />
        <path {...commonProps} d="m5 7 7 4 7-4" />
        <path {...commonProps} d="M12 11v10" />
      </svg>
    );
  }

  if (type === "sales") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M6 7h12" />
        <path {...commonProps} d="M9 7V5h6v2" />
        <path {...commonProps} d="M8 7l1 10h6l1-10" />
        <path {...commonProps} d="M10.5 11v4" />
        <path {...commonProps} d="M13.5 11v4" />
      </svg>
    );
  }

  if (type === "settings") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 8.8A3.2 3.2 0 1 1 8.8 12 3.2 3.2 0 0 1 12 8.8Z" />
        <path
          {...commonProps}
          d="M18.5 12a5.7 5.7 0 0 0-.1-.9l1.8-1.4-1.8-3-2.2.9a6.5 6.5 0 0 0-1.5-.9l-.3-2.3h-3.5l-.3 2.3a6.5 6.5 0 0 0-1.5.9l-2.2-.9-1.8 3 1.8 1.4a5.7 5.7 0 0 0 0 1.8l-1.8 1.4 1.8 3 2.2-.9c.5.4 1 .7 1.5.9l.3 2.3h3.5l.3-2.3c.5-.2 1-.5 1.5-.9l2.2.9 1.8-3-1.8-1.4c.1-.3.1-.6.1-.9Z"
        />
      </svg>
    );
  }

  if (type === "accounting") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M7 4.5h10v15H7z" />
        <path {...commonProps} d="M9.5 8h5" />
        <path {...commonProps} d="M9.5 11.5h5" />
        <path {...commonProps} d="M9.5 15h2.5" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle {...commonProps} cx="9" cy="9" r="3.2" />
      <path {...commonProps} d="M4.8 18c1-2.4 2.6-3.6 4.2-3.6S12.2 15.6 13.2 18" />
      <path {...commonProps} d="M15.5 9h4.5" />
      <path {...commonProps} d="M17.75 6.8v4.4" />
    </svg>
  );
}

function ActivityLogBrowserIcon({ type }: { type: "chrome" | "firefox" | "edge" }) {
  if (type === "firefox") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <defs>
          <linearGradient id="activity-log-firefox-fill" x1="0%" x2="100%" y1="0%" y2="100%">
            <stop offset="0%" stopColor="#ffb347" />
            <stop offset="100%" stopColor="#f97316" />
          </linearGradient>
        </defs>
        <circle cx="12" cy="12" r="8" fill="#2563eb" />
        <path
          d="M16.7 8.5c-.5-1.4-1.9-2.6-3.8-2.9 1 1 1.1 2.1 1 2.7-1.1-1.2-2.9-1.2-4.1-.3-1.7 1.2-2 4-.7 5.8 1.3 1.9 4 2.5 5.9 1.3 1.8-1.1 2.3-3.7 1.7-6.6Z"
          fill="url(#activity-log-firefox-fill)"
        />
      </svg>
    );
  }

  if (type === "edge") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <defs>
          <linearGradient id="activity-log-edge-fill" x1="0%" x2="100%" y1="0%" y2="100%">
            <stop offset="0%" stopColor="#38bdf8" />
            <stop offset="100%" stopColor="#2563eb" />
          </linearGradient>
        </defs>
        <path
          d="M12 4a8 8 0 0 1 8 8c0 1.5-.4 2.8-1.1 4-1.8-1.7-4.2-2.7-6.6-2.7-2.2 0-3.4.9-3.4 2.2 0 1.6 1.9 2.5 4.4 2.5 1.4 0 2.9-.3 4.3-.9A8 8 0 1 1 12 4Z"
          fill="url(#activity-log-edge-fill)"
        />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="8" fill="#fbbc05" />
      <path d="M12 12 5.3 12A6.7 6.7 0 0 1 12 5.3Z" fill="#ea4335" />
      <path d="M12 12 15.4 18A6.7 6.7 0 0 1 5.3 12Z" fill="#34a853" />
      <circle cx="12" cy="12" r="3.2" fill="#4285f4" />
      <circle cx="12" cy="12" r="1.6" fill="#e8f0fe" />
    </svg>
  );
}

function ActivityLogExportIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 15V7"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="m8.5 10.5 3.5-3.5 3.5 3.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M5.5 18h13"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function TaxVatActionIcon({ type }: { type: "edit" | "delete" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "delete") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 7h14" />
        <path {...commonProps} d="M9 7V5h6v2" />
        <path {...commonProps} d="M8 7l1 11h6l1-11" />
        <path {...commonProps} d="M10.5 11v4" />
        <path {...commonProps} d="M13.5 11v4" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z" />
      <path {...commonProps} d="m12.8 6.7 3.5 3.5" />
    </svg>
  );
}

function TaxVatFieldIcon({ type }: { type: "tax" | "vat" | "area" | "routing" | "value" | "toggle" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "toggle") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="4" y="8" width="16" height="8" rx="4" />
        <circle {...commonProps} cx="15.5" cy="12" r="2.6" />
      </svg>
    );
  }

  if (type === "value") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M7 12h10" />
        <path {...commonProps} d="M12 7v10" />
      </svg>
    );
  }

  if (type === "area") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 7h14v10H5z" />
        <path {...commonProps} d="M8 11h8" />
        <path {...commonProps} d="M8 14h5" />
      </svg>
    );
  }

  if (type === "routing") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M7 6h10l-2 3 2 3H9l2-3-2-3Z" />
        <path {...commonProps} d="M10 15h4" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="M7 4.5h7l4 4v11H7z" />
      <path {...commonProps} d="M14 4.5v4h4" />
      <path {...commonProps} d="M9 11h6" />
      <path {...commonProps} d="M9 14.5h4" />
    </svg>
  );
}

function TaxVatApplyCheckIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <rect x="3" y="3" width="18" height="18" rx="4" fill="currentColor" />
      <path
        d="m8 12 2.5 2.5L16 9"
        fill="none"
        stroke="#fff"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function TaxVatUpdateIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M12 16V8"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
      <path
        d="m8.5 11.5 3.5-3.5 3.5 3.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M6 18h12"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
      />
    </svg>
  );
}

function SubscriptionViewIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <circle cx="12" cy="12" r="2.6" fill="none" stroke="currentColor" strokeWidth="1.8" />
    </svg>
  );
}

type SubscriptionSummaryAccent = "blue" | "green" | "yellow" | "red";
type SubscriptionSummaryIconType = "users" | "check" | "clock" | "user";

function SubscriptionSummaryIcon({ type }: { type: SubscriptionSummaryIconType }) {
  if (type === "check") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" strokeWidth="1.8" />
        <path
          d="m8.7 12.1 2.1 2.1 4.6-5"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    );
  }

  if (type === "clock") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="8" fill="none" stroke="currentColor" strokeWidth="1.8" />
        <path d="M12 7.8v4.4l3 1.8" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
      </svg>
    );
  }

  if (type === "user") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path
          d="M16.5 18.5c-1.2-1.7-2.8-2.5-4.5-2.5s-3.3.8-4.5 2.5"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.8"
          strokeLinecap="round"
        />
        <circle cx="12" cy="8.5" r="3" fill="none" stroke="currentColor" strokeWidth="1.8" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="M6 18.5c.7-1.9 2.2-3 4-3s3.3 1.1 4 3"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
      />
      <circle cx="10" cy="8.8" r="2.7" fill="none" stroke="currentColor" strokeWidth="1.8" />
      <circle cx="16" cy="9.9" r="2.2" fill="none" stroke="currentColor" strokeWidth="1.8" />
    </svg>
  );
}

function RoleManagementActionIcon({ type }: { type: "edit" | "more" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "more") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="6" r="1.1" />
        <circle {...commonProps} cx="12" cy="12" r="1.1" />
        <circle {...commonProps} cx="12" cy="18" r="1.1" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z" />
      <path {...commonProps} d="m12.8 6.7 3.5 3.5" />
    </svg>
  );
}

function RolePermissionItemIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <rect x="5" y="10" width="14" height="9" rx="2" fill="none" stroke="currentColor" strokeWidth="1.9" />
      <path d="M8 10V8a4 4 0 0 1 8 0v2" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
      <path d="M12 13v3" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
    </svg>
  );
}

function RolePermissionChevronIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path d="m9 6 6 6-6 6" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

function RoleUserBadgeIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" strokeWidth="1.8" />
      <path
        d="m8.8 12 2.2 2.2 4.2-4.4"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function SecurityCardIcon({
  type,
}: {
  type: "key" | "lock" | "logout" | "shield" | "shield-badge";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "key") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="8.5" cy="11.5" r="4.5" />
        <path {...commonProps} d="M13 11.5h8" />
        <path {...commonProps} d="M17 11.5v3" />
        <path {...commonProps} d="M20 11.5v2" />
      </svg>
    );
  }

  if (type === "logout") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M10 5H7a3 3 0 0 0-3 3v8a3 3 0 0 0 3 3h3" />
        <path {...commonProps} d="M13 8l5 4-5 4" />
        <path {...commonProps} d="M18 12H8" />
      </svg>
    );
  }

  if (type === "shield") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z" />
        <path {...commonProps} d="M9.5 12 11.3 13.8 14.8 10.3" />
      </svg>
    );
  }

  if (type === "shield-badge") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z" />
        <path {...commonProps} d="M12 9v4" />
        <path {...commonProps} d="M12 16h.01" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <rect {...commonProps} x="5" y="11" width="14" height="10" rx="2" />
      <path {...commonProps} d="M8 11V8a4 4 0 0 1 8 0v3" />
    </svg>
  );
}

function InventoryRuleIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 12 4 7.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 12l8-4.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 12v9"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function InventoryRuleItemIcon({
  type,
}: {
  type: "barcode" | "bell" | "box" | "calendar" | "copy" | "folder" | "ruler" | "tag";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "tag") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M20 10 12 18 4 10l6-6h6l4 4Z" />
        <path {...commonProps} d="M14 8h.01" />
      </svg>
    );
  }

  if (type === "barcode") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 6v12" />
        <path {...commonProps} d="M8 6v12" />
        <path {...commonProps} d="M11 8v8" />
        <path {...commonProps} d="M14 6v12" />
        <path {...commonProps} d="M17 8v8" />
        <path {...commonProps} d="M20 6v12" />
      </svg>
    );
  }

  if (type === "folder") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M3.5 8.5h6l2 2h9v7A2.5 2.5 0 0 1 18 20H6a2.5 2.5 0 0 1-2.5-2.5v-9Z" />
        <path {...commonProps} d="M3.5 8.5V7A2.5 2.5 0 0 1 6 4.5h4l2 2h6A2.5 2.5 0 0 1 20.5 9" />
      </svg>
    );
  }

  if (type === "copy") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="8" y="8" width="10" height="10" rx="2" />
        <path {...commonProps} d="M6 15H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v1" />
      </svg>
    );
  }

  if (type === "calendar") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="4" y="5.5" width="16" height="14" rx="2.5" />
        <path {...commonProps} d="M8 3.5v4" />
        <path {...commonProps} d="M16 3.5v4" />
        <path {...commonProps} d="M4 9.5h16" />
        <path {...commonProps} d="M8 13h3" />
      </svg>
    );
  }

  if (type === "ruler") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="m5 15 10-10 4 4L9 19H5v-4Z" />
        <path {...commonProps} d="M12 8 16 12" />
        <path {...commonProps} d="M10 10 8.5 8.5" />
      </svg>
    );
  }

  if (type === "bell") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 5a4 4 0 0 0-4 4v2.7c0 .7-.2 1.4-.6 2l-1 1.5h11.2l-1-1.5c-.4-.6-.6-1.3-.6-2V9a4 4 0 0 0-4-4Z" />
        <path {...commonProps} d="M10 18a2 2 0 0 0 4 0" />
      </svg>
    );
  }

  if (type === "box") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" />
        <path {...commonProps} d="M12 12 4 7.5" />
        <path {...commonProps} d="M12 12l8-4.5" />
        <path {...commonProps} d="M12 12v9" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="M5.5 8h13" />
      <path {...commonProps} d="M5.5 12h13" />
      <path {...commonProps} d="M5.5 16h8" />
    </svg>
  );
}

function UnitActionIcon({ type }: { type: "edit" | "delete" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "delete") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 7h14" />
        <path {...commonProps} d="M9 7V5h6v2" />
        <path {...commonProps} d="M8 7l1 11h6l1-11" />
        <path {...commonProps} d="M10.5 11v4" />
        <path {...commonProps} d="M13.5 11v4" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z" />
      <path {...commonProps} d="m12.8 6.7 3.5 3.5" />
    </svg>
  );
}

function SecurityActivityIcon({
  type,
}: {
  type: "success" | "password" | "failed" | "lock";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "password") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="8.5" cy="11.5" r="4.5" />
        <path {...commonProps} d="M13 11.5h8" />
        <path {...commonProps} d="M17 11.5v3" />
        <path {...commonProps} d="M20 11.5v2" />
      </svg>
    );
  }

  if (type === "failed") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8" />
        <path {...commonProps} d="m9 9 6 6" />
        <path {...commonProps} d="m15 9-6 6" />
      </svg>
    );
  }

  if (type === "lock") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="5" y="11" width="14" height="10" rx="2" />
        <path {...commonProps} d="M8 11V8a4 4 0 0 1 8 0v3" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle {...commonProps} cx="12" cy="12" r="8" />
      <path {...commonProps} d="M8.8 12.2 11 14.4l4.5-4.5" />
    </svg>
  );
}

function BackupRowIcon({ type }: { type: "clock" | "message" | "upload" | "info" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "clock") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8" />
        <path {...commonProps} d="M12 8v4l2.5 2" />
      </svg>
    );
  }

  if (type === "upload") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M7 18h10a4 4 0 0 0 .6-8A5.5 5.5 0 0 0 7 8.7 3.8 3.8 0 0 0 7 18Z" />
        <path {...commonProps} d="M12 15V9" />
        <path {...commonProps} d="m9.5 11.5 2.5-2.5 2.5 2.5" />
      </svg>
    );
  }

  if (type === "info") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8" />
        <path {...commonProps} d="M12 10.5V16" />
        <path {...commonProps} d="M12 8h.01" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="M5 6h14v12H8l-3 3V6Z" />
      <path {...commonProps} d="M9 10h6" />
      <path {...commonProps} d="M9 14h4" />
    </svg>
  );
}

function BackupActionIcon({ type }: { type: "view" | "download" | "delete" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "download") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 4v10" />
        <path {...commonProps} d="m8.5 10.5 3.5 3.5 3.5-3.5" />
        <path {...commonProps} d="M5 19h14" />
      </svg>
    );
  }

  if (type === "delete") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 7h14" />
        <path {...commonProps} d="M9 7V5h6v2" />
        <path {...commonProps} d="M8 7l1 11h6l1-11" />
        <path {...commonProps} d="M10.5 11v4" />
        <path {...commonProps} d="M13.5 11v4" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <circle {...commonProps} cx="12" cy="12" r="7.5" />
      <path {...commonProps} d="M15.5 15.5 19 19" />
      <path {...commonProps} d="M9 12a3 3 0 1 0 6 0 3 3 0 0 0-6 0Z" />
    </svg>
  );
}

function ThemeControlIcon({ type }: { type: "edit" | "upload" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "upload") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M7 18h10a4 4 0 0 0 .6-8A5.5 5.5 0 0 0 7 8.7 3.8 3.8 0 0 0 7 18Z" />
        <path {...commonProps} d="M12 15V9" />
        <path {...commonProps} d="m9.5 11.5 2.5-2.5 2.5 2.5" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z" />
      <path {...commonProps} d="m12.8 6.7 3.5 3.5" />
    </svg>
  );
}

function ThemePreviewIcon({
  type,
}: {
  type: "alert" | "box" | "check" | "shop" | "export" | "refresh" | "save" | "plus";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "check") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8" />
        <path {...commonProps} d="M8.8 12.2 11 14.4l4.5-4.5" />
      </svg>
    );
  }

  if (type === "alert") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8" />
        <path {...commonProps} d="M12 8v4" />
        <path {...commonProps} d="M12 16h.01" />
      </svg>
    );
  }

  if (type === "shop") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 10h14v9H5z" />
        <path {...commonProps} d="M7 10V7h10v3" />
        <path {...commonProps} d="M9 14h6" />
      </svg>
    );
  }

  if (type === "export") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 4v10" />
        <path {...commonProps} d="m8.5 7.5 3.5-3.5 3.5 3.5" />
        <path {...commonProps} d="M5 19h14" />
      </svg>
    );
  }

  if (type === "refresh") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M20 12a8 8 0 1 1-2.3-5.7" />
        <path {...commonProps} d="M20 4v5h-5" />
      </svg>
    );
  }

  if (type === "save") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 4h11l3 3v13H5z" />
        <path {...commonProps} d="M8 4v6h8V4" />
        <path {...commonProps} d="M9 18h6" />
      </svg>
    );
  }

  if (type === "plus") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M12 5v14" />
        <path {...commonProps} d="M5 12h14" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" />
      <path {...commonProps} d="M12 12 4 7.5" />
      <path {...commonProps} d="M12 12l8-4.5" />
      <path {...commonProps} d="M12 12v9" />
    </svg>
  );
}

function PinManagementIcon({
  type,
}: {
  type: "alert" | "lock" | "mail" | "shield" | "x";
}) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "alert") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z" />
        <path {...commonProps} d="M12 8v4" />
        <path {...commonProps} d="M12 16h.01" />
      </svg>
    );
  }

  if (type === "mail") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="4" y="6" width="16" height="12" rx="2" />
        <path {...commonProps} d="m5.5 7.5 6.5 5 6.5-5" />
      </svg>
    );
  }

  if (type === "x") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <circle {...commonProps} cx="12" cy="12" r="8" />
        <path {...commonProps} d="m9 9 6 6" />
        <path {...commonProps} d="m15 9-6 6" />
      </svg>
    );
  }

  if (type === "lock") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <rect {...commonProps} x="5" y="11" width="14" height="10" rx="2" />
        <path {...commonProps} d="M8 11V8a4 4 0 0 1 8 0v3" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="M12 3 5 6v5c0 4.6 2.7 7.8 7 10 4.3-2.2 7-5.4 7-10V6l-7-3Z" />
      <path {...commonProps} d="M12 9v5" />
    </svg>
  );
}

const notificationChannels = [
  {
    id: "email",
    title: "Email Notification",
    description: "System emails and alerts can be sent.",
    accent: "green",
    icon: "mail",
  },
  {
    id: "sms",
    title: "SMS Notification",
    description: "System SMS and alerts can be sent.",
    accent: "indigo",
    icon: "message",
  },
  {
    id: "app",
    title: "In app Notification",
    description: "System emails and alerts can be sent.",
    accent: "red",
    icon: "mobile",
  },
];

const inventoryRuleItems = [
  {
    id: "negative-stock",
    title: "Allow Negative Stock",
    description: "Allow selling products even when stock becomes less than zero.",
    category: "Stock Rules",
    icon: "box" as const,
    accent: "warning" as const,
    enabled: false,
    helpText: "Risky setting. This can create inventory inconsistencies if stock is not reconciled regularly.",
  },
  {
    id: "enable-brands",
    title: "Enable Brands",
    description: "Use brands when creating products.",
    category: "Product Rules",
    icon: "tag" as const,
    accent: "green" as const,
    enabled: true,
    helpText: "Lets your team assign brand information to products.",
  },
  {
    id: "barcode-required",
    title: "Barcode Required",
    description: "Require a barcode when creating a product.",
    category: "Validation Rules",
    icon: "barcode" as const,
    accent: "blue" as const,
    enabled: true,
    helpText: "Prevents saving products without a scannable barcode.",
  },
  {
    id: "category-required",
    title: "Category Required",
    description: "Require a category before saving a product.",
    category: "Validation Rules",
    icon: "folder" as const,
    accent: "indigo" as const,
    enabled: true,
    helpText: "Keeps products organized and avoids uncategorized items.",
  },
  {
    id: "duplicate-products",
    title: "Allow Duplicate Products",
    description: "Allow multiple products with the same name.",
    category: "Validation Rules",
    icon: "copy" as const,
    accent: "orange" as const,
    enabled: false,
    helpText: "Useful for variants, but can also create duplicate catalog entries.",
  },
  {
    id: "default-sale-unit",
    title: "Default Sale Unit",
    description: "Choose the default unit used while selling products.",
    category: "Product Rules",
    icon: "ruler" as const,
    accent: "teal" as const,
    field: "select" as const,
    fieldValue: "Pcs",
    options: ["Pcs", "Box", "Kg", "Liter", "Meter"],
    helpText: "Preselects the most common sales unit in product and sales forms.",
  },
  {
    id: "expiry-tracking",
    title: "Expiry Tracking",
    description: "Track product expiry dates and generate alerts.",
    category: "Product Rules",
    icon: "calendar" as const,
    accent: "purple" as const,
    enabled: true,
    helpText: "Helps monitor shelf life and notify staff before stock expires.",
  },
  {
    id: "low-stock-limit",
    title: "Low Stock Alert Limit",
    description: "Set the threshold that triggers low stock alerts.",
    category: "Stock Rules",
    icon: "bell" as const,
    accent: "red" as const,
    field: "input" as const,
    fieldValue: "10",
    helpText: "Alerts appear once product quantity falls to or below this value.",
  },
];

const inventoryUnits = [
  { id: "pitch", name: "Pitch", shortcut: "PCS", type: "Number", status: "Account" },
  { id: "kilogram", name: "Kilogram", shortcut: "KG", type: "Weight", status: "Account" },
  { id: "gram", name: "Gram", shortcut: "GM", type: "Weight", status: "Account" },
  { id: "litter", name: "Litter", shortcut: "LTR", type: "Volume", status: "Account" },
  { id: "box", name: "Box", shortcut: "Box", type: "Number", status: "Account" },
];

const securitySettingCards = [
  {
    id: "2fa",
    title: "Two-step verification (2FA)",
    description: "Two-step verification for additional login security.",
    icon: "lock" as const,
    enabled: true,
  },
  {
    id: "password-rule",
    title: "Strong Password rule",
    description: "Two-step verification for additional login security.",
    icon: "key" as const,
    enabled: true,
  },
  {
    id: "auto-logout",
    title: "Auto Logout",
    description: "Two-step verification for additional login security.",
    icon: "logout" as const,
    enabled: true,
  },
  {
    id: "ip-communication",
    title: "IP Communication",
    description: "Provide permission for the plastic system.",
    icon: "shield" as const,
    enabled: true,
    footerType: "button" as const,
    footerLabel: "3 IPs have been set",
  },
  {
    id: "session-limit",
    title: "Active Session Limit",
    description: "Provide permission for the plastic system.",
    icon: "lock" as const,
    enabled: true,
    footerType: "select" as const,
    footerLabel: "2 session",
  },
  {
    id: "failed-login-limit",
    title: "Failed Login Limit",
    description: "Provide permission for the plastic system.",
    icon: "shield-badge" as const,
    enabled: true,
    footerType: "select" as const,
    footerLabel: "2 session",
  },
];

const securityActivityRows = [
  {
    id: "security-log-1",
    dateTime: "12 Jan 2024 02:00 AM",
    user: "Supper Admin",
    role: "Admin",
    activity: "Successful Login",
    activityType: "success" as const,
    details: "Successfully logged into the system.",
    ipAddress: "192.54.4.20",
    status: "Success",
    statusType: "success" as const,
  },
  {
    id: "security-log-2",
    dateTime: "12 Jan 2024 02:00 AM",
    user: "Supper Admin",
    role: "Admin",
    activity: "Password Change",
    activityType: "password" as const,
    details: "Successfully updated the account password.",
    ipAddress: "192.412.21",
    status: "Success",
    statusType: "success" as const,
  },
  {
    id: "security-log-3",
    dateTime: "12 Jan 2024 02:00 AM",
    user: "Supper Admin",
    role: "Admin",
    activity: "Unsuccessful Login",
    activityType: "failed" as const,
    details: "Failed password caused the login attempt to be rejected.",
    ipAddress: "192.412.21",
    status: "Reject",
    statusType: "danger" as const,
  },
  {
    id: "security-log-4",
    dateTime: "12 Jan 2024 02:00 AM",
    user: "Supper Admin",
    role: "Admin",
    activity: "Account Lock",
    activityType: "lock" as const,
    details: "Account was locked after repeated failed attempts.",
    ipAddress: "192.412.21",
    status: "Lock",
    statusType: "danger" as const,
  },
];

const activityLogFilters = [
  {
    id: "log-type",
    label: "Log Type",
    value: "All Logs",
    options: ["All Logs", "System Logs", "User Logs", "API Logs"],
  },
  {
    id: "user",
    label: "User",
    value: "All Users",
    options: ["All Users", "Super Admin", "HR Manager", "Sales User", "Accountant"],
  },
  {
    id: "module",
    label: "Module",
    value: "All Modules",
    options: ["All Modules", "User Management", "Inventory", "Sales", "System Settings", "Accounting"],
  },
  {
    id: "action",
    label: "Action",
    value: "All Actions",
    options: ["All Actions", "Create", "Update", "Delete"],
  },
];

const activityLogRows = [
  {
    id: "activity-log-1",
    dateTime: "12 Jan 2024 02:00AM",
    user: "Super Admin",
    handle: "super.admin",
    module: "User Management",
    moduleType: "users" as const,
    action: "Create",
    actionType: "create" as const,
    details: 'New User Created By "Kazi Salauddin"',
    ipAddress: "192.544.2",
    browser: "192.544.2",
    browserType: "chrome" as const,
    status: "Success",
    statusType: "success" as const,
  },
  {
    id: "activity-log-2",
    dateTime: "12 Jan 2024 02:00AM",
    user: "HR Manager",
    handle: "hr.manager",
    module: "Inventory",
    moduleType: "inventory" as const,
    action: "Update",
    actionType: "update" as const,
    details: 'Product "Laptop" Stock Updated',
    ipAddress: "192.412.21",
    browser: "192.412.21",
    browserType: "firefox" as const,
    status: "Success",
    statusType: "success" as const,
  },
  {
    id: "activity-log-3",
    dateTime: "12 Jan 2024 02:00AM",
    user: "Sales User",
    handle: "sales.user",
    module: "Sales",
    moduleType: "sales" as const,
    action: "Delete",
    actionType: "delete" as const,
    details: "Sales Order #SO-2026-016 Deleted",
    ipAddress: "192.412.21",
    browser: "192.412.21",
    browserType: "edge" as const,
    status: "Reject",
    statusType: "reject" as const,
  },
  {
    id: "activity-log-4",
    dateTime: "12 Jan 2024 02:00AM",
    user: "Super Admin",
    handle: "admin",
    module: "System Settings",
    moduleType: "settings" as const,
    action: "Update",
    actionType: "update" as const,
    details: "Tax Setting Was Changed",
    ipAddress: "192.412.21",
    browser: "192.412.21",
    browserType: "chrome" as const,
    status: "Success",
    statusType: "success" as const,
  },
  {
    id: "activity-log-5",
    dateTime: "12 Jan 2024 02:00AM",
    user: "Accountant",
    handle: "accountant",
    module: "Accounting",
    moduleType: "accounting" as const,
    action: "Create",
    actionType: "create" as const,
    details: "New Voucher #JV-2026-016",
    ipAddress: "192.412.21",
    browser: "192.412.21",
    browserType: "chrome" as const,
    status: "Success",
    statusType: "success" as const,
  },
];

const shopRegistrationWorkflowOptions = [
  {
    id: "manual-verification",
    title: "Manual Verification",
    description: "Will be activated after admin approval.",
    selected: true,
  },
  {
    id: "auto-approval",
    title: "Auto Approval",
    description: "The shop will be activated once is complete.",
    selected: false,
  },
];

const shopRegistrationSecurityRules = [
  {
    id: "allow-new-shops",
    title: "Allow new shop registrations.",
    description: "Allow new shop registrations.",
    enabled: true,
  },
  {
    id: "email-verification",
    title: "Email verification is mandatory.",
    description: "Will be activated after admin approval.",
    enabled: true,
  },
  {
    id: "mobile-verification",
    title: "Mobile verification is mandatory.",
    description: "Will be activated after admin approval.",
    enabled: true,
  },
  {
    id: "nid-verification",
    title: "NID verification is mandatory.",
    description: "Will be activated after admin approval.",
    enabled: true,
  },
];

const shopRegistrationRequiredDocuments = [
  {
    id: "owner-nid",
    title: "Owner NID",
    description: "National ID card image",
  },
  {
    id: "trade-license",
    title: "Tread License",
    description: "The shop will be activated once is complete.",
  },
  {
    id: "shop-image",
    title: "Shop Image",
    description: "The shop will be activated once is complete.",
  },
  {
    id: "owner-image",
    title: "Owner Image",
    description: "The shop will be activated once is complete.",
  },
];

const shopRegistrationDocumentRows = [
  {
    id: "shop-doc-1",
    name: "Owner NID",
    fileType: "JPG, PNG, PDF",
    size: "2MB",
    status: "Necessary",
  },
  {
    id: "shop-doc-2",
    name: "Tread License",
    fileType: "JPG, PNG, PDF",
    size: "2MB",
    status: "Necessary",
  },
  {
    id: "shop-doc-3",
    name: "Shop Image",
    fileType: "JPG, PNG, PDF",
    size: "2MB",
    status: "Necessary",
  },
  {
    id: "shop-doc-4",
    name: "Owner Image",
    fileType: "JPG, PNG, PDF",
    size: "2MB",
    status: "Necessary",
  },
];

const backupConfigItems = [
  {
    id: "auto-backup",
    title: "Auto Backup on/off",
    description: "Turn auto backup on and off at scheduled times.",
    icon: "clock" as const,
    type: "toggle" as const,
  },
  {
    id: "backup-frequency",
    title: "Backup frequency",
    description: "Auto backup will stop after a day or so.",
    icon: "message" as const,
    type: "select" as const,
    value: "Everyday",
    options: ["Everyday", "Weekly", "Monthly"],
  },
  {
    id: "backup-time",
    title: "Backup Time",
    description: "Backup will be done at a scheduled time every day.",
    icon: "message" as const,
    type: "time" as const,
    value: "02:00AM",
  },
  {
    id: "retention-period",
    title: "Backup retention period",
    description: "How long will backup files be stored?",
    icon: "message" as const,
    type: "select" as const,
    value: "Pcs",
    options: ["Pcs", "7 days", "30 days", "90 days"],
  },
  {
    id: "backup-email",
    title: "Email notification when backup is complete",
    description: "Email notification when backup is complete",
    icon: "clock" as const,
    type: "toggle" as const,
  },
];

const backupActionItems = [
  {
    id: "manual-backup",
    title: "Backup frequency",
    description: "Create a backup of the database now.",
    icon: "message" as const,
    buttonLabel: "Backup",
  },
  {
    id: "reset-backup",
    title: "Reset Backup",
    description: "Create a database from a previously created backup.",
    icon: "message" as const,
    buttonLabel: "Backup",
  },
];

const recentBackupRows = [
  {
    id: "backup-log-1",
    dateTime: "31 May 2024 02:00Am",
    fileName: "backup_2024_05_020000.sql",
    size: "45.6MB",
    type: "Auto Backup",
    status: "Success",
  },
  {
    id: "backup-log-2",
    dateTime: "31 May 2024 02:00Am",
    fileName: "backup_2024_05_020000.sql",
    size: "45.6MB",
    type: "Auto Backup",
    status: "Success",
  },
  {
    id: "backup-log-3",
    dateTime: "31 May 2024 02:00Am",
    fileName: "backup_2024_05_020000.sql",
    size: "45.6MB",
    type: "Auto Backup",
    status: "Success",
  },
  {
    id: "backup-log-4",
    dateTime: "31 May 2024 02:00Am",
    fileName: "backup_2024_05_020000.sql",
    size: "45.6MB",
    type: "Auto Backup",
    status: "Success",
  },
  {
    id: "backup-log-5",
    dateTime: "31 May 2024 02:00Am",
    fileName: "backup_2024_05_020000.sql",
    size: "45.6MB",
    type: "Auto Backup",
    status: "Success",
  },
];

const themeColorItems = [
  {
    id: "primary",
    title: "Primary Color",
    description: "Choose the main brand color used across buttons and highlights.",
    swatch: "#00743C",
    value: "#00743C",
  },
  {
    id: "secondary",
    title: "Secondary Color",
    description: "Set the supporting color for layouts, surfaces, and accents.",
    swatch: "#1158DB",
    value: "#1158DB",
  },
  {
    id: "accent",
    title: "Accent Color",
    description: "Pick an accent color for badges, callouts, and small highlights.",
    swatch: "#F39606",
    value: "#F39606",
  },
];

const themePreviewStats = [
  {
    id: "total-products",
    title: "Total Products",
    value: "4516",
    note: "All products",
    accent: "violet" as const,
    icon: "box" as const,
  },
  {
    id: "active-products",
    title: "Active Products",
    value: "4500",
    note: "Shops can use these",
    accent: "green" as const,
    icon: "check" as const,
  },
  {
    id: "inactive-products",
    title: "Inactive Products",
    value: "16",
    note: "In system, not visible",
    accent: "orange" as const,
    icon: "alert" as const,
  },
  {
    id: "using-shops",
    title: "Using Shops",
    value: "12,684",
    note: "Shops using products",
    accent: "blue" as const,
    icon: "shop" as const,
  },
];

const pinManagementItems = [
  {
    id: "pin-enabled",
    title: "Require PIN for Sensitive Actions",
    description: "Ask for a PIN before approving protected actions and secure operations.",
    icon: "shield" as const,
    accent: "blue" as const,
    type: "toggle" as const,
  },
  {
    id: "pin-frequency",
    title: "Enable PIN Recovery",
    description: "Allow users to recover or reset their PIN through the recovery flow.",
    icon: "alert" as const,
    accent: "red" as const,
    type: "toggle" as const,
  },
  {
    id: "pindhari-period",
    title: "PIN Expiry Period",
    description: "Set how many days a PIN stays valid before users must update it.",
    icon: "lock" as const,
    accent: "pink" as const,
    type: "metric" as const,
    value: "90",
    unit: "Day",
  },
  {
    id: "highest-wrong-try",
    title: "Maximum Wrong Attempts",
    description: "Choose how many incorrect PIN entries are allowed before extra protection starts.",
    icon: "x" as const,
    accent: "red" as const,
    type: "metric" as const,
    value: "05",
    unit: "Time",
  },
  {
    id: "account-lock-time",
    title: "Account Lock Time",
    description: "Set how long the account remains locked after too many failed PIN attempts.",
    icon: "lock" as const,
    accent: "violet" as const,
    type: "metric" as const,
    value: "30",
    unit: "Min",
  },
  {
    id: "pin-reset-email",
    title: "PIN Reset Email Notification",
    description: "Send an email alert whenever a PIN reset request is created or completed.",
    icon: "mail" as const,
    accent: "blue" as const,
    type: "toggle" as const,
  },
];

const subscriptionPlanRows = [
  { id: "basic", name: "Basic", duration: "1 Month", price: "$99.21", users: "5", status: "Active" },
  { id: "standard", name: "Standard", duration: "60 Month", price: "$99.21", users: "5", status: "Active" },
  { id: "professional", name: "Professional", duration: "1 Year", price: "$99.21", users: "5", status: "Active" },
  { id: "enterprise", name: "Enterprise", duration: "Custom", price: "$99.21", users: "5", status: "Active" },
  { id: "basic-2", name: "Basic", duration: "1 Month", price: "$99.21", users: "5", status: "Active" },
  { id: "basic-3", name: "Basic", duration: "1 Month", price: "$99.21", users: "5", status: "Active" },
];

const subscriptionListRows = [
  {
    id: "abc-traders",
    customer: "ABC Traders",
    plan: "Standard",
    startDate: "31 may 2024",
    endDate: "31 may 2025",
    status: "Active",
  },
  {
    id: "xyz-fashion",
    customer: "XYZ Fashion",
    plan: "Basic",
    startDate: "31 may 2024",
    endDate: "31 may 2025",
    status: "Active",
  },
  {
    id: "brother-fashion",
    customer: "Brother Fashion",
    plan: "Professional",
    startDate: "31 may 2024",
    endDate: "31 may 2025",
    status: "Active",
  },
];

const subscriptionSummaryItems: Array<{
  id: string;
  label: string;
  value: string;
  accent: SubscriptionSummaryAccent;
  icon: SubscriptionSummaryIconType;
}> = [
  {
    id: "total",
    label: "Total subscription",
    value: "120",
    accent: "blue",
    icon: "users",
  },
  {
    id: "active",
    label: "Active subscription",
    value: "120",
    accent: "green",
    icon: "check",
  },
  {
    id: "soon",
    label: "The term will end soon.",
    value: "120",
    accent: "yellow",
    icon: "clock",
  },
  {
    id: "expired",
    label: "Expired Subscription",
    value: "120",
    accent: "red",
    icon: "user",
  },
];

const roleManagementRows = [
  { id: "super-admin", name: "Supper Admin", explain: "Highest level access", users: "5" },
  { id: "admin", name: "Admin", explain: "Highest level access", users: "3" },
  { id: "manager", name: "Manager", explain: "Highest level access", users: "4" },
  { id: "sales-executive", name: "Sales Executive", explain: "Highest level access", users: "5" },
  { id: "store-keeper", name: "Store keeper", explain: "Highest level access", users: "7" },
  { id: "basic-1", name: "Basic", explain: "Low level access", users: "8" },
  { id: "basic-2", name: "Basic", explain: "Low level access", users: "8" },
];

const rolePermissionItems = [
  { id: "module", label: "Module Permission" },
  { id: "action", label: "Action Permission" },
  { id: "data", label: "Data Access Permission" },
  { id: "report", label: "Report permission" },
  { id: "system", label: "System setting permission" },
];

const roleUsersByRoleItems = [
  { id: "super-admin", role: "Super Admin", count: "7", accent: "violet" as const },
  { id: "admin", role: "Admin", count: "8", accent: "blue" as const },
  { id: "manager", role: "Manager", count: "4", accent: "green" as const },
  { id: "sales-executive", role: "Sales executive", count: "12", accent: "orange" as const },
  { id: "store-keeper", role: "Store Keeper", count: "6", accent: "red" as const },
  { id: "accounted", role: "Accounted", count: "4", accent: "violet" as const },
];

const taxVatRateRows = [
  { id: "vat-15", name: "VAT 15%", type: "VAT", rate: "15.00", status: "Success" },
  { id: "vat-75", name: "VAT 7.5%", type: "VAT", rate: "7.50", status: "Success" },
  { id: "tax-5", name: "TAX 5%", type: "TAX", rate: "5.00", status: "Reject" },
  { id: "tax-25", name: "TAX 2.5%", type: "TAX", rate: "2.50", status: "Success" },
  { id: "service-1", name: "Service Charge 10%", type: "Charge", rate: "10.00", status: "Success" },
  { id: "service-2", name: "Service Charge 10%", type: "Charge", rate: "10.00", status: "Success" },
];

const taxVatSettingsFields = [
  {
    id: "different-vat-rate",
    label: "Different VAT Rate",
    type: "select" as const,
    value: "VAT 15% (15%)",
    options: ["VAT 15% (15%)", "VAT 7.5% (7.5%)", "VAT 5% (5%)"],
  },
  {
    id: "different-tax-rate",
    label: "Different TAX Rate",
    type: "select" as const,
    value: "TAX 5% (5%)",
    options: ["TAX 5% (5%)", "TAX 2.5% (2.5%)", "TAX 1% (1%)"],
  },
  {
    id: "vat-area",
    label: "TAX/VAT Showing Area",
    type: "select" as const,
    value: "Below The Invoice Item",
    options: ["Below The Invoice Item", "Above The Invoice Item", "Invoice Summary"],
  },
  {
    id: "routing-method",
    label: "Routing Method",
    type: "select" as const,
    value: "General Routing",
    options: ["General Routing", "Custom Routing", "Manual Routing"],
  },
  {
    id: "routing-value",
    label: "Routing Value",
    type: "input" as const,
    value: "0.01",
  },
  {
    id: "display-separate",
    label: "Display TAX/VAT Separately Invoice",
    type: "toggle" as const,
  },
];

const taxVatApplyItems = [
  { id: "sales", label: "Apply TAX/VAT To Sales Invoice" },
  { id: "purchase", label: "Apply TAX/VAT To Purchase Invoice" },
  { id: "return", label: "Apply TAX/VAT To Return/Credit Invoice" },
  { id: "product-price", label: "Apply TAX/VAT To Product Price Invoice" },
];

const taxVatNumberFields = [
  {
    id: "vat-number-rate",
    label: "Different VAT Rate",
    type: "select" as const,
    value: "VAT 15% (15%)",
    options: ["VAT 15% (15%)", "VAT 7.5% (7.5%)", "VAT 5% (5%)"],
  },
  {
    id: "tax-number-rate",
    label: "Different TAX Rate",
    type: "select" as const,
    value: "TAX 5% (5%)",
    options: ["TAX 5% (5%)", "TAX 2.5% (2.5%)", "TAX 1% (1%)"],
  },
  {
    id: "routing-number-method",
    label: "Routing Method",
    type: "select" as const,
    value: "General Routing",
    options: ["General Routing", "Custom Routing", "Manual Routing"],
  },
];

const subscriptionRuleItems = [
  {
    id: "renewal",
    title: "Automatic renewal",
    description: "Turn auto-renew on or off before expiration.",
    icon: "shield" as const,
    accent: "blue" as const,
    type: "toggle" as const,
  },
  {
    id: "before-renewal",
    title: "Notification before renewal",
    description: "Notify users before a subscription renews.",
    icon: "alert" as const,
    accent: "red" as const,
    type: "select" as const,
    value: "07 Day",
    options: ["07 Day", "14 Day", "30 Day"],
  },
  {
    id: "press-period",
    title: "Press period",
    description: "Set the grace period before access is limited.",
    icon: "alert" as const,
    accent: "pink" as const,
    type: "select" as const,
    value: "07 Day",
    options: ["07 Day", "14 Day", "30 Day"],
  },
  {
    id: "access-after-expire",
    title: "Access after Expires",
    description: "Allow access after a subscription expires.",
    icon: "lock" as const,
    accent: "blue" as const,
    type: "toggle" as const,
  },
  {
    id: "invoice-generation",
    title: "Indus Generation",
    description: "Generate an invoice when a subscription is created.",
    icon: "doc" as const,
    accent: "blue" as const,
    type: "toggle" as const,
  },
];

const notificationEvents = [
  {
    id: "stock",
    title: "Low stock alert",
    description: "Notifications will be sent when the product stock runs low.",
  },
  {
    id: "expired",
    title: "Subscription expired.",
    description: "Notifications will be sent when Subscription expired.",
  },
  {
    id: "payment",
    title: "Payment successful",
    description: "Notifications will be sent when payment successful",
  },
  {
    id: "user",
    title: "Add new user",
    description: "System emails and alerts can be sent.",
  },
  {
    id: "update",
    title: "System update",
    description: "System emails and alerts can be sent.",
  },
];

const customNotifications = [
  {
    id: "cn-1",
    name: "Low stock Alert",
    event: "Product Stock Low",
    status: "Account",
  },
  {
    id: "cn-2",
    name: "Low stock Alert",
    event: "Product Stock Low",
    status: "Account",
  },
  {
    id: "cn-3",
    name: "Low stock Alert",
    event: "Product Stock Low",
    status: "Account",
  },
];

function NotificationItemIcon({ type }: { type: "mail" | "message" | "mobile" | "bell" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
    case "mail":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="4" y="6" width="16" height="12" rx="2" />
          <path {...commonProps} d="m5.5 7.5 6.5 5 6.5-5" />
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
    case "mobile":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="7" y="3.5" width="10" height="17" rx="2" />
          <path {...commonProps} d="M10 6.5h4" />
          <path {...commonProps} d="M11.5 17.5h1" />
        </svg>
      );
    default:
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M12 5a4 4 0 0 0-4 4v2.7c0 .7-.2 1.4-.6 2l-1 1.5h11.2l-1-1.5c-.4-.6-.6-1.3-.6-2V9a4 4 0 0 0-4-4Z" />
          <path {...commonProps} d="M10 18a2 2 0 0 0 4 0" />
        </svg>
      );
  }
}

function ChannelPill({ type }: { type: "email" | "sms" | "app" }) {
  const icon = type === "email" ? "mail" : type === "sms" ? "message" : "mobile";
  return (
    <span className={`notification-channel-pill notification-channel-pill-${type}`}>
      <NotificationItemIcon type={icon} />
    </span>
  );
}

function NotificationActionIcon({ type }: { type: "edit" | "delete" }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  if (type === "delete") {
    return (
      <svg aria-hidden="true" viewBox="0 0 24 24">
        <path {...commonProps} d="M5 7h14" />
        <path {...commonProps} d="M9 7V5h6v2" />
        <path {...commonProps} d="M8 7l1 11h6l1-11" />
        <path {...commonProps} d="M10.5 11v4" />
        <path {...commonProps} d="M13.5 11v4" />
      </svg>
    );
  }

  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path {...commonProps} d="m4 20 4.5-1 9-9-3.5-3.5-9 9L4 20Z" />
      <path {...commonProps} d="m12.8 6.7 3.5 3.5" />
    </svg>
  );
}

function SectionAnchorAction({ href, label }: { href?: string; label: string }) {
  if (!href) {
    return null;
  }

  return <Link href={href}>{label}</Link>;
}

export function GeneralSettingsSection({ sectionId }: { sectionId?: string }) {
  return (
    <section className="general-settings-page" id={sectionId}>
      <div className="general-settings-shell">
        <div className="general-settings-left-column">
          <div className="general-settings-card">
            <h2>Basic Information</h2>
            <div className="general-settings-form-grid">
              <label className="general-settings-field">
                <span>App Name</span>
                <input defaultValue="MUDI ERP" />
              </label>
              <label className="general-settings-field">
                <span>Tagline</span>
                <input defaultValue="All-in-One Business Management Solution" />
              </label>
              <label className="general-settings-field">
                <span>Company Name</span>
                <input defaultValue="Fresh" />
              </label>
              <label className="general-settings-field">
                <span>Website</span>
                <input defaultValue="https://mudierp.com" />
              </label>
              <label className="general-settings-field">
                <span>Support Mail</span>
                <input defaultValue="support@gmail.com" />
              </label>
              <label className="general-settings-field">
                <span>Support Phone Number</span>
                <div className="general-settings-phone-group">
                  <select defaultValue="BD">
                    <option value="BD">BD</option>
                  </select>
                  <input defaultValue="+880 170-334578" />
                </div>
              </label>
              <label className="general-settings-field general-settings-field-full">
                <span>Company address</span>
                <textarea defaultValue="House-12, Road-05, Dhanmondi, Dhaka-1205, Bangladesh" />
              </label>
              <label className="general-settings-field">
                <span>Time zone</span>
                <select defaultValue="(GMT+06:00) Asia/Dhaka">
                  <option>(GMT+06:00) Asia/Dhaka</option>
                </select>
              </label>
              <label className="general-settings-field">
                <span>Language</span>
                <select defaultValue="Bangla">
                  <option>Bangla</option>
                </select>
              </label>
              <label className="general-settings-field">
                <span>Currency</span>
                <select defaultValue="BDT (৳) - Bangladeshi Taka">
                  <option>BDT (৳) - Bangladeshi Taka</option>
                </select>
              </label>
              <label className="general-settings-field">
                <span>Date</span>
                <input defaultValue="31-12-2024" />
              </label>
            </div>
          </div>

          <div className="general-settings-card">
            <h2>Others Setting</h2>
            <div className="general-settings-form-grid">
              <label className="general-settings-field">
                <span>Page per item</span>
                <select defaultValue="10">
                  <option>10</option>
                </select>
              </label>
              <label className="general-settings-field">
                <span>Redirect after saving data</span>
                <select defaultValue="Stay on the current page">
                  <option>Stay on the current page</option>
                </select>
              </label>
              <label className="general-settings-field">
                <span>Currency</span>
                <select defaultValue="BDT (৳) - Bangladeshi Taka">
                  <option>BDT (৳) - Bangladeshi Taka</option>
                </select>
              </label>
            </div>
          </div>
        </div>

        <div className="general-settings-right-column">
          <div className="general-settings-card">
            <h2>Basic Information</h2>
            <div className="general-settings-form-grid general-settings-form-grid-single">
              <label className="general-settings-field">
                <span>Facebook page</span>
                <input defaultValue="MUDI ERP" />
              </label>
              <label className="general-settings-field">
                <span>Linkedin</span>
                <input defaultValue="Fresh" />
              </label>
              <label className="general-settings-field">
                <span>Youtube</span>
                <input defaultValue="support@gmail.com" />
              </label>
              <label className="general-settings-field">
                <span>Twitter (X)</span>
                <input defaultValue="support@gmail.com" />
              </label>
            </div>

            <div className="general-settings-toggle-stack">
              {toggleOptions.map((item) => (
                <ToggleRow
                  key={item.label}
                  label={
                    item.label === "Multiple language"
                      ? "Enable Multiple Language"
                      : item.label === "Dark mode enable"
                        ? "Enable Dark Mood"
                        : item.label === "Maintenance mode"
                          ? "Maintenance Mood"
                          : item.label === "New registration permission"
                            ? "New registration permission"
                            : "Email Notification"
                  }
                  checked={item.checked}
                />
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="general-settings-logo-row">
        <div className="general-settings-card">
          <h2>Logo and Fedicon</h2>
          <div className="general-settings-logo-grid">
            <div className="general-settings-logo-card">
              <span className="general-settings-logo-title">App Logo</span>
              <div className="general-settings-logo-body">
                <div className="general-settings-logo-preview">
                  <div className="general-settings-logo-mark">🛍</div>
                  <strong>MUDI ERP</strong>
                </div>
                <button type="button" className="general-settings-upload-button">
                  Upload Change
                </button>
              </div>
              <small>PNG, JPG, SVG (Max. 2MB)</small>
            </div>

            <div className="general-settings-logo-card">
              <span className="general-settings-logo-title">Fedicon</span>
              <div className="general-settings-logo-body">
                <div className="general-settings-logo-preview general-settings-logo-preview-icon">
                  <div className="general-settings-logo-mark">🛍</div>
                </div>
                <button type="button" className="general-settings-upload-button">
                  Upload Change
                </button>
              </div>
              <small>PNG, JPG, SVG (Max. 512KB)</small>
            </div>
          </div>
        </div>
      </div>

      <div className="general-settings-actions">
        <button type="button" className="general-settings-secondary-button">
          Reset
        </button>
        <button type="button" className="general-settings-primary-button">
          Save changes
        </button>
      </div>
    </section>
  );
}

export function PaymentGatewaySettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  const [isModalOpen, setIsModalOpen] = useState(false);

  return (
    <>
      <section className="payment-settings-page" id={sectionId}>
        <article className="payment-settings-hero">
          <div className="payment-settings-icon">
            <PaymentGatewayIcon />
          </div>

          <div className="payment-settings-copy">
            <h2>Payment Gateway Settings</h2>
            <p>bKash, Nagad, Rocket, SSLCommerz, and card payment gateway setup.</p>
            <SectionAnchorAction href={heroLinkHref} label="Configure payment settings" />
          </div>
        </article>

        <section className="payment-gateway-table-card">
          <div className="payment-gateway-table-header">
            <h3>Supported Payment Gateways</h3>
            <button
              type="button"
              className="payment-gateway-add-button"
              onClick={() => setIsModalOpen(true)}
            >
              + Add New Gateway
            </button>
          </div>

          <div className="payment-gateway-table">
            <div className="payment-gateway-table-head">
              <span>Gateway Name</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {paymentGateways.map((gateway) => (
              <article className="payment-gateway-row" key={gateway.id}>
                <div className="payment-gateway-main">
                  <div className={`payment-gateway-logo payment-gateway-logo-${gateway.accent}`}>
                    <span>{gateway.mark}</span>
                  </div>
                  <div className="payment-gateway-copy">
                    <strong>{gateway.name}</strong>
                    <span>{gateway.description}</span>
                  </div>
                </div>

                <PaymentGatewayToggle enabled={gateway.enabled} />

                <div className="payment-gateway-actions">
                  <button type="button" className="payment-gateway-action-button">
                    <TableActionIcon type="settings" />
                    Settings
                  </button>
                  <button
                    type="button"
                    className="payment-gateway-action-button payment-gateway-action-button-danger"
                  >
                    <TableActionIcon type="delete" />
                    Delete
                  </button>
                </div>
              </article>
            ))}
          </div>

          <div className="payment-gateway-note">
            <div className="payment-gateway-note-icon">
              <TableActionIcon type="info" />
            </div>
            <p>
              The gateways marked as active will appear to users during checkout and payment selection.
            </p>
          </div>
        </section>
      </section>

      {isModalOpen ? (
        <div className="payment-modal-backdrop" onClick={() => setIsModalOpen(false)}>
          <div
            className="payment-modal"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-labelledby="payment-modal-title"
          >
            <div className="payment-modal-header">
              <div>
                <h3 id="payment-modal-title">Add New Gateway</h3>
                <p>Create a new payment method configuration for your platform.</p>
              </div>
              <button
                type="button"
                className="payment-modal-close"
                onClick={() => setIsModalOpen(false)}
                aria-label="Close modal"
              >
                ×
              </button>
            </div>

            <form className="payment-modal-form">
              <label className="payment-modal-field">
                <span>Gateway Name</span>
                <input type="text" placeholder="Enter gateway name" />
              </label>

              <label className="payment-modal-field">
                <span>Gateway Type</span>
                <select defaultValue="Mobile Banking">
                  <option>Mobile Banking</option>
                  <option>Card Payment</option>
                  <option>Bank Transfer</option>
                </select>
              </label>

              <label className="payment-modal-field payment-modal-field-full">
                <span>Description</span>
                <textarea placeholder="Describe how this gateway should be used." />
              </label>

              <label className="payment-modal-field">
                <span>Merchant ID</span>
                <input type="text" placeholder="Enter merchant ID" />
              </label>

              <label className="payment-modal-field">
                <span>API Key</span>
                <input type="text" placeholder="Enter API key" />
              </label>

              <div className="payment-modal-actions">
                <button
                  type="button"
                  className="payment-modal-secondary-button"
                  onClick={() => setIsModalOpen(false)}
                >
                  Cancel
                </button>
                <button type="button" className="payment-modal-primary-button">
                  Save Gateway
                </button>
              </div>
            </form>
          </div>
        </div>
      ) : null}
    </>
  );
}

export function SmsOtpSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  const [showSecurityKey, setShowSecurityKey] = useState(false);
  const [sendButtonLabel, setSendButtonLabel] = useState("Sent OTP");
  const [showAllLogs, setShowAllLogs] = useState(false);
  const visibleLogs = showAllLogs ? recentLogs : recentLogs.slice(0, 2);

  return (
    <section className="sms-settings-page" id={sectionId}>
      <article className="sms-settings-hero">
        <div className="sms-settings-icon" aria-hidden="true">
          <svg viewBox="0 0 24 24">
            <path
              d="M5 6h14v10H9l-4 3V6Z"
              fill="none"
              stroke="currentColor"
              strokeWidth="1.9"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
            <path d="M8 10h8" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
            <path d="M8 13h5" fill="none" stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" />
          </svg>
        </div>

        <div className="sms-settings-copy">
          <h2>SMS & OTP Settings</h2>
          <p>Manage SMS provider, API key, sender ID & OTP configuration settings.</p>
          <SectionAnchorAction href={heroLinkHref} label="Config Settings" />
        </div>
      </article>

      <div className="sms-settings-grid">
        <article className="sms-settings-card">
          <div className="sms-settings-card-header">
            <h2>SMS service provider settings</h2>
          </div>

          <div className="sms-settings-form-grid">
            <label className="sms-field sms-field-full">
              <span>Select a problem service provider</span>
              <div className="sms-provider-row">
                <select defaultValue="Others service provider (custom)">
                  <option>Others service provider (custom)</option>
                  <option>bKash SMS</option>
                  <option>Nagad SMS</option>
                </select>
                <StatusBadge label="Active" />
              </div>
            </label>

            <label className="sms-field sms-field-full">
              <span>API URL</span>
              <input defaultValue="https://api.smsprovider.com/send" />
            </label>

            <label className="sms-field sms-field-full">
              <span>API Key</span>
              <input defaultValue="sk_live_5ld487xxxxxxxxxxxxxx" />
            </label>

            <label className="sms-field sms-field-full">
              <span>API security Key</span>
              <div className="sms-password-field">
                <input defaultValue="sk_live_5ld487xxxxxxxxxxxxxx" type={showSecurityKey ? "text" : "password"} />
                <button
                  type="button"
                  className="sms-password-eye"
                  aria-label={showSecurityKey ? "Hide secret" : "Show secret"}
                  onClick={() => setShowSecurityKey((current) => !current)}
                >
                  {showSecurityKey ? "🙈" : "👁"}
                </button>
              </div>
            </label>

            <label className="sms-field sms-field-full">
              <span>Sender ID</span>
              <input defaultValue="MUDIERP" />
            </label>
            <p className="sms-field-note">Sender id can usually be 6-11 characters.</p>

            <label className="sms-field sms-field-full">
              <span>Default Language</span>
              <select defaultValue="Bangla">
                <option>Bangla</option>
                <option>English</option>
              </select>
            </label>
          </div>

          <div className="sms-info-callout">
            If the above information is not correct, there will be problems sending messages.
          </div>
        </article>

        <article className="sms-settings-card">
          <div className="sms-settings-card-header">
            <h2>OTP Setting</h2>
          </div>

          <div className="sms-settings-option-list">
            <div className="sms-option-row sms-option-row-inline sms-option-row-toggle">
              <div>
                <strong>Enable OTP</strong>
                <span>Use OTP User login, registration and other verification.</span>
              </div>
              <ToggleSwitch checked />
            </div>
            <div className="sms-option-row sms-option-row-inline">
              <div>
                <strong>The expiration date of the code is</strong>
              </div>
              <div className="sms-inline-input-group">
                <input className="sms-inline-input" defaultValue="5" />
                <span className="sms-inline-suffix">(Minute)</span>
              </div>
            </div>
            <div className="sms-option-row sms-option-row-inline">
              <div>
                <strong>The length of the code is</strong>
              </div>
              <input className="sms-inline-input" defaultValue="6" />
            </div>
            <div className="sms-option-row sms-option-row-inline">
              <div>
                <strong>Time to send the OTP again.</strong>
              </div>
              <div className="sms-inline-input-group">
                <input className="sms-inline-input" defaultValue="60" />
                <span className="sms-inline-suffix">(Second)</span>
              </div>
            </div>
            <div className="sms-option-row sms-option-row-inline">
              <div>
                <strong>How many times OTP can be sent</strong>
              </div>
              <div className="sms-inline-input-group">
                <input className="sms-inline-input" defaultValue="5" />
                <span className="sms-inline-suffix">(Time)</span>
              </div>
            </div>
          </div>

          <div className="sms-test-grid">
            <label className="sms-field sms-field-full">
              <span>Support Phone Number</span>
              <div className="sms-phone-field">
                <div className="sms-country-chip">
                  <span className="sms-flag">🇧🇩</span>
                  <select defaultValue="+880">
                    <option>+880</option>
                  </select>
                </div>
                <input defaultValue="1712-345678" />
              </div>
            </label>

            <div className="sms-radio-row sms-radio-row-boxed">
              <label>
                <input type="radio" name="send_type" defaultChecked />
                SMS Test
              </label>
              <label>
                <input type="radio" name="send_type" />
                OTP Test
              </label>
            </div>

            <button
              type="button"
              className="sms-send-button"
              onClick={() => {
                setSendButtonLabel("OTP Sent");
                window.setTimeout(() => setSendButtonLabel("Sent OTP"), 1200);
              }}
            >
              {sendButtonLabel}
            </button>
          </div>
        </article>
      </div>

      <article className="sms-settings-card">
        <div className="sms-settings-card-header">
          <h2>Recent SMS Logs</h2>
          <button
            type="button"
            className="sms-link-button"
            onClick={() => setShowAllLogs((current) => !current)}
          >
            {showAllLogs ? "Show fewer logs" : "View all logs"}
          </button>
        </div>

        <div className="sms-log-table">
          <div className="sms-log-head">
            <span>#</span>
            <span>Date & Time</span>
            <span>Mobile Number</span>
            <span>Message type</span>
            <span>Message</span>
            <span>Status</span>
            <span>Action</span>
          </div>

          {visibleLogs.map((log, index) => (
            <div className="sms-log-row" key={log.id}>
              <span>{index + 1}</span>
              <span>{log.date}</span>
              <span>{log.mobile}</span>
              <span>{log.type}</span>
              <span>{log.message}</span>
              <span>
                <StatusBadge label={log.status} />
              </span>
              <span>{log.note}</span>
            </div>
          ))}
        </div>
      </article>
    </section>
  );
}

export function NotificationSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="notification-settings-page" id={sectionId}>
      <article className="notification-settings-hero">
        <div className="notification-settings-icon">
          <NotificationIcon />
        </div>

        <div className="notification-settings-copy">
          <h2>Notification Settings</h2>
          <p>Configure various notifications, email alerts & system alert preferences.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="notification-settings-grid">
        <div className="notification-settings-left-column">
          <article className="notification-settings-card">
            <div className="notification-settings-card-header-simple">
              <h3>Notification Channel</h3>
              <p>Channels to which notifications will be sent</p>
            </div>

            <div className="notification-settings-list">
              {notificationChannels.map((channel) => (
                <div className="notification-settings-item" key={channel.id}>
                  <div className="notification-settings-item-main">
                    <div className={`notification-settings-item-icon notification-settings-item-icon-${channel.accent}`}>
                      <NotificationItemIcon type={channel.icon as "mail" | "message" | "mobile" | "bell"} />
                    </div>
                    <div className="notification-settings-item-copy">
                      <strong>{channel.title}</strong>
                      <span>{channel.description}</span>
                    </div>
                  </div>

                  <div className="notification-settings-item-actions">
                    <ToggleSwitch checked />
                    <NotificationFeedbackButton
                      className="notification-settings-config-button"
                      defaultLabel="configuration"
                      activeLabel="configured"
                    />
                  </div>
                </div>
              ))}
            </div>
          </article>

          <article className="notification-settings-card">
            <div className="notification-settings-card-header-simple">
              <h3>Notification Channel</h3>
              <p>Channels to which notifications will be sent</p>
            </div>

            <div className="notification-settings-list">
              <div className="notification-settings-item">
                <div className="notification-settings-item-main">
                  <div className="notification-settings-item-icon notification-settings-item-icon-green">
                    <NotificationItemIcon type="mail" />
                  </div>
                  <div className="notification-settings-item-copy">
                    <strong>Email Notification</strong>
                    <span>System emails and alerts can be sent.</span>
                  </div>
                </div>

                <div className="notification-settings-item-actions">
                  <ToggleSwitch checked />
                  <NotificationFeedbackButton
                    className="notification-settings-config-button"
                    defaultLabel="configuration"
                    activeLabel="configured"
                  />
                </div>
              </div>
            </div>
          </article>
        </div>

        <article className="notification-settings-card">
          <div className="notification-settings-card-header-simple">
            <h3>Notification Event Setting</h3>
            <p>Channels to which notifications will be sent</p>
          </div>

          <div className="notification-settings-event-list">
            {notificationEvents.map((event) => (
              <div className="notification-settings-item" key={event.id}>
                <div className="notification-settings-item-main">
                  <div className="notification-settings-item-icon notification-settings-item-icon-green">
                    <NotificationItemIcon type="bell" />
                  </div>
                  <div className="notification-settings-item-copy">
                    <strong>{event.title}</strong>
                    <span>{event.description}</span>
                  </div>
                </div>
                <ToggleSwitch checked />
              </div>
            ))}
          </div>
        </article>
      </div>

      <article className="notification-settings-card notification-settings-card-table">
        <div className="notification-settings-table-header">
          <div className="notification-settings-card-header-simple">
            <h3>Custom Notification Setting</h3>
            <p>Channels to which notifications will be sent</p>
          </div>

          <NotificationFeedbackButton
            className="notification-settings-primary-button"
            defaultLabel="+ New Notification"
            activeLabel="Created"
          />
        </div>

        <div className="notification-settings-table">
          <div className="notification-settings-table-head">
            <span>Name</span>
            <span>Event</span>
            <span>Chanel</span>
            <span>Status</span>
            <span>Action</span>
          </div>

          {customNotifications.map((item) => (
            <div className="notification-settings-table-row" key={item.id}>
              <span>{item.name}</span>
              <span>{item.event}</span>
              <span className="notification-settings-table-channels">
                <ChannelPill type="email" />
                <ChannelPill type="sms" />
                <ChannelPill type="app" />
              </span>
              <span>
                <em className="notification-settings-status-badge">{item.status}</em>
              </span>
              <span className="notification-settings-table-actions">
                <button type="button" className="notification-settings-icon-button notification-settings-icon-button-edit">
                  <NotificationActionIcon type="edit" />
                </button>
                <button type="button" className="notification-settings-icon-button notification-settings-icon-button-delete">
                  <NotificationActionIcon type="delete" />
                </button>
              </span>
            </div>
          ))}
        </div>

        <div className="notification-settings-footer-row">
          <NotificationFeedbackButton
            className="notification-settings-view-button"
            defaultLabel="View all"
            activeLabel="Opened"
          />
        </div>
      </article>

      <div className="notification-settings-actions">
        <NotificationFeedbackButton
          className="notification-settings-secondary-button"
          defaultLabel="Reset"
          activeLabel="Reset Done"
        />
        <NotificationFeedbackButton
          className="notification-settings-primary-button"
          defaultLabel="Save Change"
          activeLabel="Saved"
        />
      </div>
    </section>
  );
}

export function SubscriptionRuleSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="subscription-rule-settings-page" id={sectionId}>
      <article className="subscription-rule-settings-hero">
        <div className="subscription-rule-settings-hero-icon">
          <SubscriptionRuleSettingsIcon />
        </div>

        <div className="subscription-rule-settings-hero-copy">
          <h2>Subscription Rule Settings</h2>
          <p>Set payment cycle, auto-renewal, expiry rules &amp; invoice configurations.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="subscription-rule-settings-grid">
        <section className="subscription-rule-card">
          <div className="subscription-rule-card-header">
            <h3>Subscription Plan</h3>
          </div>

          <div className="subscription-plan-table">
            <div className="subscription-plan-table-head">
              <span>Plan name</span>
              <span>Duration</span>
              <span>Price</span>
              <span>Highest User</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {subscriptionPlanRows.map((plan) => (
              <div className="subscription-plan-table-row" key={plan.id}>
                <span>{plan.name}</span>
                <span>{plan.duration}</span>
                <span>{plan.price}</span>
                <span>{plan.users}</span>
                <span>
                  <em className="subscription-plan-status">Active</em>
                </span>
                <span className="subscription-plan-actions">
                  <button type="button" className="subscription-plan-icon-button subscription-plan-icon-button-edit">
                    <SubscriptionPlanActionIcon type="edit" />
                  </button>
                  <button type="button" className="subscription-plan-icon-button subscription-plan-icon-button-more">
                    <SubscriptionPlanActionIcon type="more" />
                  </button>
                </span>
              </div>
            ))}
          </div>

          <div className="subscription-plan-footer">
            <button type="button" className="subscription-plan-view-button">
              View all
            </button>
          </div>
        </section>

        <section className="subscription-rule-card">
          <div className="subscription-rule-card-header">
            <h3>Subscription rules</h3>
            <p>Set these general rules for subscriptions.</p>
          </div>

          <div className="subscription-rule-list">
            {subscriptionRuleItems.map((item) => (
              <article className="subscription-rule-row" key={item.id}>
                <div className="subscription-rule-row-main">
                  <div className={`subscription-rule-row-icon subscription-rule-row-icon-${item.accent}`}>
                    <SubscriptionRuleRowIcon type={item.icon} />
                  </div>

                  <div className="subscription-rule-row-copy">
                    <strong>{item.title}</strong>
                    <span>{item.description}</span>
                  </div>
                </div>

                <div className="subscription-rule-row-control">
                  {item.type === "toggle" ? <ToggleSwitch checked /> : null}
                  {item.type === "select" ? (
                    <label className="subscription-rule-select">
                      <select defaultValue={item.value}>
                        {item.options?.map((option) => (
                          <option key={option}>{option}</option>
                        ))}
                      </select>
                    </label>
                  ) : null}
                </div>
              </article>
            ))}
          </div>
        </section>
      </div>

      <div className="subscription-list-grid">
        <article className="subscription-list-card">
          <div className="subscription-list-card-header">
            <h3>Subscription List</h3>
          </div>

          <div className="subscription-list-table">
            <div className="subscription-list-table-head">
              <span>Customer Name</span>
              <span>Plan name</span>
              <span>Start Date</span>
              <span>End Date</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {subscriptionListRows.map((row) => (
              <div className="subscription-list-table-row" key={row.id}>
                <span>{row.customer}</span>
                <span>{row.plan}</span>
                <span>{row.startDate}</span>
                <span>{row.endDate}</span>
                <span>
                  <em className="subscription-list-status-badge">{row.status}</em>
                </span>
                <span className="subscription-list-actions">
                  <button type="button" className="subscription-list-action-button" aria-label={`View ${row.customer}`}>
                    <SubscriptionViewIcon />
                  </button>
                </span>
              </div>
            ))}
          </div>

          <div className="subscription-list-footer">
            <button type="button" className="subscription-list-view-button">
              View all
            </button>
          </div>
        </article>

        <aside className="subscription-summary-card">
          <div className="subscription-summary-card-header">
            <h3>Summary</h3>
          </div>

          <div className="subscription-summary-list">
            {subscriptionSummaryItems.map((item) => (
              <article key={item.id} className={`subscription-summary-item subscription-summary-item-${item.accent}`}>
                <div className={`subscription-summary-icon subscription-summary-icon-${item.accent}`}>
                  <SubscriptionSummaryIcon type={item.icon} />
                </div>
                <div className="subscription-summary-copy">
                  <strong>{item.label}</strong>
                  <span>{item.value}</span>
                </div>
              </article>
            ))}
          </div>
        </aside>
      </div>
    </section>
  );
}

export function PinSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="pin-settings-page" id={sectionId}>
      <article className="pin-settings-hero">
        <div className="pin-settings-hero-icon">
          <PinSettingsIcon />
        </div>

        <div className="pin-settings-hero-copy">
          <h2>Pin Settings</h2>
          <p>2FA, PIN usage, login security and authorization settings</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <section className="pin-settings-card">
        <div className="pin-settings-card-header">
          <h3>PIN management</h3>
          <p>Turn on auto backup configuration</p>
        </div>

        <div className="pin-settings-list">
          {pinManagementItems.map((item) => (
            <article className="pin-settings-row" key={item.id}>
              <div className="pin-settings-row-main">
                <div className={`pin-settings-row-icon pin-settings-row-icon-${item.accent}`}>
                  <PinManagementIcon type={item.icon} />
                </div>

                <div className="pin-settings-row-copy">
                  <strong>{item.title}</strong>
                  <span>{item.description}</span>
                </div>
              </div>

              <div className="pin-settings-row-control">
                {item.type === "toggle" ? <ToggleSwitch checked /> : null}
                {item.type === "metric" ? (
                  <div className="pin-settings-metric">
                    <label className="pin-settings-metric-input">
                      <input defaultValue={item.value} />
                    </label>
                    <span>{item.unit}</span>
                  </div>
                ) : null}
              </div>
            </article>
          ))}
        </div>
      </section>

      <div className="pin-settings-actions">
        <button type="button" className="pin-settings-secondary-button">
          Reset
        </button>
        <button type="button" className="pin-settings-primary-button">
          Save Change
        </button>
      </div>
    </section>
  );
}

export function ThemeSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="theme-settings-page" id={sectionId}>
      <article className="theme-settings-hero">
        <div className="theme-settings-hero-icon">
          <ThemeSettingsIcon />
        </div>

        <div className="theme-settings-hero-copy">
          <h2>System setting</h2>
          <p>Change everything here, from colors to fonts and logos, to your liking.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="theme-config-grid">
        <section className="theme-config-card">
          <div className="theme-config-card-header">
            <h3>Theme Customize</h3>
            <p>Adjust your brand colors, typography, and visual identity.</p>
          </div>

          <div className="theme-config-list">
            {themeColorItems.map((item) => (
              <article className="theme-config-row" key={item.id}>
                <div className="theme-config-row-copy">
                  <strong>{item.title}</strong>
                  <span>{item.description}</span>
                </div>

                <div className="theme-config-color-input">
                  <span className="theme-config-color-swatch" style={{ backgroundColor: item.swatch }} />
                  <span>{item.value}</span>
                  <button type="button" className="theme-config-icon-button" aria-label={`Edit ${item.title}`}>
                    <ThemeControlIcon type="edit" />
                  </button>
                </div>
              </article>
            ))}

            <article className="theme-config-row">
              <div className="theme-config-row-copy">
                <strong>Font Customize</strong>
                <span>Select the default font family used across your interface.</span>
              </div>

              <label className="theme-config-select">
                <select defaultValue="DM Sans">
                  <option>DM Sans</option>
                  <option>Inter</option>
                  <option>Poppins</option>
                  <option>Nunito Sans</option>
                </select>
              </label>
            </article>

            <article className="theme-config-row">
              <div className="theme-config-row-copy">
                <strong>Language Customize</strong>
                <span>Choose the default language shown across the admin interface.</span>
              </div>

              <label className="theme-config-select">
                <select defaultValue="English">
                  <option>English</option>
                  <option>Bangla</option>
                  <option>Arabic</option>
                  <option>Hindi</option>
                </select>
              </label>
            </article>
          </div>
        </section>

        <section className="theme-config-card">
          <div className="theme-config-card-header">
            <h3>Brand Assets</h3>
            <p>Upload the logo and favicon shown throughout the platform.</p>
          </div>

          <div className="theme-upload-stack">
            <article className="theme-upload-card">
              <div className="theme-upload-card-header">
                <strong>App Logo</strong>
              </div>

              <div className="theme-upload-card-body">
                <div className="theme-upload-preview">
                  <div className="theme-upload-preview-mark">
                    <ThemeControlIcon type="upload" />
                  </div>
                  <strong>MUDI ERP</strong>
                </div>

                <button type="button" className="theme-upload-button">
                  <ThemeControlIcon type="upload" />
                  Upload Change
                </button>
              </div>

              <small>PNG, JPG, SVG (Max. 2MB)</small>
            </article>

            <article className="theme-upload-card">
              <div className="theme-upload-card-header">
                <strong>Fedicon</strong>
              </div>

              <div className="theme-upload-card-body">
                <div className="theme-upload-preview theme-upload-preview-icon-only">
                  <div className="theme-upload-preview-mark">
                    <ThemeControlIcon type="upload" />
                  </div>
                </div>

                <button type="button" className="theme-upload-button">
                  <ThemeControlIcon type="upload" />
                  Upload Change
                </button>
              </div>

              <small>PNG, JPG, SVG, ICO (Max. 512KB)</small>
            </article>
          </div>
        </section>
      </div>

      <div className="theme-preview-grid">
        <section className="theme-config-card">
          <div className="theme-config-card-header">
            <h3>Live Preview</h3>
            <p>See a live preview of your theme.</p>
          </div>

          <div className="theme-preview-shell">
            <div className="theme-preview-stack">
              <section className="theme-preview-section">
                <div className="theme-preview-section-header">Sidebar Preview</div>
                <div className="theme-preview-sidebar">
                  <div className="theme-preview-sidebar-brand">MUDI ERP</div>
                  <div className="theme-preview-sidebar-item theme-preview-sidebar-item-active">Dashboard</div>
                  <div className="theme-preview-sidebar-item">Reports &amp; Analytics</div>
                  <div className="theme-preview-sidebar-item">Setting</div>
                </div>
              </section>

              <section className="theme-preview-section">
                <div className="theme-preview-section-header">KPI Cards Preview</div>
                <div className="theme-preview-kpi-grid">
                  {themePreviewStats.slice(0, 4).map((item) => (
                    <article className="theme-preview-kpi-card" key={item.id}>
                      <div className={`theme-preview-stat-icon theme-preview-stat-icon-${item.accent}`}>
                        <ThemePreviewIcon type={item.icon} />
                      </div>
                      <div className="theme-preview-stat-copy">
                        <span>{item.title}</span>
                        <strong>{item.value}</strong>
                      </div>
                    </article>
                  ))}
                </div>
              </section>

              <section className="theme-preview-section">
                <div className="theme-preview-section-header">Button Preview</div>
                <div className="theme-preview-button-row">
                  <button type="button" className="theme-preview-toolbar-button">
                    <ThemePreviewIcon type="export" />
                    Export
                  </button>
                  <button type="button" className="theme-preview-toolbar-button theme-preview-toolbar-button-primary">
                    Add New Product
                    <ThemePreviewIcon type="plus" />
                  </button>
                </div>
              </section>

              <section className="theme-preview-section">
                <div className="theme-preview-section-header">Badge Preview</div>
                <div className="theme-preview-badge-row">
                  <span className="theme-preview-badge theme-preview-badge-success">Active</span>
                  <span className="theme-preview-badge theme-preview-badge-warning">Pending</span>
                  <span className="theme-preview-badge theme-preview-badge-danger">Inactive</span>
                </div>
              </section>

              <section className="theme-preview-section">
                <div className="theme-preview-section-header">Table Preview</div>
                <div className="theme-preview-table">
                  <div className="theme-preview-table-head">
                    <span>Product</span>
                    <span>Status</span>
                    <span>Action</span>
                  </div>
                  <div className="theme-preview-table-row">
                    <span>Miniket Rice 25KG</span>
                    <span className="theme-preview-table-status">Active</span>
                    <span>Edit</span>
                  </div>
                  <div className="theme-preview-table-row">
                    <span>Soybean Oil 5L</span>
                    <span className="theme-preview-table-status">Pending</span>
                    <span>View</span>
                  </div>
                </div>
              </section>
            </div>
          </div>
        </section>

        <section className="theme-config-card theme-quick-card">
          <div className="theme-config-card-header">
            <h3>Quick Action</h3>
            <p>Save changes or quickly restore the default theme setup.</p>
          </div>

          <div className="theme-quick-actions">
            <button type="button" className="theme-quick-button theme-quick-button-primary">
              <ThemePreviewIcon type="save" />
              Save and changes
            </button>
            <button type="button" className="theme-quick-button">
              <ThemePreviewIcon type="refresh" />
              Apply default theme
            </button>
            <button type="button" className="theme-quick-button">
              <ThemePreviewIcon type="refresh" />
              Button
            </button>
          </div>
        </section>
      </div>
    </section>
  );
}

export function BackupSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="backup-settings-page" id={sectionId}>
      <article className="backup-settings-hero">
        <div className="backup-settings-hero-icon">
          <BackupSettingsIcon />
        </div>

        <div className="backup-settings-hero-copy">
          <h2>Backup Settings</h2>
          <p>Configure auto backup, cloud backup, database export &amp; restore options.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="backup-config-grid">
        <section className="backup-config-card">
          <div className="backup-config-card-header">
            <h3>Backup configuration</h3>
            <p>Turn on auto backup configuration</p>
          </div>

          <div className="backup-config-list">
            {backupConfigItems.map((item) => (
              <article className="backup-config-row" key={item.id}>
                <div className="backup-config-row-main">
                  <div className="backup-config-row-icon">
                    <BackupRowIcon type={item.icon} />
                  </div>

                  <div className="backup-config-row-copy">
                    <strong>{item.title}</strong>
                    <span>{item.description}</span>
                  </div>
                </div>

                <div className="backup-config-row-control">
                  {item.type === "toggle" ? <ToggleSwitch checked /> : null}
                  {item.type === "select" ? (
                    <label className="backup-config-select">
                      <select defaultValue={item.value}>
                        {item.options?.map((option) => <option key={option}>{option}</option>)}
                      </select>
                    </label>
                  ) : null}
                  {item.type === "time" ? (
                    <label className="backup-config-time">
                      <input defaultValue={item.value} />
                      <span className="backup-config-time-icon">
                        <BackupRowIcon type="clock" />
                      </span>
                    </label>
                  ) : null}
                </div>
              </article>
            ))}
          </div>
        </section>

        <section className="backup-config-card">
          <div className="backup-config-card-header">
            <h3>Backup configuration</h3>
            <p>Turn on auto backup configuration</p>
          </div>

          <div className="backup-config-action-list">
            {backupActionItems.map((item) => (
              <article className="backup-config-action-row" key={item.id}>
                <div className="backup-config-row-main">
                  <div className="backup-config-row-icon backup-config-row-icon-violet">
                    <BackupRowIcon type={item.icon} />
                  </div>

                  <div className="backup-config-row-copy">
                    <strong>{item.title}</strong>
                    <span>{item.description}</span>
                  </div>
                </div>

                <button type="button" className="backup-config-action-button">
                  <span className="backup-config-action-button-icon">
                    <BackupRowIcon type="upload" />
                  </span>
                  {item.buttonLabel}
                </button>
              </article>
            ))}

            <article className="backup-config-note">
              <div className="backup-config-row-icon backup-config-row-icon-blue">
                <BackupRowIcon type="info" />
              </div>

              <div className="backup-config-note-copy">
                <strong>Note</strong>
                <span>Resetting will delete daily data. Please reset carefully.</span>
              </div>
            </article>
          </div>
        </section>
      </div>

      <section className="backup-config-card">
        <div className="backup-config-card-header">
          <h3>Recently Backup List</h3>
        </div>

        <div className="backup-history-table">
          <div className="backup-history-table-head">
            <span>Date and Time</span>
            <span>File name</span>
            <span>Size</span>
            <span>Type</span>
            <span>Status</span>
            <span>Action</span>
          </div>

          {recentBackupRows.map((item) => (
            <div className="backup-history-table-row" key={item.id}>
              <span>{item.dateTime}</span>
              <span>{item.fileName}</span>
              <span>{item.size}</span>
              <span>{item.type}</span>
              <span>
                <em className="backup-history-status">{item.status}</em>
              </span>
              <span className="backup-history-actions">
                <button type="button" className="backup-history-action backup-history-action-view">
                  <BackupActionIcon type="view" />
                </button>
                <button type="button" className="backup-history-action backup-history-action-download">
                  <BackupActionIcon type="download" />
                </button>
                <button type="button" className="backup-history-action backup-history-action-delete">
                  <BackupActionIcon type="delete" />
                </button>
              </span>
            </div>
          ))}
        </div>

        <div className="backup-history-footer">
          <button type="button" className="backup-history-view-button">
            View all
          </button>
        </div>
      </section>
    </section>
  );
}

export function TaxVatSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="tax-vat-settings-page" id={sectionId}>
      <article className="tax-vat-settings-hero">
        <div className="tax-vat-settings-hero-icon">
          <TaxVatSettingsIcon />
        </div>

        <div className="tax-vat-settings-hero-copy">
          <h2>TAX and VAT Settings</h2>
          <p>TAX Rate, VAT Rate, TAX Number</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="tax-vat-settings-grid">
        <section className="tax-vat-card">
          <div className="tax-vat-card-header tax-vat-card-header-inline">
            <h3>TAX and VAT Rate List</h3>
            <button type="button" className="tax-vat-add-button">
              <span aria-hidden="true">+</span>
              Add New TAX / VAT
            </button>
          </div>

          <div className="tax-vat-table">
            <div className="tax-vat-table-head">
              <span>Name</span>
              <span>Type</span>
              <span>Rate</span>
              <span>Status</span>
              <span>Action</span>
            </div>

            {taxVatRateRows.map((row) => (
              <div className="tax-vat-table-row" key={row.id}>
                <span>{row.name}</span>
                <span>{row.type}</span>
                <span>{row.rate}</span>
                <span>
                  <em className={`tax-vat-status-badge tax-vat-status-badge-${row.status.toLowerCase()}`}>
                    {row.status}
                  </em>
                </span>
                <span className="tax-vat-table-actions">
                  <button type="button" className="tax-vat-icon-button tax-vat-icon-button-edit" aria-label={`Edit ${row.name}`}>
                    <TaxVatActionIcon type="edit" />
                  </button>
                  <button type="button" className="tax-vat-icon-button tax-vat-icon-button-delete" aria-label={`Delete ${row.name}`}>
                    <TaxVatActionIcon type="delete" />
                  </button>
                </span>
              </div>
            ))}
          </div>
        </section>

        <section className="tax-vat-card">
          <div className="tax-vat-card-header">
            <h3>TAX and VAT Settings</h3>
            <p>TAX and VAT Related General Settings</p>
          </div>

          <div className="tax-vat-form-grid">
            {taxVatSettingsFields.map((field) => (
              <div className="tax-vat-form-group" key={field.id}>
                {field.type === "toggle" ? (
                  <div className="tax-vat-form-toggle-row">
                    <div className="tax-vat-form-toggle-copy">
                      <strong>{field.label}</strong>
                    </div>
                    <ToggleSwitch checked />
                  </div>
                ) : (
                  <>
                    <label className="tax-vat-form-label">{field.label}</label>
                    {field.type === "select" ? (
                      <label className="tax-vat-select">
                        <select defaultValue={field.value}>
                          {field.options?.map((option) => (
                            <option key={option}>{option}</option>
                          ))}
                        </select>
                      </label>
                    ) : null}
                    {field.type === "input" ? (
                      <label className="tax-vat-input">
                        <input defaultValue={field.value} />
                      </label>
                    ) : null}
                  </>
                )}
              </div>
            ))}
          </div>
        </section>
      </div>

      <div className="tax-vat-settings-grid tax-vat-settings-grid-secondary">
        <section className="tax-vat-card">
          <div className="tax-vat-card-header">
            <h3>TAX and VAT Apply Settings</h3>
            <p>Determine Where VAT/TAX Will Apply</p>
          </div>

          <div className="tax-vat-apply-list">
            {taxVatApplyItems.map((item) => (
              <article className="tax-vat-apply-item" key={item.id}>
                <span className="tax-vat-apply-icon" aria-hidden="true">
                  <TaxVatApplyCheckIcon />
                </span>
                <strong>{item.label}</strong>
              </article>
            ))}
          </div>
        </section>

        <section className="tax-vat-card">
          <div className="tax-vat-card-header">
            <h3>TAX and VAT Number</h3>
            <p>Add Your Business TAX and VAT Number</p>
          </div>

          <div className="tax-vat-number-grid">
            {taxVatNumberFields.map((field) => (
              <div className="tax-vat-form-group" key={field.id}>
                <label className="tax-vat-form-label">{field.label}</label>
                <label className="tax-vat-select">
                  <select defaultValue={field.value}>
                    {field.options?.map((option) => (
                      <option key={option}>{option}</option>
                    ))}
                  </select>
                </label>
              </div>
            ))}

            <div className="tax-vat-number-action">
              <button type="button" className="tax-vat-update-button">
                <TaxVatUpdateIcon />
                Update Information
              </button>
            </div>
          </div>
        </section>
      </div>
    </section>
  );
}

export function ActivityLogSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="activity-log-settings-page" id={sectionId}>
      <article className="activity-log-settings-hero">
        <div className="activity-log-settings-hero-icon">
          <ActivityLogSettingsIcon />
        </div>

        <div className="activity-log-settings-hero-copy">
          <h2>Activity Log Settings</h2>
          <p>System Log, User Log, API Log and</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <section className="activity-log-filter-card">
        <div className="activity-log-card-header">
          <h3>Log Filter</h3>
        </div>

        <div className="activity-log-filter-grid">
          {activityLogFilters.map((field) => (
            <div className="activity-log-filter-field" key={field.id}>
              <label htmlFor={field.id}>{field.label}</label>
              <label className="activity-log-select" htmlFor={field.id}>
                <select id={field.id} defaultValue={field.value}>
                  {field.options.map((option) => (
                    <option key={option}>{option}</option>
                  ))}
                </select>
              </label>
            </div>
          ))}

          <div className="activity-log-filter-field">
            <label htmlFor="activity-log-start">Starting Date</label>
            <div className="activity-log-date-input">
              <input id="activity-log-start" type="text" defaultValue="01/05/2026" />
            </div>
          </div>

          <div className="activity-log-filter-field">
            <label htmlFor="activity-log-end">Ending Date</label>
            <div className="activity-log-date-input">
              <input id="activity-log-end" type="text" defaultValue="31/05/2026" />
            </div>
          </div>

          <div className="activity-log-filter-action">
            <button type="button" className="activity-log-search-button">
              Search
            </button>
          </div>
        </div>
      </section>

      <section className="activity-log-list-card">
        <div className="activity-log-list-header">
          <h3>Activity Log List</h3>
          <button type="button" className="activity-log-export-button">
            <ActivityLogExportIcon />
            Export
          </button>
        </div>

        <div className="activity-log-table">
          <div className="activity-log-table-head">
            <span>Date and Time</span>
            <span>User</span>
            <span>Module</span>
            <span>Action</span>
            <span>Details</span>
            <span>IP Address</span>
            <span>Browser</span>
            <span>Status</span>
          </div>

          {activityLogRows.map((row) => (
            <div className="activity-log-table-row" key={row.id}>
              <span>{row.dateTime}</span>

              <span className="activity-log-user-cell">
                <span className="activity-log-user-avatar" aria-hidden="true">
                  <ActivityLogUserAvatarIcon />
                </span>
                <span className="activity-log-user-copy">
                  <strong>{row.user}</strong>
                  <small>({row.handle})</small>
                </span>
              </span>

              <span className="activity-log-module-cell">
                <span className="activity-log-module-icon" aria-hidden="true">
                  <ActivityLogModuleIcon type={row.moduleType} />
                </span>
                <span>{row.module}</span>
              </span>

              <span>
                <em className={`activity-log-action-badge activity-log-action-badge-${row.actionType}`}>{row.action}</em>
              </span>

              <span>{row.details}</span>
              <span>{row.ipAddress}</span>

              <span className="activity-log-browser-cell">
                <span className="activity-log-browser-icon" aria-hidden="true">
                  <ActivityLogBrowserIcon type={row.browserType} />
                </span>
                <span>{row.browser}</span>
              </span>

              <span>
                <em className={`activity-log-status-badge activity-log-status-badge-${row.statusType}`}>{row.status}</em>
              </span>
            </div>
          ))}
        </div>
      </section>
    </section>
  );
}

export function ShopRegistrationSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="shop-registration-settings-page" id={sectionId}>
      <article className="shop-registration-settings-hero">
        <div className="shop-registration-settings-hero-icon">
          <ShopRegistrationSettingsIcon />
        </div>

        <div className="shop-registration-settings-hero-copy">
          <h2>Shop Registration Setting</h2>
          <p>Shop Registration Procedure and Verification Requirement Setting</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="shop-registration-settings-grid">
        <section className="shop-registration-card">
          <div className="shop-registration-card-header">
            <h3>Security Settings</h3>
          </div>

          <div className="shop-registration-option-list">
            {shopRegistrationWorkflowOptions.map((option) => (
              <div className="shop-registration-option-item" key={option.id}>
                <span
                  className={`shop-registration-option-icon${option.selected ? " shop-registration-option-icon-active" : ""}`}
                  aria-hidden="true"
                >
                  <ShopRegistrationRadioIcon selected={option.selected} />
                </span>

                <div className="shop-registration-option-copy">
                  <strong>{option.title}</strong>
                  <span>{option.description}</span>
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className="shop-registration-card">
          <div className="shop-registration-card-header">
            <h3>Security Settings</h3>
          </div>

          <div className="shop-registration-rule-list">
            {shopRegistrationSecurityRules.map((rule) => (
              <div className="shop-registration-rule-item" key={rule.id}>
                <div className="shop-registration-rule-copy">
                  <strong>{rule.title}</strong>
                  <span>{rule.description}</span>
                </div>

                <ToggleSwitch checked={rule.enabled} />
              </div>
            ))}
          </div>
        </section>

        <section className="shop-registration-card">
          <div className="shop-registration-card-header">
            <h3>Security Settings</h3>
          </div>

          <div className="shop-registration-document-list">
            {shopRegistrationRequiredDocuments.map((item) => (
              <div className="shop-registration-document-item" key={item.id}>
                <span className="shop-registration-document-icon" aria-hidden="true">
                  <ShopRegistrationCheckIcon />
                </span>

                <div className="shop-registration-document-copy">
                  <strong>{item.title}</strong>
                  <span>{item.description}</span>
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>

      <section className="shop-registration-card shop-registration-document-table-card">
        <div className="shop-registration-card-header shop-registration-card-header-inline">
          <h3>Document Management</h3>
          <button type="button" className="shop-registration-add-button">
            <span aria-hidden="true">+</span>
            Add New Document
          </button>
        </div>

        <div className="shop-registration-document-table">
          <div className="shop-registration-document-table-head">
            <span>Document name</span>
            <span>File Type</span>
            <span>Highest file size</span>
            <span>Status</span>
            <span>IP Address</span>
          </div>

          {shopRegistrationDocumentRows.map((row) => (
            <div className="shop-registration-document-table-row" key={row.id}>
              <span className="shop-registration-document-name-cell">
                <span className="shop-registration-document-file-icon" aria-hidden="true">
                  <ShopRegistrationCheckIcon />
                </span>
                <span>{row.name}</span>
              </span>
              <span>{row.fileType}</span>
              <span>{row.size}</span>
              <span>
                <em className="shop-registration-document-status-badge">{row.status}</em>
              </span>
              <span className="shop-registration-document-actions">
                <button type="button" className="inventory-unit-action-button inventory-unit-action-button-edit" aria-label={`Edit ${row.name}`}>
                  <UnitActionIcon type="edit" />
                </button>
                <button type="button" className="inventory-unit-action-button inventory-unit-action-button-delete" aria-label={`Delete ${row.name}`}>
                  <UnitActionIcon type="delete" />
                </button>
              </span>
            </div>
          ))}
        </div>

        <div className="shop-registration-document-footer">
          <button type="button" className="shop-registration-view-button">
            View all
          </button>
        </div>
      </section>
    </section>
  );
}

export function SecuritySettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="security-settings-page" id={sectionId}>
      <article className="security-settings-hero">
        <div className="security-settings-hero-icon">
          <SecuritySettingsIcon />
        </div>

        <div className="security-settings-hero-copy">
          <h2>Security Settings</h2>
          <p>Set up 2FA, login alerts, session timeout &amp; IP restriction rules.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <section className="security-settings-card">
        <div className="security-settings-card-header">
          <h3>Security Settings</h3>
        </div>

        <div className="security-settings-grid">
          {securitySettingCards.map((item) => (
            <article className="security-setting-item" key={item.id}>
              <div className="security-setting-item-top">
                <div className="security-setting-item-main">
                  <div className="security-setting-item-icon">
                    <SecurityCardIcon type={item.icon} />
                  </div>

                  <div className="security-setting-item-copy">
                    <strong>{item.title}</strong>
                    <span>{item.description}</span>
                  </div>
                </div>

                <ToggleSwitch checked={item.enabled} />
              </div>

              {item.footerType === "button" ? (
                <button type="button" className="security-setting-footer-button">
                  <span>{item.footerLabel}</span>
                  <span className="security-setting-footer-arrow">›</span>
                </button>
              ) : null}

              {item.footerType === "select" ? (
                <label className="security-setting-select">
                  <select defaultValue={item.footerLabel}>
                    <option>{item.footerLabel}</option>
                  </select>
                </label>
              ) : null}
            </article>
          ))}
        </div>
      </section>

      <section className="security-settings-card">
        <div className="security-settings-card-header">
          <h3>Recent Security Activity</h3>
        </div>

        <div className="security-activity-table">
          <div className="security-activity-table-head">
            <span>Date and Time</span>
            <span>User</span>
            <span>Activities</span>
            <span>Details</span>
            <span>IP Address</span>
            <span>Status</span>
          </div>

          {securityActivityRows.map((item) => (
            <div className="security-activity-table-row" key={item.id}>
              <span>{item.dateTime}</span>

              <div className="security-activity-user">
                <div className="security-activity-avatar" aria-hidden="true">
                  <svg viewBox="0 0 24 24">
                    <circle cx="12" cy="8" r="4" />
                    <path d="M4.5 20a7.5 7.5 0 0 1 15 0" />
                  </svg>
                </div>
                <div className="security-activity-user-copy">
                  <strong>{item.user}</strong>
                  <span>({item.role})</span>
                </div>
              </div>

              <span className="security-activity-event">
                <span className={`security-activity-event-icon security-activity-event-icon-${item.activityType}`}>
                  <SecurityActivityIcon type={item.activityType} />
                </span>
                <span>{item.activity}</span>
              </span>

              <span>{item.details}</span>
              <span>{item.ipAddress}</span>
              <span>
                <em className={`security-activity-status security-activity-status-${item.statusType}`}>{item.status}</em>
              </span>
            </div>
          ))}
        </div>

        <div className="security-activity-footer">
          <button type="button" className="security-activity-view-button">
            View all
          </button>
        </div>
      </section>
    </section>
  );
}

export function InventoryRuleSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="inventory-rule-page" id={sectionId}>
      <article className="inventory-rule-hero">
        <div className="inventory-rule-hero-icon">
          <InventoryRuleIcon />
        </div>

        <div className="inventory-rule-hero-copy">
          <h2>Inventory Rule Settings</h2>
          <p>Set negative stock, barcode, duplicate product &amp; inventory rules.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <section className="inventory-rule-card">
        <div className="inventory-rule-card-header">
          <h3>Inventory Rules</h3>
          <p>Configure inventory behavior, validation, and stock control settings.</p>
        </div>

        <div className="inventory-rule-category-row">
          <span className="inventory-rule-category-pill">Validation Rules</span>
          <span className="inventory-rule-category-pill">Stock Rules</span>
          <span className="inventory-rule-category-pill">Product Rules</span>
        </div>

        <div className="inventory-rule-grid">
          {inventoryRuleItems.map((item) => (
            <article
              className={`inventory-rule-item${item.accent === "warning" ? " inventory-rule-item-warning" : ""}`}
              key={item.id}
            >
              <div className="inventory-rule-item-main">
                <div className={`inventory-rule-item-icon inventory-rule-item-icon-${item.accent}`}>
                  <InventoryRuleItemIcon type={item.icon} />
                </div>

                <div className="inventory-rule-item-copy">
                  <div className="inventory-rule-item-heading">
                    <strong>{item.title}</strong>
                    <span className="inventory-rule-help-chip" title={item.helpText}>
                      i
                    </span>
                  </div>
                  <span>{item.description}</span>
                  <em className="inventory-rule-category-label">{item.category}</em>
                </div>
              </div>

              <div className="inventory-rule-item-actions">
                {item.field ? null : <ToggleSwitch checked={item.enabled} />}
                {item.field === "select" ? (
                  <label className="inventory-rule-select">
                    <select defaultValue={item.fieldValue}>
                      {item.options?.map((option) => <option key={option}>{option}</option>)}
                    </select>
                  </label>
                ) : null}
                {item.field === "input" ? (
                  <label
                    className={`inventory-rule-input${
                      item.id === "low-stock-limit" ? " inventory-rule-input-compact" : ""
                    }`}
                  >
                    <input defaultValue={item.fieldValue} inputMode="numeric" />
                  </label>
                ) : null}
              </div>
            </article>
          ))}
        </div>

        <div className="inventory-rule-save-bar">
          <div className="inventory-rule-save-copy">
            <strong>Save status</strong>
            <span>Changes are ready to save. Risky rules stay highlighted for review.</span>
          </div>
          <button type="button" className="inventory-rule-save-button">
            Save Changes
          </button>
        </div>
      </section>

      <section className="inventory-rule-card">
        <div className="inventory-rule-card-header inventory-rule-card-header-inline">
          <div>
            <h3>Unit Management</h3>
            <p>Product map and unit quantity</p>
          </div>

          <button type="button" className="inventory-rule-add-button">
            + Add New Unit
          </button>
        </div>

        <div className="inventory-unit-table">
          <div className="inventory-unit-table-head">
            <span>Unit name</span>
            <span>Shortcut</span>
            <span>Type</span>
            <span>Status</span>
            <span>Action</span>
          </div>

          {inventoryUnits.map((unit) => (
            <div className="inventory-unit-table-row" key={unit.id}>
              <span>{unit.name}</span>
              <span>{unit.shortcut}</span>
              <span>{unit.type}</span>
              <span>
                <em className="inventory-unit-status-badge">{unit.status}</em>
              </span>
              <span className="inventory-unit-actions">
                <button type="button" className="inventory-unit-action-button inventory-unit-action-button-edit">
                  <UnitActionIcon type="edit" />
                </button>
                <button type="button" className="inventory-unit-action-button inventory-unit-action-button-delete">
                  <UnitActionIcon type="delete" />
                </button>
              </span>
            </div>
          ))}
        </div>

        <div className="inventory-unit-footer">
          <p>Product map and unit quantity</p>
          <button type="button" className="inventory-unit-view-button">
            View all
          </button>
        </div>
      </section>
    </section>
  );
}

export function RolePermissionSettingsSection({
  sectionId,
  heroLinkHref,
}: {
  sectionId?: string;
  heroLinkHref?: string;
}) {
  return (
    <section className="role-permission-settings-page" id={sectionId}>
      <article className="role-permission-settings-hero">
        <div className="role-permission-settings-hero-icon">
          <RolePermissionSettingsIcon />
        </div>

        <div className="role-permission-settings-hero-copy">
          <h2>Role &amp; Permission Settings</h2>
          <p>Manage admin &amp; staff roles, permissions &amp; access control settings.</p>
          <SectionAnchorAction href={heroLinkHref} label="Configure Settings" />
        </div>
      </article>

      <div className="role-permission-settings-grid">
        <section className="role-permission-card">
          <div className="role-permission-card-header">
            <h3>Role Management</h3>
          </div>

          <div className="role-permission-table">
            <div className="role-permission-table-head">
              <span>Role name</span>
              <span>Explain</span>
              <span>User Number</span>
              <span>Action</span>
            </div>

            {roleManagementRows.map((role) => (
              <div className="role-permission-table-row" key={role.id}>
                <span>{role.name}</span>
                <span>{role.explain}</span>
                <span>{role.users}</span>
                <span className="role-permission-table-actions">
                  <button type="button" className="role-permission-icon-button role-permission-icon-button-edit" aria-label={`Edit ${role.name}`}>
                    <RoleManagementActionIcon type="edit" />
                  </button>
                  <button type="button" className="role-permission-icon-button role-permission-icon-button-more" aria-label={`More actions for ${role.name}`}>
                    <RoleManagementActionIcon type="more" />
                  </button>
                </span>
              </div>
            ))}
          </div>

          <div className="role-permission-table-footer">
            <button type="button" className="role-permission-view-button">
              View all role
            </button>
          </div>
        </section>

        <aside className="role-permission-side-card">
          <div className="role-permission-side-header">
            <h3>Permissions and Access Control</h3>
            <p>Permissions and Access Control</p>
          </div>

          <div className="role-permission-list">
            {rolePermissionItems.map((item) => (
              <article className="role-permission-item" key={item.id}>
                <div className="role-permission-item-main">
                  <div className="role-permission-item-icon">
                    <RolePermissionItemIcon />
                  </div>
                  <div className="role-permission-item-copy">
                    <strong>{item.label}</strong>
                    <span>Auto backup will stop after a day or so.</span>
                  </div>
                </div>
                <button type="button" className="role-permission-chevron-button" aria-label={`Open ${item.label}`}>
                  <RolePermissionChevronIcon />
                </button>
              </article>
            ))}
          </div>

          <button type="button" className="role-permission-configure-button">
            Configure permissions
          </button>
        </aside>
      </div>

      <section className="role-user-card">
        <div className="role-user-card-header">
          <h3>List of users by role</h3>
          <p>See how many users are in a role</p>
        </div>

        <div className="role-user-list">
          {roleUsersByRoleItems.map((item) => (
            <article key={item.id} className="role-user-item">
              <div className={`role-user-item-icon role-user-item-icon-${item.accent}`}>
                <RoleUserBadgeIcon />
              </div>
              <div className="role-user-item-copy">
                <strong>{item.role}</strong>
                <span>{item.count}</span>
                <small>User</small>
              </div>
            </article>
          ))}
        </div>

        <div className="role-user-footer">
          <button type="button" className="role-user-view-button">
            See all user
          </button>
        </div>
      </section>
    </section>
  );
}
