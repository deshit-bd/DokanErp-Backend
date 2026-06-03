"use client";

import { useState } from "react";

function SubscriptionIcon() {
  return (
    <svg aria-hidden="true" viewBox="0 0 24 24">
      <path
        d="m5 18 1.6-8 5.4 4 5.4-4L19 18H5Z"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M6.6 10 4 6l4 1 4-3 4 3 4-1-2.6 4"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.9"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}

function SubscriptionToggle({ defaultChecked = true }: { defaultChecked?: boolean }) {
  const [enabled, setEnabled] = useState(defaultChecked);

  return (
    <button
      type="button"
      className={`subscription-settings-toggle${enabled ? " subscription-settings-toggle-active" : ""}`}
      aria-pressed={enabled}
      onClick={() => setEnabled((current) => !current)}
    >
      <span />
    </button>
  );
}

export default function SubscriptionSettingsPage() {
  const [saveLabel, setSaveLabel] = useState("Save Change");
  const [resetLabel, setResetLabel] = useState("Reset");

  return (
    <section className="subscription-settings-page">
      <article className="subscription-settings-hero">
        <div className="subscription-settings-icon">
          <SubscriptionIcon />
        </div>

        <div className="subscription-settings-copy">
          <h2>Subscription Settings</h2>
          <p>Manage feature plans, pricing, trials, expiry, grace period & late fee settings.</p>
          <a href="/super-admin/settings/subscription">Configure Settings</a>
        </div>
      </article>

      <div className="subscription-settings-grid">
        <article className="subscription-settings-card">
          <h3>Select default plan</h3>
          <div className="subscription-settings-stack">
            <label className="subscription-settings-field">
              <span>Select the default plan.</span>
              <select defaultValue="MUDI ERP">
                <option>MUDI ERP</option>
              </select>
            </label>
            <p className="subscription-settings-help">
              This plan will be selected by default when registering a new store.
            </p>

            <label className="subscription-settings-field">
              <span>Price per day (BDT)</span>
              <input defaultValue="10.0" />
            </label>
            <p className="subscription-settings-help">Determine daily charges</p>
          </div>
        </article>

        <article className="subscription-settings-card">
          <h3>Trial setting</h3>
          <div className="subscription-settings-stack">
            <label className="subscription-settings-field">
              <span>Trial time (Day)</span>
              <input defaultValue="7" />
            </label>
            <p className="subscription-settings-help">
              Determining the number of free trial days for new stores
            </p>

            <div className="subscription-settings-toggle-card">
              <div className="subscription-settings-toggle-copy">
                <strong>Will it auto-shut down after the trial ends?</strong>
                <p>It will be so crowded when the trial is over.</p>
              </div>
              <SubscriptionToggle />
            </div>
          </div>
        </article>

        <article className="subscription-settings-card">
          <h3>Expired settings</h3>
          <div className="subscription-settings-stack">
            <div className="subscription-settings-toggle-card">
              <div className="subscription-settings-toggle-copy">
                <strong>Auto support when the term expires</strong>
                <p>The shopkeeper will receive automatic support once the term expires.</p>
              </div>
              <SubscriptionToggle />
            </div>

            <label className="subscription-settings-field">
              <span>Grace period (Day)</span>
              <input defaultValue="3" />
            </label>
            <p className="subscription-settings-help">
              This plan will be selected by default when registering a new store.
            </p>

            <div className="subscription-settings-toggle-card">
              <div className="subscription-settings-toggle-copy">
                <strong>Auto Brocade when the grace period ends</strong>
                <p>Auto Brocade when the grace period ends</p>
              </div>
              <SubscriptionToggle />
            </div>
          </div>
        </article>
      </div>

      <div className="subscription-settings-bottom-grid">
        <article className="subscription-settings-card">
          <h3>Late fee Setting</h3>
          <div className="subscription-settings-stack">
            <div className="subscription-settings-toggle-card">
              <div className="subscription-settings-toggle-copy">
                <strong>Turn on late fees</strong>
                <p>Late fees will apply if you do not renew on time.</p>
              </div>
              <SubscriptionToggle />
            </div>

            <div className="subscription-settings-two-column">
              <div>
                <label className="subscription-settings-field">
                  <span>Amount of late fee (BDT)</span>
                  <input defaultValue="20" />
                </label>
                <p className="subscription-settings-help">Amount of late fee per day</p>
              </div>

              <div>
                <label className="subscription-settings-field">
                  <span>Total Amount of late fee (BDT)</span>
                  <input defaultValue="200" />
                </label>
                <p className="subscription-settings-help">
                  What is the maximum late fee that can be charged?
                </p>
              </div>
            </div>
          </div>
        </article>

        <article className="subscription-settings-card">
          <h3>Additional settings</h3>
          <div className="subscription-settings-stack">
            <div className="subscription-settings-toggle-card">
              <div className="subscription-settings-toggle-copy">
                <strong>Send renewal reminder</strong>
                <p>A reminder will be sent to the shopkeeper before the expiration date.</p>
              </div>
              <SubscriptionToggle />
            </div>

            <label className="subscription-settings-field">
              <span>When to send reminders (Before Day)</span>
              <input defaultValue="3" />
            </label>
            <p className="subscription-settings-help">
              A reminder will be sent a few days before the expiration date.
            </p>
          </div>
        </article>
      </div>

      <div className="subscription-settings-actions">
        <button
          type="button"
          className="subscription-settings-secondary-button"
          onClick={() => {
            setResetLabel("Reset Done");
            window.setTimeout(() => setResetLabel("Reset"), 1200);
          }}
        >
          {resetLabel}
        </button>
        <button
          type="button"
          className="subscription-settings-primary-button"
          onClick={() => {
            setSaveLabel("Saved");
            window.setTimeout(() => setSaveLabel("Save Change"), 1200);
          }}
        >
          {saveLabel}
        </button>
      </div>
    </section>
  );
}
