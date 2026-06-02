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
  return (
    <div className="general-settings-toggle-row">
      <div className="general-settings-toggle-copy">
        <strong>{label}</strong>
        {description ? <span>{description}</span> : null}
      </div>
      <button
        type="button"
        className={`general-settings-toggle${checked ? " general-settings-toggle-active" : ""}`}
        aria-pressed={checked}
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

function ToggleSwitch({ checked = true }: { checked?: boolean }) {
  return (
    <button type="button" className={`sms-toggle${checked ? " sms-toggle-active" : ""}`} aria-pressed={checked}>
      <span />
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

                <div className="payment-gateway-status">
                  <span
                    className={`payment-gateway-badge${
                      gateway.enabled ? " payment-gateway-badge-active" : " payment-gateway-badge-inactive"
                    }`}
                  >
                    {gateway.status}
                  </span>
                  <button
                    type="button"
                    className={`payment-gateway-toggle${gateway.enabled ? " payment-gateway-toggle-active" : ""}`}
                    aria-pressed={gateway.enabled}
                  >
                    <span />
                  </button>
                </div>

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
                <input defaultValue="********************" type="password" />
                <button type="button" className="sms-password-eye" aria-label="Show secret">
                  👁
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

            <button type="button" className="sms-send-button">
              Sent OTP
            </button>
          </div>
        </article>
      </div>

      <article className="sms-settings-card">
        <div className="sms-settings-card-header">
          <h2>Recent SMS Logs</h2>
          <button type="button" className="sms-link-button">
            View all logs
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

          {recentLogs.map((log, index) => (
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
                    <button type="button" className="notification-settings-config-button">
                      configuration
                    </button>
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
                  <button type="button" className="notification-settings-config-button">
                    configuration
                  </button>
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

          <button type="button" className="notification-settings-primary-button">
            + New Notification
          </button>
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
          <button type="button" className="notification-settings-view-button">
            View all
          </button>
        </div>
      </article>

      <div className="notification-settings-actions">
        <button type="button" className="notification-settings-secondary-button">
          Reset
        </button>
        <button type="button" className="notification-settings-primary-button">
          Save Change
        </button>
      </div>
    </section>
  );
}
