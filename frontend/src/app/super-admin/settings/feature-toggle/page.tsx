"use client";

import { useState } from "react";

const featureRows = [
  { id: "gateway", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "chart", enabled: true },
  { id: "sales", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "cart", enabled: true },
  { id: "users", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "users", enabled: true },
  { id: "mail-1", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "mail", enabled: false },
  { id: "mail-2", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "mail", enabled: true },
  { id: "mail-3", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "mail", enabled: false },
  { id: "mail-4", name: "Nagad", description: "Nagad Get inspired by payment gateways", icon: "mail", enabled: true },
];

function FeatureToggleHeroIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <rect
        x="3"
        y="7"
        width="18"
        height="10"
        rx="5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
      />
      <circle
        cx="9"
        cy="12"
        r="3"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
      />
    </svg>
  );
}

function FeatureRowIcon({ type }: { type: string }) {
  const commonProps = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  switch (type) {
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
    case "users":
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <path {...commonProps} d="M9 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
          <path {...commonProps} d="M15.5 10a2.5 2.5 0 1 0 0-5" />
          <path {...commonProps} d="M4.5 19a4.5 4.5 0 0 1 9 0" />
          <path {...commonProps} d="M14.5 18a3.5 3.5 0 0 1 5-2.3" />
        </svg>
      );
    default:
      return (
        <svg aria-hidden="true" viewBox="0 0 24 24">
          <rect {...commonProps} x="4" y="6" width="16" height="12" rx="2" />
          <path {...commonProps} d="m5.5 7.5 6.5 5 6.5-5" />
        </svg>
      );
  }
}

function FeatureToggleRow({
  feature,
}: {
  feature: (typeof featureRows)[number];
}) {
  const [isEnabled, setIsEnabled] = useState(feature.enabled);

  return (
    <div className="feature-toggle-table-row">
      <div className="feature-toggle-product">
        <div className={`feature-toggle-product-icon feature-toggle-product-icon-${feature.icon}`}>
          <FeatureRowIcon type={feature.icon} />
        </div>
        <div className="feature-toggle-product-copy">
          <strong>{feature.name}</strong>
          <span>{feature.description}</span>
        </div>
      </div>

      <span>
        <em className="feature-toggle-badge feature-toggle-badge-category">Active</em>
      </span>

      <span>
        <em className="feature-toggle-badge feature-toggle-badge-status">{isEnabled ? "Active" : "Inactive"}</em>
      </span>

      <span>
        <button
          type="button"
          className={`feature-toggle-switch${isEnabled ? " feature-toggle-switch-active" : ""}`}
          aria-pressed={isEnabled}
          onClick={() => setIsEnabled((current) => !current)}
        >
          <span />
        </button>
      </span>
    </div>
  );
}

export default function FeatureToggleSettingsPage() {
  const [saveLabel, setSaveLabel] = useState("Save");
  const [viewLabel, setViewLabel] = useState("View all");

  return (
    <section className="feature-toggle-page">
      <article className="feature-toggle-hero">
        <div className="feature-toggle-hero-icon">
          <FeatureToggleHeroIcon />
        </div>

        <div className="feature-toggle-hero-copy">
          <h2>Feature Toggle Settings</h2>
          <p>Turn system features on/off globally and control feature availability.</p>
          <a href="/super-admin/settings/feature-toggle">Configure Settings</a>
        </div>
      </article>

      <section className="feature-toggle-card">
        <div className="feature-toggle-card-header">
          <div>
            <h3>All features</h3>
            <p>Turn features on or off as needed.</p>
          </div>

          <div className="feature-toggle-toolbar">
            <label className="feature-toggle-search">
              <span>⌕</span>
              <input type="text" placeholder="Search Product or Brand name..." />
            </label>

            <select className="feature-toggle-filter" defaultValue="All categories">
              <option>All categories</option>
            </select>

            <button
              type="button"
              className="feature-toggle-save-button"
              onClick={() => {
                setSaveLabel("Saved");
                window.setTimeout(() => setSaveLabel("Save"), 1200);
              }}
            >
              {saveLabel}
            </button>
          </div>
        </div>

        <div className="feature-toggle-table">
          <div className="feature-toggle-table-head">
            <span>Product</span>
            <span>Category</span>
            <span>Status</span>
            <span>Action</span>
          </div>

          {featureRows.map((feature) => (
            <FeatureToggleRow feature={feature} key={feature.id} />
          ))}
        </div>

        <div className="feature-toggle-footer">
          <button
            type="button"
            className="feature-toggle-view-button"
            onClick={() => {
              setViewLabel("Opened");
              window.setTimeout(() => setViewLabel("View all"), 1200);
            }}
          >
            {viewLabel}
          </button>
        </div>
      </section>
    </section>
  );
}
