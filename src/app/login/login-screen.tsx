"use client";

import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";

export default function LoginScreen() {
  const router = useRouter();
  const [mounted, setMounted] = useState(false);
  const [identity, setIdentity] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return null;
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setIsSubmitting(true);

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ identity, password }),
      });

      const result = (await response.json()) as {
        message?: string;
        redirectTo?: string;
      };

      if (!response.ok || !result.redirectTo) {
        setError(result.message ?? "Login failed.");
        return;
      }

      router.push(result.redirectTo);
    } catch {
      setError("Unable to log in right now. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <main className="login-shell">
      <section className="login-frame login-frame-simple">
        <div className="login-panel">
          <div className="brand-lockup brand-lockup-simple">
            <div className="brand-mark">D</div>
            <div className="brand-copy brand-copy-simple">
              <strong>DokanERP</strong>
              <span>Retail SaaS for modern dokan operations</span>
            </div>
          </div>

          <div className="panel-tag">Secure access</div>

          <div className="panel-heading">
            <h2>Login to your workspace</h2>
            <p>
              One login system for admin, store owner, and salesman accounts.
            </p>
          </div>

          <form className="field-stack" onSubmit={handleSubmit}>
            <div className="field">
              <label htmlFor="identity">Email, mobile, or store ID</label>
              <input
                id="identity"
                name="identity"
                type="text"
                placeholder="admin@deshit or +8801000000000"
                value={identity}
                onChange={(event) => setIdentity(event.target.value)}
              />
            </div>

            <div className="field">
              <label htmlFor="password">Password or PIN</label>
              <input
                id="password"
                name="password"
                type="password"
                placeholder="Enter your password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
              />
            </div>

            <button className="submit-button" type="submit">
              {isSubmitting ? "Signing in..." : "Continue"}
            </button>
          </form>

          {error ? <p className="login-error">{error}</p> : null}

          <p className="login-note">
            Admin, store owner, and salesman can all sign in from this same page.
          </p>
        </div>
      </section>
    </main>
  );
}
