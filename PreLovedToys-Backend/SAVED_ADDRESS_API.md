# Saved Address API Documentation

## Overview
The Saved Address feature allows users to save multiple delivery addresses for easier checkout. Users can manage their addresses, set a default address, and choose from different address types (Home, Work, Other).

## Base URL
```
/api/addresses
```

## Authentication
All endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### 1. Create New Address
**POST** `/api/addresses`

Create a new saved address for the authenticated user.

**Request Body:**
```json
{
  "receiver_name": "John Doe",
  "phone_number": "9876543210",
  "address_line1": "123 Main Street",
  "address_line2": "Apartment 4B",
  "city": "Mumbai",
  "state": "Maharashtra",
  "country": "India",
  "pincode": "400001",
  "address_type": "Home",
  "is_default": true
}
```

**Field Descriptions:**
- `receiver_name` (string, required) - Name of the person receiving the delivery
- `phone_number` (string, required) - Contact number
- `address_line1` (string, required) - Primary address line
- `address_line2` (string, optional) - Secondary address line
- `city` (string, required) - City name
- `state` (string, required) - State name
- `country` (string, required) - Country name
- `pincode` (string, required) - Postal/ZIP code
- `address_type` (enum, required) - One of: "Home", "Work", "Other"
- `is_default` (boolean, optional) - Set as default address (default: false)

**Success Response (201):**
```json
{
  "message": "Address created successfully",
  "address": {
    "id": 1,
    "userId": 5,
    "receiver_name": "John Doe",
    "phone_number": "9876543210",
    "address_line1": "123 Main Street",
    "address_line2": "Apartment 4B",
    "city": "Mumbai",
    "state": "Maharashtra",
    "country": "India",
    "pincode": "400001",
    "address_type": "Home",
    "is_default": true,
    "createdAt": "2025-12-08T12:19:18.000Z",
    "updatedAt": "2025-12-08T12:19:18.000Z"
  }
}
```

**Error Responses:**
- `500` - Server error

**Note:** If `is_default` is set to `true`, all other addresses for this user will be automatically set to `is_default: false`.

---

### 2. Get All User Addresses
**GET** `/api/addresses/my-addresses`

Retrieve all saved addresses for the authenticated user.

**Success Response (200):**
```json
[
  {
    "id": 1,
    "userId": 5,
    "receiver_name": "John Doe",
    "phone_number": "9876543210",
    "address_line1": "123 Main Street",
    "address_line2": "Apartment 4B",
    "city": "Mumbai",
    "state": "Maharashtra",
    "country": "India",
    "pincode": "400001",
    "address_type": "Home",
    "is_default": true,
    "createdAt": "2025-12-08T12:19:18.000Z",
    "updatedAt": "2025-12-08T12:19:18.000Z"
  },
  {
    "id": 2,
    "userId": 5,
    "receiver_name": "Jane Doe",
    "phone_number": "9876543211",
    "address_line1": "456 Office Plaza",
    "address_line2": null,
    "city": "Delhi",
    "state": "Delhi",
    "country": "India",
    "pincode": "110001",
    "address_type": "Work",
    "is_default": false,
    "createdAt": "2025-12-07T10:15:00.000Z",
    "updatedAt": "2025-12-07T10:15:00.000Z"
  }
]
```

**Note:** Addresses are returned with default address first, then sorted by creation date (newest first).

**Error Responses:**
- `500` - Server error

---

### 3. Get Default Address
**GET** `/api/addresses/default`

Get the user's default delivery address.

**Success Response (200):**
```json
{
  "id": 1,
  "userId": 5,
  "receiver_name": "John Doe",
  "phone_number": "9876543210",
  "address_line1": "123 Main Street",
  "address_line2": "Apartment 4B",
  "city": "Mumbai",
  "state": "Maharashtra",
  "country": "India",
  "pincode": "400001",
  "address_type": "Home",
  "is_default": true,
  "createdAt": "2025-12-08T12:19:18.000Z",
  "updatedAt": "2025-12-08T12:19:18.000Z"
}
```

**Error Responses:**
- `404` - No default address found
- `500` - Server error

---

### 4. Get Address by ID
**GET** `/api/addresses/:id`

Get a specific address by its ID.

**URL Parameters:**
- `id` (number) - The ID of the address

**Success Response (200):**
```json
{
  "id": 1,
  "userId": 5,
  "receiver_name": "John Doe",
  "phone_number": "9876543210",
  "address_line1": "123 Main Street",
  "address_line2": "Apartment 4B",
  "city": "Mumbai",
  "state": "Maharashtra",
  "country": "India",
  "pincode": "400001",
  "address_type": "Home",
  "is_default": true,
  "createdAt": "2025-12-08T12:19:18.000Z",
  "updatedAt": "2025-12-08T12:19:18.000Z"
}
```

**Error Responses:**
- `404` - Address not found
- `500` - Server error

---

### 5. Update Address
**PUT** `/api/addresses/:id`

Update an existing address.

**URL Parameters:**
- `id` (number) - The ID of the address to update

