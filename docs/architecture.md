# GTEC Pure Veg Canteen System - Architecture

```text
+---------------------------------------------------------------------------------------------------+
|                                                                                                   |
|                                       GTEC PURE VEG CANTEEN                                       |
|                                                                                                   |
+---------------------------------------------------------------------------------------------------+

      [ Firebase Cloud Messaging (FCM) ] <----------------------------------------+
              |                                                                   |
              | (Push Notifications: Favourite dish available)                    |
              v                                                                   | (HTTPS API)
+---------------------------+                                                     |
|                           |      HTTP/REST (Axios/Dio)           +-----------------------------+
|    Flutter Mobile App     | -----------------------------------> |                             |
|    (Android / iOS)        |                                      |      REST API (Express)     |
|                           | <----------------------------------- |                             |
|  - Students               |         (JSON Responses)             |  - JWT Auth                 |
|  - Pure Veg Theme         |                                      |  - Validation (Joi)         |
|  - Real-time updates      |      WSS (Socket.IO Client)          |  - Business Logic           |
|                           | <==================================> |                             |
+---------------------------+                                      +-----------------------------+
              ^                                                            |            |
              |                                                            |            |
              | WSS (Socket.IO)                                            |            |
              v                                                            |            |
+---------------------------+                                              |            |
|                           |      HTTP/REST (Axios)                       |            |
|    Admin Web Panel        | ---------------------------------------------+            |
|    (Next.js + Tailwind)   |                                                           |
|                           | <---------------------------------------------------------+
|  - Canteen Managers       |         (JSON Responses)                              (HTTP/REST)
|  - Dashboard / Analytics  |                                                           |
|  - Menu Management        |      WSS (Socket.IO Client)                               |
|                           | <=========================================================+
+---------------------------+

                                     +-----------------------------------------+
                                     |           SOCKET.IO SERVER              |
                                     |        (Real-time event router)         |
                                     +-----------------------------------------+
                                                |                   |
                                                v                   v
                                     +----------------+   +--------------------+
                                     | Redis Adapter  |   | Rate Limiter /     |
                                     | (Scale/Sync)   |   | Session Cache      |
                                     +----------------+   +--------------------+
                                                |                   |
                                                +---------+---------+
                                                          |
                                                          v
                                     +-----------------------------------------+
                                     |             POSTGRESQL DB               |
                                     |  (Users, Menu, Orders, Reviews, etc.)   |
                                     +-----------------------------------------+

```

## Data Flow Protocol Labels
- **Flutter App ↔ REST API (Express.js)**: HTTP/REST (Port 4000)
- **Flutter App ↔ Socket.IO Server**: WSS/Socket.IO (Real-time updates)
- **Flutter App ← FCM**: FCM/HTTPS (Push Notifications)
- **Admin Web Panel ↔ REST API**: HTTP/REST
- **Admin Web Panel ↔ Socket.IO**: WSS/Socket.IO
- **REST API ↔ PostgreSQL**: TCP (Port 5432)
- **REST API / Socket.IO ↔ Redis**: TCP (Port 6379)
