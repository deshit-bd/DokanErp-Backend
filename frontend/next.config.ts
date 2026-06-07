import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Keep dev and production artifacts separate so a build can't break a running dev server.
  distDir: process.env.NODE_ENV === "development" ? ".next-dev" : ".next",
  reactStrictMode: true,
  webpack: (config, { dev }) => {
    // Avoid corrupted filesystem cache packs in local dev causing missing chunk errors.
    if (dev) {
      config.cache = false;
    }

    return config;
  },
};

export default nextConfig;
