import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#00E676', // Neon Green
        accent: '#00E676',
        background: '#0D1117', // Deep navy/black
        card: '#161B22',      // Dark cards
        elevated: '#1C2333',  // Elevated surfaces
        border: '#30363D',    // Subtle borders
        veg: {
          50: '#E8F5E9',
          100: 'rgba(0, 230, 118, 0.1)',
          200: 'rgba(0, 230, 118, 0.2)',
          300: '#81C784',
          400: '#66BB6A',
          500: '#00E676',
          600: '#00C853',
          700: '#388E3C',
          800: '#2E7D32',
          900: '#1B5E20',
        }
      }
    },
  },
  plugins: [],
}
export default config
