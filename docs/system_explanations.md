# GTEC Pure Veg Canteen System - Explanations & Guides

## 1. Real-Time Data Flow Explanation

### Socket Connection Lifecycle
The Flutter client connects to the Node.js Socket.IO server using a JWT token in the connection handshake. The server's Socket.IO middleware verifies this token. If valid, the socket connects and joins a specific room corresponding to the user's ID (`user:{userId}`). If the user is an admin, they also join the `admins` room. The connection includes a heartbeat mechanism to detect disconnections. Upon reconnection, an exponential backoff strategy is used by `socket.io-client`, and the token is re-authenticated.

### Optimistic UI Pattern
When a user toggles a favourite item, the Flutter app immediately updates the local state (UI turns the star icon green). An API request is sent in the background. If the request fails or a socket error occurs, the state reverts, and a toast notifies the user of the failure. This ensures a highly responsive experience.

### Menu Availability Updates
When the admin marks "Masala Dosa" as `sold_out` on the web panel:
1. Admin panel sends PUT request to `/api/v1/menu/{id}/availability`.
2. Server updates PostgreSQL.
3. Server invalidates the Redis menu cache.
4. Server emits `menu:itemUpdate` to all connected clients.
5. Flutter clients receive the event and update ONLY that specific item's availability badge locally, avoiding a full menu refetch.

### Review Flow
A student submits a review via POST. It goes into the DB as `is_approved = false`. The admin sees this in the Reviews tab and clicks "Approve". The server updates the DB and emits `review:new`. All connected Flutter apps receive this and inject it into the `ReviewTicker` component at the bottom of the Home screen.

### Order Status
When the admin changes an order status to "Ready", the server emits `order:statusUpdate` specifically to `user:{studentId}`. Only the student who placed the order receives this event, updating their Order Detail screen.

### FCM Integration (Favourite Availability)
If a user favourites an item that is currently `sold_out`, and the admin later changes it to `available`, the backend service checks the `favourites` table for users who liked this item. It extracts their `fcm_token`s and dispatches a multicast push notification via Firebase Admin: "Your favourite [dish name] is now available! 🌿". Tapping the notification opens the Flutter app and routes directly to the item detail screen.

### Reconnection Strategy
When the Flutter app regains connection (e.g., waking from background), the socket reconnects automatically. To catch any missed events, the app performs a lightweight delta fetch by calling `GET /canteen/status` and `GET /menu?updated_since={disconnectedAt}`.


## 2. Security Implementation

- **Password Hashing**: Passwords are never stored in plain text. `bcryptjs` is used with `saltRounds = 12` to hash passwords before storing them in PostgreSQL.
- **JWT Authentication**: The system uses two tokens: a short-lived access token (15 mins, HS256) and a long-lived refresh token (7 days). The access token is used for API requests, while the refresh token is used to obtain a new access token when it expires. Refresh tokens are rotated upon use to prevent replay attacks.
- **Input Validation**: `Joi` schemas validate every incoming API request payload. Extraneous fields are stripped. Specifically, the menu endpoints reject any request containing `is_veg: false` (returning 400).
- **Rate Limiting**: `express-rate-limit` is applied to prevent abuse. Auth routes have strict limits (5 req/min/IP), general routes (100 req/min/IP), and order creation (10 req/min/user).
- **SQL Injection**: The pg pool and query builder strictly use parameterized queries (e.g., `WHERE id = $1`). String concatenation is never used to build SQL.
- **XSS Prevention**: `helmet` is used in Express to set strict HTTP headers (Content-Security-Policy). The admin dashboard sanitizes HTML inputs.
- **CORS**: Configured to whitelist only the specific domains of the Admin panel and the custom scheme of the Flutter app.
- **WebSocket Auth**: Sockets are secured using custom middleware that validates the JWT in the `auth` payload before allowing a connection.
- **File Uploads**: Image uploads (if enabled) are checked using `multer` for MIME type validation (only jpeg/png/webp) and size limits (2MB).


## 3. Step-by-Step Deployment Guide

### PostgreSQL & Redis
1. Deploy PostgreSQL on Railway or Supabase.
2. Run migrations: `npm run db:migrate`
3. Run seeds: `npm run db:seed`
4. Deploy a Redis instance (e.g., Upstash or Docker).

### Backend (Node.js)
1. Set up a Railway or Render service.
2. Configure Environment Variables: `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `JWT_REFRESH_SECRET`, `PORT`, and Firebase Admin SDK credentials.
3. Build command: `npm install`
4. Start command: `npm start` (Runs `node server.js`).

### Admin Web (Next.js)
1. Link the GitHub repo to Vercel.
2. Configure Environment Variables: `NEXT_PUBLIC_API_URL` and `NEXT_PUBLIC_SOCKET_URL`.
3. Vercel automatically runs `npm run build` and deploys.

### Flutter App
1. Replace `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) with your Firebase project files.
2. Update the API base URL in `lib/config/api_config.dart`.
3. Build Android APK/AAB: `flutter build apk --release` or `flutter build appbundle`.
4. Build iOS: `flutter build ipa`.


## 4. Testing Strategy

### Backend (Jest + Supertest)
- **Auth Flow**: Test registration, login, token refresh, and logout.
- **Menu CRUD**: Crucial tests to ensure that attempting to create a non-veg item fails, and that `is_veg` is correctly defaulted to `true`.
- **Order & Favourites**: Test adding to favourites, creating an order, and updating statuses.

### WebSocket Testing
- Use `socket.io-client` in tests to connect to the test server, emit events, and assert that the correct broadcast events are received by dummy clients.

### Admin Web (Jest + RTL)
- Test that the menu form explicitly omits any "is veg/non-veg" toggle and displays the "🌿 This item will be marked as Vegetarian" warning.
- Test login form submissions.

### Flutter (Widget & Integration)
- Widget tests for the `VegBadge` to ensure it renders correctly.
- Integration tests using `integration_test` package to simulate the full user journey: Login → View Menu → Add to Favourites → Pre-Order.

### Security Tests
- Attempt SQL injection in the login endpoint (expect 401).
- Send requests exceeding the rate limit (expect 429).
- Send `is_veg = false` in menu creation (expect 400).

---
**READY TO DEPLOY CHECKLIST**
- [ ] Database migrated and seeded.
- [ ] Backend deployed and passing health checks.
- [ ] FCM Server Key configured.
- [ ] Admin panel deployed on Vercel.
- [ ] Environment variables set in all environments.
- [ ] Flutter app configured with production API URLs.
