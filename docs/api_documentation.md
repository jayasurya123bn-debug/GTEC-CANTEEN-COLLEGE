# GTEC Pure Veg Canteen - API Documentation

Base URL: `/api/v1`

## Authentication

### `POST /auth/register`
- **Auth**: None
- **Body**:
  ```json
  {
    "name": "Student Name",
    "email": "student@gtec.ac.in",
    "password": "securepassword",
    "phone": "9876543210"
  }
  ```
- **Success 201**: `{ "message": "User registered successfully", "user": { "id": "...", "name": "...", "email": "..." } }`
- **Error 400**: `{ "error": "Validation error or email already exists" }`

### `POST /auth/login`
- **Auth**: None
- **Body**:
  ```json
  {
    "email": "student@gtec.ac.in",
    "password": "securepassword"
  }
  ```
- **Success 200**: `{ "accessToken": "...", "refreshToken": "...", "user": { "id": "...", "role": "student" } }`
- **Error 401**: `{ "error": "Invalid credentials" }`

### `POST /auth/refresh`
- **Auth**: None
- **Body**: `{ "refreshToken": "..." }`
- **Success 200**: `{ "accessToken": "..." }`
- **Error 401**: `{ "error": "Invalid refresh token" }`

### `POST /auth/logout`
- **Auth**: Bearer JWT
- **Body**: `{ "refreshToken": "..." }`
- **Success 200**: `{ "message": "Logged out successfully" }`

### `GET /auth/me`
- **Auth**: Bearer JWT
- **Success 200**: `{ "user": { ... } }`

### `PUT /auth/me`
- **Auth**: Bearer JWT
- **Body**: `{ "name": "New Name", "phone": "1234567890" }`
- **Success 200**: `{ "user": { ... } }`

### `PUT /auth/fcm-token`
- **Auth**: Bearer JWT
- **Body**: `{ "fcm_token": "token_string" }`
- **Success 200**: `{ "message": "Token updated" }`


## Canteen Status

### `GET /canteen/status`
- **Auth**: None
- **Success 200**:
  ```json
  {
    "is_open": true,
    "busyness": "moderate",
    "broadcast_message": "Special Lunch meals today!"
  }
  ```

### `PUT /canteen/status`
- **Auth**: Bearer JWT (admin)
- **Body**: `{ "is_open": true, "busyness": "packed" }`
- **Success 200**: `{ "status": { ... } }`

### `PUT /canteen/broadcast`
- **Auth**: Bearer JWT (admin)
- **Body**: `{ "broadcast_message": "..." }`
- **Success 200**: `{ "status": { ... } }`


## Menu (100% Pure Veg)
*Note: The `is_veg` parameter is never accepted. It is strictly enforced as `true` on the backend.*

### `GET /menu`
- **Auth**: None
- **Query Params**: `?category=uuid`, `?availability=available`, `?dietary_tag=vegan`
- **Success 200**:
  ```json
  [
    {
      "category": "Breakfast",
      "items": [
        { "id": "...", "name": "Idli Sambar", "price": 40.00, "is_veg": true, "dietary_tag": "vegan", "availability": "available" }
      ]
    }
  ]
  ```

### `GET /menu/categories`
- **Auth**: None
- **Success 200**: `[ { "id": "...", "name": "Lunch", "icon_emoji": "🍛" } ]`

### `GET /menu/:id`
- **Auth**: None
- **Success 200**: `{ "item": { ... }, "reviews": [ ... ] }`

### `POST /menu`
- **Auth**: Bearer JWT (admin)
- **Body**:
  ```json
  {
    "name": "Veg Pulao",
    "category_id": "...",
    "description": "...",
    "price": 80.00,
    "image_url": "...",
    "dietary_tag": "vegan",
    "availability": "available"
  }
  ```
  *(Note: Any request containing `is_veg: false` will return 400 Bad Request).*
- **Success 201**: `{ "message": "Item created", "item": { ... } }`

