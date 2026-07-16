# GTEC Canteen College System

This is a comprehensive full-stack solution for the GTEC Pure Veg Canteen. The project is divided into three main applications:

## 1. Backend API (`/backend`)
A Node.js and Express backend that powers both the admin dashboard and the mobile application.
- **Technologies:** Node.js, Express, PostgreSQL, Redis, Socket.io for real-time updates.
- **Features:** Authentication (JWT & Firebase), menu management, order processing, and reviews.
- **Getting Started:**
  ```bash
  cd backend
  npm install
  npm run dev
  ```

## 2. Admin Dashboard (`/admin`)
A web-based dashboard for canteen staff and administrators to manage orders, update the menu, and view analytics.
- **Technologies:** Next.js (React), Tailwind CSS, Lucide Icons, Recharts, Socket.io Client.
- **Getting Started:**
  ```bash
  cd admin
  npm install
  npm run dev
  ```

## 3. Flutter Mobile App (`/flutter_app`)
A cross-platform mobile application for students and staff to browse the menu, place orders, and leave reviews.
- **Technologies:** Flutter, Dart.
- **Getting Started:**
  ```bash
  cd flutter_app
  flutter pub get
  flutter run
  ```

## Setup Instructions
1. Setup your PostgreSQL database and Redis server.
2. Configure `.env` files in both the `backend` and `admin` directories (use `.env.example` as a reference).
3. Ensure the backend is running before starting the admin dashboard or Flutter app to allow them to connect successfully.