**Request Body:** (All fields are optional)
```json
{
  "receiver_name": "John Smith",
  "phone_number": "9876543210",
  "address_line1": "123 Main Street",
  "address_line2": "Apartment 5C",
  "city": "Mumbai",
  "state": "Maharashtra",
  "country": "India",
  "pincode": "400002",
  "address_type": "Home",
  "is_default": true
}
```

**Success Response (200):**
```json
{
  "message": "Address updated successfully",
  "address": {
    "id": 1,
    "userId": 5,
    "receiver_name": "John Smith",
    "phone_number": "9876543210",
    "address_line1": "123 Main Street",
    "address_line2": "Apartment 5C",
    "city": "Mumbai",
    "state": "Maharashtra",
    "country": "India",
    "pincode": "400002",
    "address_type": "Home",
    "is_default": true,
    "createdAt": "2025-12-08T12:19:18.000Z",
    "updatedAt": "2025-12-08T12:30:00.000Z"
  }
}
```

**Error Responses:**
- `404` - Address not found
- `500` - Server error

---

### 6. Delete Address
**DELETE** `/api/addresses/:id`

Delete a saved address.

**URL Parameters:**
- `id` (number) - The ID of the address to delete

**Success Response (200):**
```json
{
  "message": "Address deleted successfully"
}
```

**Error Responses:**
- `404` - Address not found
- `500` - Server error

---

### 7. Set Default Address
**PUT** `/api/addresses/:id/set-default`

Set a specific address as the default delivery address.

**URL Parameters:**
- `id` (number) - The ID of the address to set as default

**Success Response (200):**
```json
{
  "message": "Default address updated",
  "address": {
    "id": 2,
    "userId": 5,
    "receiver_name": "Jane Doe",
    "phone_number": "9876543211",
    "address_line1": "456 Office Plaza",
    "address_line2": null,
    "city": "Delhi",
    "state": "Delhi",
    "country": "India",
    "pincode": "110001",
    "address_type": "Work",
    "is_default": true,
    "createdAt": "2025-12-07T10:15:00.000Z",
    "updatedAt": "2025-12-08T12:35:00.000Z"
  }
}
```

**Note:** This will automatically unset all other addresses as default.

**Error Responses:**
- `404` - Address not found
- `500` - Server error

---

## Database Schema

### Table: `tbl_saved_address`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INTEGER | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| userId | INTEGER | NOT NULL, FOREIGN KEY | Reference to tbl_users |
| receiver_name | STRING | NOT NULL | Name of receiver |
| phone_number | STRING | NOT NULL | Contact number |
| address_line1 | STRING | NOT NULL | Primary address line |
| address_line2 | STRING | NULL | Secondary address line |
| city | STRING | NOT NULL | City name |
| state | STRING | NOT NULL | State name |
| country | STRING | NOT NULL | Country name |
| pincode | STRING | NOT NULL | Postal/ZIP code |
| address_type | ENUM | NOT NULL | 'Home', 'Work', or 'Other' |
| is_default | BOOLEAN | NOT NULL | Default address flag |
| createdAt | TIMESTAMP | NOT NULL | Creation timestamp |
| updatedAt | TIMESTAMP | NOT NULL | Last update timestamp |

**Relationships:**
- `userId` → `tbl_users.id` (Many-to-One)

---

## Usage Examples

### Example 1: Create Address
```javascript
const createAddress = async (addressData) => {
  try {
    const response = await fetch('http://localhost:4000/api/addresses', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(addressData)
    });
    
    const data = await response.json();
    console.log(data.message); // "Address created successfully"
  } catch (error) {
    console.error('Error:', error);
  }
};
```

### Example 2: Get All Addresses
```javascript
const getMyAddresses = async () => {
  try {
    const response = await fetch('http://localhost:4000/api/addresses/my-addresses', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const addresses = await response.json();
    console.log('My addresses:', addresses);
  } catch (error) {
    console.error('Error:', error);
  }
};
```

### Example 3: Set Default Address
```javascript
const setDefault = async (addressId) => {
  try {
    const response = await fetch(`http://localhost:4000/api/addresses/${addressId}/set-default`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    
    const data = await response.json();
    console.log(data.message); // "Default address updated"
  } catch (error) {
    console.error('Error:', error);
  }
};
```

---

## Files Created

1. **Model**: `src/models/savedaddress.model.js`
2. **Service**: `src/services/savedaddress.service.js`
3. **Controller**: `src/controllers/savedaddress.controller.js`
4. **Routes**: `src/routes/savedaddress.routes.js`
5. **Updated**: `src/models/index.js` (added SavedAddress import and relationships)
6. **Updated**: `server.js` (registered address routes)

---

## Business Logic Notes

1. **Default Address Management**: 
   - Only one address can be marked as default per user
   - When setting a new default, all other addresses are automatically unmarked
   - This happens both during creation and update

2. **Address Ordering**:
   - Default address always appears first in the list
   - Other addresses are sorted by creation date (newest first)

3. **Security**:
   - Users can only access their own addresses
   - All operations verify userId from JWT token
   - No cross-user address access is possible

4. **Validation**:
   - All required fields must be provided during creation
   - Address type must be one of: "Home", "Work", "Other"
   - Phone number and pincode are stored as strings to preserve formatting
