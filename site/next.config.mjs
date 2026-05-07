/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',

  // Required for Shiki WASM in webpack
  webpack: (config) => {
    config.experiments = {
      ...config.experiments,
      asyncWebAssembly: true,
    }
    return config
  },
}

export default nextConfig
