const path = require('path'); // Import path at the beginning
const { withModuleFederation, MerfeRuntime } = require('@module-federation/nextjs-mf');
const ModuleFederationPlugin = require('webpack/lib/container/ModuleFederationPlugin');

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  transpilePackages: ["@repo/ui"],
  output: 'standalone',
  assetPrefix: '', // Add assetPrefix to point to the correct static asset path
  experimental: {
    // outputFileTracingRoot: path.join(__dirname, '../../'), // adjust if needed for your monorepo structure
  },
  webpack: (config, options) => {
    const { isServer } = options;

    const mfConf = {
      name: 'fe',
      library: { type: config.output.libraryTarget, name: 'fe' },
      filename: 'static/chunks/remoteEntry.js',
      remotes: {
        web: 'web@http://localhost:3002/_next/static/chunks/remoteEntry.js',
      },
      exposes: {
        './Page': './src/app/page',
      },
      shared: {
        react: { singleton: true },
        'react-dom': { singleton: true },
      },
    };

    // Apply Module Federation configuration
    withModuleFederation(config, options, mfConf);
    config.plugins.push(new MerfeRuntime());

    if (!isServer) {
      config.output.publicPath = 'http://localhost:3000/_next/';
    }

    return config;
  },
};

module.exports = withModuleFederation(nextConfig);