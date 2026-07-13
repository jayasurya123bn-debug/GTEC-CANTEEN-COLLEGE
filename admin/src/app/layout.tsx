import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { AuthProvider } from '../context/AuthContext'
import { SocketProvider } from '../context/SocketContext'
import { Toaster } from 'react-hot-toast'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'GTEC Pure Veg Canteen - Admin',
  description: 'Admin Panel for GTEC Pure Veg Canteen',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <AuthProvider>
          <SocketProvider>
            <Toaster position="top-right" toastOptions={{
              style: {
                background: '#333',
                color: '#fff',
              },
              success: {
                iconTheme: {
                  primary: '#4CAF50',
                  secondary: '#fff',
                },
              },
            }} />
            {children}
          </SocketProvider>
        </AuthProvider>
      </body>
    </html>
  )
}
