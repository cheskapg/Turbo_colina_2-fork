const path = require('path'); // Import path at the beginning

/** @type {import('next').NextConfig} */
module.exports = {
  reactStrictMode: true,
  transpilePackages: ["@repo/ui"],
  output: 'standalone',
  assetPrefix: '/apps/web/', // Add assetPrefix to point to the correct static asset path
  experimental: {
    outputFileTracingRoot: path.join(__dirname, '../../'), // adjust if needed for your monorepo structure
  }
};
