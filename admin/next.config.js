/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
      {
        protocol: 'https',
        hostname: 'upload.wikimedia.org',
      },
      {
        protocol: 'https',
        hostname: 'www.gtec.ac.in',
      },
      {
        protocol: 'https',
        hostname: 'encrypted-tbn0.gstatic.com',
      }
    ],
  },
}

module.exports = nextConfig
