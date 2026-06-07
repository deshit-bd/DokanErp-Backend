"use client";

import { type ChangeEvent, type FormEvent, useEffect, useState } from "react";

type ProfileResponse = {
  user?: {
    id: string;
    name: string;
    email: string | null;
    phone: string | null;
    profileImageUrl: string | null;
    status: string;
  };
  session?: {
    role?: string;
  };
  message?: string;
};

export default function SuperAdminProfilePage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [role, setRole] = useState("SUPER_ADMIN");
  const [status, setStatus] = useState("ACTIVE");
  const [profileImageUrl, setProfileImageUrl] = useState("");
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewImageUrl, setPreviewImageUrl] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploadingImage, setIsUploadingImage] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    let mounted = true;

    async function loadProfile() {
      try {
        const response = await fetch("/api/auth/me", {
          cache: "no-store",
        });
        const result = (await response.json()) as ProfileResponse;

        if (!response.ok || !result.user) {
          if (mounted) {
            setError(result.message ?? "Failed to load profile.");
          }
          return;
        }

        if (!mounted) {
          return;
        }

        setName(result.user.name ?? "");
        setEmail(result.user.email ?? "");
        setPhone(result.user.phone ?? "");
        setProfileImageUrl(result.user.profileImageUrl ?? "");
        setPreviewImageUrl(result.user.profileImageUrl ?? "");
        setRole(result.session?.role ?? "SUPER_ADMIN");
        setStatus(result.user.status ?? "ACTIVE");
      } catch {
        if (mounted) {
          setError("Unable to load profile right now.");
        }
      } finally {
        if (mounted) {
          setIsLoading(false);
        }
      }
    }

    void loadProfile();

    return () => {
      mounted = false;
    };
  }, []);

  useEffect(() => {
    return () => {
      if (previewImageUrl.startsWith("blob:")) {
        URL.revokeObjectURL(previewImageUrl);
      }
    };
  }, [previewImageUrl]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSaving(true);
    setMessage("");
    setError("");

    try {
      const response = await fetch("/api/auth/me", {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          name,
          email,
          phone,
        }),
      });

      const result = (await response.json()) as ProfileResponse;

      if (!response.ok || !result.user) {
        setError(result.message ?? "Failed to update profile.");
        return;
      }

      setName(result.user.name ?? "");
      setEmail(result.user.email ?? "");
      setPhone(result.user.phone ?? "");
      setProfileImageUrl(result.user.profileImageUrl ?? "");
      if (!selectedImage) {
        setPreviewImageUrl(result.user.profileImageUrl ?? "");
      }
      setStatus(result.user.status ?? "ACTIVE");
      setMessage(result.message ?? "Profile updated successfully.");
    } catch {
      setError("Unable to save profile right now.");
    } finally {
      setIsSaving(false);
    }
  }

  function handleImageSelection(event: ChangeEvent<HTMLInputElement>) {
    const nextFile = event.target.files?.[0] ?? null;

    if (!nextFile) {
      return;
    }

    if (previewImageUrl.startsWith("blob:")) {
      URL.revokeObjectURL(previewImageUrl);
    }

    setSelectedImage(nextFile);
    setPreviewImageUrl(URL.createObjectURL(nextFile));
    setMessage("");
    setError("");
  }

  async function handleImageUpload() {
    if (!selectedImage) {
      setError("Please choose an image first.");
      return;
    }

    setIsUploadingImage(true);
    setMessage("");
    setError("");

    try {
      const formData = new FormData();
      formData.append("file", selectedImage);

      const response = await fetch("/api/auth/me/avatar", {
        method: "POST",
        body: formData,
      });

      const result = (await response.json()) as ProfileResponse;

      if (!response.ok || !result.user) {
        setError(result.message ?? "Failed to upload profile image.");
        return;
      }

      const nextImageUrl = result.user.profileImageUrl ?? "";

      setProfileImageUrl(nextImageUrl);
      setPreviewImageUrl(nextImageUrl);
      setSelectedImage(null);
      setMessage(result.message ?? "Profile image updated successfully.");
    } catch {
      setError("Unable to upload image right now.");
    } finally {
      setIsUploadingImage(false);
    }
  }

  const avatarLabel = name.trim().charAt(0).toUpperCase() || "A";
  const activePreview = previewImageUrl || profileImageUrl;

  return (
    <section className="profile-page">
      <div className="profile-header-card">
        <div className="profile-header-copy">
          <span className="profile-page-eyebrow">My Profile</span>
          <h2>{name || "Admin User"}</h2>
          <p>Review and update your basic account information for the admin panel.</p>
        </div>
        <div className="profile-header-meta">
          <span>{role.replace(/_/g, " ")}</span>
          <strong>{status}</strong>
        </div>
      </div>

      <section className="admin-dashboard-panel profile-form-panel">
        <div className="purchase-report-panel-header">
          <div>
            <h3>Edit Profile</h3>
            <p>Keep your account information up to date.</p>
          </div>
        </div>

        {isLoading ? (
          <p className="profile-form-feedback">Loading profile...</p>
        ) : (
          <div className="profile-content-grid">
            <div className="profile-image-card">
              <div className="profile-image-preview">
                {activePreview ? (
                  <img src={activePreview} alt={`${name || "Admin User"} profile`} />
                ) : (
                  <span>{avatarLabel}</span>
                )}
              </div>

              <div className="profile-image-copy">
                <h4>Profile Image</h4>
                <p>Upload a JPG, PNG, or WEBP image up to 2MB.</p>
              </div>

              <label className="profile-image-input">
                <span>Choose Image</span>
                <input type="file" accept="image/png,image/jpeg,image/webp" onChange={handleImageSelection} />
              </label>

              <button
                type="button"
                className="master-category-primary-button profile-image-upload-button"
                onClick={handleImageUpload}
                disabled={isUploadingImage || !selectedImage}
              >
                {isUploadingImage ? "Uploading..." : "Upload Image"}
              </button>
            </div>

            <form className="profile-form-grid" onSubmit={handleSubmit}>
              <label className="general-settings-field">
                <span>Full Name</span>
                <input value={name} onChange={(event) => setName(event.target.value)} placeholder="Enter full name" />
              </label>

              <label className="general-settings-field">
                <span>Email Address</span>
                <input value={email} onChange={(event) => setEmail(event.target.value)} placeholder="Enter email address" />
              </label>

              <label className="general-settings-field">
                <span>Phone Number</span>
                <input value={phone} onChange={(event) => setPhone(event.target.value)} placeholder="Enter phone number" />
              </label>

              <label className="general-settings-field">
                <span>Role</span>
                <input value={role.replace(/_/g, " ")} readOnly />
              </label>

              <label className="general-settings-field">
                <span>Status</span>
                <input value={status} readOnly />
              </label>

              <div className="profile-form-actions">
                <button type="submit" className="master-category-primary-button" disabled={isSaving}>
                  {isSaving ? "Saving..." : "Save Changes"}
                </button>
              </div>

              {message ? <p className="profile-form-feedback profile-form-feedback-success">{message}</p> : null}
              {error ? <p className="profile-form-feedback profile-form-feedback-error">{error}</p> : null}
            </form>
          </div>
        )}
      </section>
    </section>
  );
}
