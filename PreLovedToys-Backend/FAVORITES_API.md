# Favorites API Documentation

## Overview
The Favorites feature allows users to save products they like for later viewing. This document describes all the endpoints available for managing favorites.

## Base URL
```
/api/favorites
```

## Authentication
All endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### 1. Add Product to Favorites
**POST** `/api/favorites`

Add a product to the authenticated user's favorites list.

**Request Body:**
```json
{
  "productId": 123
}
```

**Success Response (201):**
```json
{
  "message": "Added to favorites",
  "favorite": {
    "id": 1,
    "userId": 5,
    "productId": 123,
    "createdAt": "2025-12-08T11:49:18.000Z",
    "updatedAt": "2025-12-08T11:49:18.000Z"
  }
}
```

**Error Responses:**
- `400` - Product ID is required
- `404` - Product not found
- `409` - Product already in favorites
- `500` - Server error

---

### 2. Remove Product from Favorites
**DELETE** `/api/favorites/:productId`

Remove a product from the authenticated user's favorites list.

**URL Parameters:**
- `productId` (number) - The ID of the product to remove

**Success Response (200):**
```json
{
  "message": "Removed from favorites"
}
```

**Error Responses:**
- `404` - Favorite not found
- `500` - Server error

---

### 3. Get User's Favorites
**GET** `/api/favorites/my-favorites`

Retrieve all products favorited by the authenticated user, including full product details.

**Success Response (200):**
```json
[
  {
    "id": 1,
    "userId": 5,
    "productId": 123,
    "createdAt": "2025-12-08T11:49:18.000Z",
    "updatedAt": "2025-12-08T11:49:18.000Z",
    "product": {
      "id": 123,
      "title": "Toy Car",
      "description": "Red racing car",
      "price": 150,
      "condition": "good",
      "status": "active",
      "images": [
        {
          "imageUrl": "https://example.com/image1.jpg",
          "isPrimary": true
        }
      ],
      "category": {
        "name": "Vehicles"
      },
      "subcategory": {
        "name": "Cars"
      },
      "seller": {
        "name": "John Doe"
      }
    }
  }
]
```

**Error Responses:**
- `500` - Server error

---

### 4. Check if Product is Favorited
**GET** `/api/favorites/check/:productId`

Check if a specific product is in the authenticated user's favorites.

**URL Parameters:**
- `productId` (number) - The ID of the product to check

**Success Response (200):**
```json
{
  "isFavorited": true
}
```

**Error Responses:**
- `500` - Server error

---

### 5. Get Favorite Count for Product
**GET** `/api/favorites/count/:productId`

Get the total number of users who have favorited a specific product.

**URL Parameters:**
- `productId` (number) - The ID of the product

**Success Response (200):**
```json
{
  "count": 15
}
```

**Error Responses:**
- `500` - Server error

---

## Database Schema

### Table: `tbl_favorites`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| userId | INTEGER | NOT NULL, FOREIGN KEY | Reference to tbl_users |
| productId | INTEGER | NOT NULL, FOREIGN KEY | Reference to tbl_products |
| createdAt | TIMESTAMP | NOT NULL | Creation timestamp |
| updatedAt | TIMESTAMP | NOT NULL | Last update timestamp |

**Indexes:**
- Unique composite index on (userId, productId) - Prevents duplicate favorites

**Relationships:**
- `userId` → `tbl_users.id` (Many-to-One)
- `productId` → `tbl_products.id` (Many-to-One)

---

## Usage Examples

### Example 1: Add to Favorites
```javascript
// Frontend code example
const addToFavorites = async (productId) => {
  try {
    const response = await fetch('http://localhost:4000/api/favorites', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({ productId })
    });
    
    const data = await response.json();
    console.log(data.message); // "Added to favorites"
  } catch (error) {
    console.error('Error:', error);
  }
};
```

### Example 2: Get My Favorites
```javascript
const getMyFavorites = async () => {
  try {
    const response = await fetch('http://localhost:4000/api/favorites/my-favorites', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const favorites = await response.json();
    console.log('My favorites:', favorites);
  } catch (error) {
    console.error('Error:', error);
  }
};
```

### Example 3: Toggle Favorite
```javascript
const toggleFavorite = async (productId, isFavorited) => {
  const url = `http://localhost:4000/api/favorites${isFavorited ? '/' + productId : ''}`;
  const method = isFavorited ? 'DELETE' : 'POST';
  
  try {
    const response = await fetch(url, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: method === 'POST' ? JSON.stringify({ productId }) : undefined
    });
    
    const data = await response.json();
    console.log(data.message);
  } catch (error) {
    console.error('Error:', error);
  }
};
```

---

## Files Created

1. **Model**: `src/models/favorite.model.js`
2. **Service**: `src/services/favorite.service.js`
3. **Controller**: `src/controllers/favorite.controller.js`
4. **Routes**: `src/routes/favorite.routes.js`
5. **Updated**: `src/models/index.js` (added Favorite relationships)
6. **Updated**: `server.js` (registered favorite routes)

---

## Notes

- The unique composite index ensures a user cannot favorite the same product twice
- Deleting a user or product will cascade delete related favorites (if cascade is configured)
- All timestamps are automatically managed by Sequelize
- The service layer includes full product details when fetching favorites for better UX
