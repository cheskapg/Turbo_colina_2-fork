const path = require('path'); // Import path at the beginning

/** @type {import('next').NextConfig} */
module.exports = {
  reactStrictMode: true,
  transpilePackages: ["@repo/ui"],
  output: 'standalone',
  experimental: {
    outputFileTracingRoot: path.join(__dirname, '../../'), // Adjust if needed for your monorepo structure
  },
};
