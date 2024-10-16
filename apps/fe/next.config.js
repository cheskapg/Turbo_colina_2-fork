/** @type {import('next').NextConfig} */
module.exports = {
  reactStrictMode: true,
  transpilePackages: ["@repo/ui"],
  output: 'standalone',
  experimental: {
    outputFileTracingRoot: path.join(__dirname, '../../'), // adjust if needed for your monorepo structure
  }
};