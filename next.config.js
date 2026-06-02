/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  webpack: (config, { dev }) => {
    // Avoid corrupted filesystem cache packs in local dev causing missing chunk errors.
    if (dev) {
      config.cache = false;
    }

    return config;
  },
};

module.exports = nextConfig;
