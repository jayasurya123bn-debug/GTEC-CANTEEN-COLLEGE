# GTEC Pure Veg Canteen - WebSocket Event Catalogue

## 1. `canteen:status`
- **Direction**: Server → All Clients
- **Payload Schema**:
  ```json
  {
    "isOpen": true,
    "busyness": "low",
    "broadcastMessage": "Welcome!",
    "updatedAt": "2023-11-01T10:00:00Z"
  }
  ```
- **Fires When**: Admin toggles canteen open/closed state, changes busyness, or sets a broadcast message.
- **Client Action**: Update the canteen status bar at the top of the UI. If closed, disable ordering.

## 2. `menu:itemUpdate`
- **Direction**: Server → All Clients
- **Payload Schema**:
  ```json
  {
    "itemId": "uuid",
    "name": "Masala Dosa",
    "availability": "sold_out",
    "limitedQuantity": null
  }
  ```
- **Fires When**: Admin updates an item's availability (e.g., changes from `available` to `sold_out`).
- **Client Action**: Perform an optimistic UI update on that specific item card's availability badge without refetching the entire menu.

## 3. `menu:itemCreated`
- **Direction**: Server → All Clients
- **Payload Schema**:
  ```json
  {
    "id": "uuid",
    "categoryId": "uuid",
    "name": "Veg Noodles",
    "price": 80.00,
    "isVeg": true,
    "dietaryTag": "vegan",
    "availability": "available",
    "imageUrl": "..."
  }
  ```
- **Fires When**: Admin adds a new item to the menu.
- **Client Action**: Add the item to the local menu provider under the corresponding category.

## 4. `menu:itemDeleted`
- **Direction**: Server → All Clients
- **Payload Schema**:
  ```json
  {
    "itemId": "uuid"
  }
  ```
- **Fires When**: Admin soft-deletes a menu item.
- **Client Action**: Remove the item from the local menu provider.

## 5. `review:new`
- **Direction**: Server → All Clients
- **Payload Schema**:
  ```json
  {
    "itemId": "uuid",
    "userName": "Rahul",
    "rating": 5,
    "comment": "Super tasty and authentic!",
    "createdAt": "2023-11-01T12:00:00Z"
  }
  ```
- **Fires When**: Admin approves a student's review.
- **Client Action**: Append the review to the horizontal auto-scrolling review ticker on the home screen.

## 6. `order:statusUpdate`
- **Direction**: Server → Specific User (Room: `user:{userId}`)
- **Payload Schema**:
  ```json
  {
    "orderId": "uuid",
    "status": "ready",
    "updatedAt": "2023-11-01T12:30:00Z"
  }
  ```
- **Fires When**: Admin updates an order's status.
- **Client Action**: Update the specific order in the Orders list and trigger a local notification if the app is in foreground.

## 7. `admin:broadcast`
- **Direction**: Server → All Clients
- **Payload Schema**:
  ```json
  {
    "message": "Canteen closing in 15 minutes!",
    "sentAt": "2023-11-01T14:45:00Z"
  }
  ```
- **Fires When**: Admin sends a global broadcast message.
- **Client Action**: Show a toast/snackbar or persistent banner in the app.

## 8. `admin:orderUpdate`
- **Direction**: Server → All Admins (Room: `admins`)
- **Payload Schema**:
  ```json
  {
    "id": "uuid",
    "userId": "uuid",
    "items": [...],
    "totalAmount": 120.00,
    "status": "pending",
    "createdAt": "..."
  }
  ```
- **Fires When**: A new order is placed by any student, or an order status is changed.
- **Client Action**: Prepend the order to the admin dashboard recent orders list and update stats.