### `PUT /menu/:id`
- **Auth**: Bearer JWT (admin)
- **Body**: Same as POST
- **Success 200**: `{ "message": "Item updated", "item": { ... } }`

### `PATCH /menu/:id/availability`
- **Auth**: Bearer JWT (admin)
- **Body**: `{ "availability": "sold_out" }`
- **Success 200**: `{ "message": "Availability updated", "item": { ... } }`

### `DELETE /menu/:id`
- **Auth**: Bearer JWT (admin)
- **Success 200**: `{ "message": "Item marked as inactive" }`

### `GET /menu/scheduled/:date`
- **Auth**: None
- **Success 200**: `{ "items": [ ... ] }`

### `POST /menu/schedule`
- **Auth**: Bearer JWT (admin)
- **Body**: `{ "item_id": "...", "scheduled_date": "2023-11-01", "meal_type": "Lunch" }`
- **Success 201**: `{ "message": "Scheduled successfully" }`


## Reviews

### `GET /menu/:id/reviews`
- **Auth**: None
- **Success 200**: `{ "reviews": [ ... ], "total": 12, "pages": 2 }`

### `POST /menu/:id/reviews`
- **Auth**: Bearer JWT (student)
- **Body**: `{ "rating": 5, "comment": "Amazing food!" }`
- **Success 201**: `{ "message": "Review submitted for approval" }`

### `GET /reviews`
- **Auth**: Bearer JWT (admin)
- **Query Params**: `?approved=false`, `?item_id=uuid`
- **Success 200**: `{ "reviews": [ ... ] }`

### `PATCH /reviews/:id/approve`
- **Auth**: Bearer JWT (admin)
- **Body**: `{ "is_approved": true }`
- **Success 200**: `{ "message": "Review approved" }`

### `DELETE /reviews/:id`
- **Auth**: Bearer JWT (admin)
- **Success 200**: `{ "message": "Review deleted" }`


## Favourites

### `GET /favourites`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "favourites": [ ... ] }`

### `POST /favourites/:itemId`
- **Auth**: Bearer JWT (student)
- **Success 201**: `{ "message": "Added to favourites" }`

### `DELETE /favourites/:itemId`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "message": "Removed from favourites" }`

### `GET /favourites/check/:itemId`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "isFavourited": true }`


## Orders

### `POST /orders`
- **Auth**: Bearer JWT (student)
- **Body**:
  ```json
  {
    "items": [
      { "item_id": "...", "quantity": 2, "price": 40.00 }
    ],
    "time_slot": "12:30 PM",
    "notes": "No onions please"
  }
  ```
- **Success 201**: `{ "message": "Order placed", "order": { ... } }`

### `GET /orders`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "orders": [ ... ], "total": 5 }`

### `GET /orders/:id`
- **Auth**: Bearer JWT (student/admin)
- **Success 200**: `{ "order": { ... } }`

### `GET /admin/orders`
- **Auth**: Bearer JWT (admin)
- **Query Params**: `?status=pending`
- **Success 200**: `{ "orders": [ ... ] }`

### `PATCH /admin/orders/:id/status`
- **Auth**: Bearer JWT (admin)
- **Body**: `{ "status": "ready" }`
- **Success 200**: `{ "message": "Order status updated", "order": { ... } }`


## Notifications

### `GET /notifications`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "notifications": [ ... ] }`

### `PATCH /notifications/:id/read`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "message": "Marked as read" }`

### `PATCH /notifications/read-all`
- **Auth**: Bearer JWT (student)
- **Success 200**: `{ "message": "All marked as read" }`


## Dashboard

### `GET /admin/stats`
- **Auth**: Bearer JWT (admin)
- **Success 200**:
  ```json
  {
    "total_items": 25,
    "orders_today": 120,
    "revenue_today": 8500.00,
    "avg_rating": 4.5,
    "orders_by_status": {
      "pending": 10,
      "ready": 5,
      "completed": 105
    }
  }
  ```

### `GET /admin/stats/recent-orders`
- **Auth**: Bearer JWT (admin)
- **Success 200**: `{ "orders": [ ... ] }`
