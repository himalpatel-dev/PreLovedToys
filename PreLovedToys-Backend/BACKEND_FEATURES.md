# PreLovedToys — Backend Features

This document summarizes what the backend (PreLovedToys-Backend) currently provides.

## Tech stack
- Node.js + Express
- Sequelize ORM (Postgres)
- JWT for authentication
- Multer for file uploads

## Main capabilities (what the backend can do)

1. Authentication (OTP-based)
   - POST /api/auth/send-otp
     - Accepts { mobile }
     - Finds or creates a user and stores a 4-digit OTP + expiry
     - (Development behavior: returns the OTP in the response for testing)
   - POST /api/auth/verify-otp
     - Accepts { mobile, otp }
     - Verifies OTP and returns { user, token } where token is a JWT containing { id, role }

2. Users
   - `User` model includes id, mobile, name, email, role (admin|user|seller), otp fields, isActive
   - Implicit registration on first send-OTP (findOrCreate)

3. Products & Listings
   - Product model fields: id, title, description, price, condition (New | Like New | Good | Fair), status (pending|active|sold|rejected)
   - Product images managed in `ProductImage` model
   - Endpoints (under /api/products):
     - GET /api/products — list products (accepts query params like categoryId, subCategoryId)
     - GET /api/products/:id — product details
     - POST /api/products — create product (protected; uses req.user.id)
     - GET /api/products/my-listings — current user's listings (protected)
     - DELETE /api/products/:id — delete listing (protected; ownership enforced in service)
     - PUT /api/products/:id/status — update product status (protected)
     - GET /api/products/admin/all — admin listing endpoint (protected)

4. Master data (catalog)
   - Full CRUD on master tables: Category, SubCategory, AgeGroup, Color, Gender, Material
   - Seeders are provided to populate useful master data

5. Uploads
   - POST /api/upload — single-image upload using multer (field name: `image`)
   - Saves files to `uploads/` and serves them statically at `/uploads/<filename>`
   - Limits to images only, max size 5 MB
   - Response: { message, filename } (filename only)

6. Cart
   - Add to cart: POST /api/cart
   - Get cart: GET /api/cart
   - Remove item: DELETE /api/cart/:id
   - Cart items / associations implemented via `CartItem` model

7. Orders
   - Place order: POST /api/orders (protected; requires address)
   - Get user orders: GET /api/orders (protected)
   - Admin: list all orders and update order status (placed, packed, shipped, delivered, cancelled)

8. Seeder utilities
   - `seed-masters.js` — seeds categories, subcategories, age groups, colors, genders, materials
   - `seed-products.js` — seeds demo products and images (requires master data present)

9. Database sync
   - On server start the code calls `db.sequelize.sync({ alter: true })` to sync models to DB (convenient for dev)


## Important notes & recommendations
- Security
  - `sendOtp` currently returns OTP in response — remove this in production and integrate an SMS provider (Twilio, etc.).
  - Ensure `JWT_SECRET` is set and strong in production.
  - Add rate limiting on OTP endpoints to prevent abuse.

- Data & Migrations
  - `sync({ alter: true })` is helpful locally but unsafe for production; use migrations for production deployments.

- Uploads & Image URLs
  - Upload returns `filename` only. Clients should construct full URL as `https://<host>/uploads/<filename>`.
  - Consider returning full URL to clients to simplify frontend logic.

- Validation & Error handling
  - Add request validation (express-validator or Joi) to avoid invalid data reaching services.
  - Normalize error responses to a consistent shape.

- Role-based access control
  - Controllers rely on `verifyToken` middleware to authenticate. Admin-only routes should explicitly check roles or have a role-check middleware.


## Orders, points and listings: current behaviour

- **Checkout** (`POST /api/orders`) runs in one transaction. The listings and wallets
  involved are locked, so two buyers can't buy the same item and a wallet can't be
  spent twice at the same moment. Points and rupee items are totalled separately
  (`pointsTotal`, `cashTotal`); `totalAmount` is kept for older clients (the rupee total
  if any, otherwise the points total). Each order item saves `isPoints` and `sellerId`.
  Buying your own listing is refused.
- **Cancelling** (`PUT /api/admin/orders/:id/status` with `cancelled`) refunds the
  buyer's points, takes the points back from each seller (a seller who already spent
  them can go below zero), and puts the listings back on sale. Cancelled orders are final.
  Rupee payment is not handled yet.
- **Banned users** (`isActive = false`) can't request or verify an OTP, and any token they
  hold is refused at once (`403`, `code: ACCOUNT_BLOCKED`): `verifyToken` loads the account
  on every request.
- **Points rules** (welcome bonus, profile-completion points, point-based sales needed
  before rupee listings) are stored in `tbl_settings`, edited in the admin portal, and
  readable by the app at `GET /api/users/points-rules`. Defaults are the old values.
- **Hidden catalogue entries**: categories and sub-categories with `isActive = false`
  are left out of `/api/master/*` lists, and their listings are left out of the app's
  product lists. Deleting a category, sub-category or attribute that is still in use is
  refused (`409`) with a message; hide it instead.

## App product endpoints

- `GET /api/products`: active listings. Filters: `search`, `categoryId`,
  `subCategoryId`, `ageGroupId`, `genderId`, `colorId`, `materialId`, `isPoints`,
  `minPrice`, `maxPrice`, `sort` (`newest`, `oldest`, `price_asc`, `price_desc`). Without
  `page`/`limit` it returns an array (as before); with them it returns
  `{ data, total, page, limit, hasMore }`.
- `GET /api/products/sub-category/:subCategoryId`, `GET /api/products/other-listings`
  (everyone's but mine): same filters and paging.
- `GET /api/products/sell-eligibility`: `{ canSellCash, message, completedPointsSales, requiredSales }`.
- `PUT /api/products/:id`: the owner edits a listing (title, description, price,
  isPoints, condition, category, sub-category, age group, gender, color, material, and
  optionally `images` to replace all photos in order). Sold listings can't be edited.
- Product images include `id` and `sortOrder`; the first image is the cover (`isPrimary`).

## Admin API (`/api/admin`, admin accounts only)

`stats?range=7d|30d|90d|12m`, `products` (+ `sellerId`), `PUT/DELETE products/:id`,
`products/:id/images` (add, `order`, delete), `orders` (+ `userId`, `sellerId`),
`PUT orders/:id/status`, `users`, `users/:id`, `wallets`, `wallets/:userId`,
`POST wallets/:userId/adjust`, `categories`, `categories/:id/visibility`,
`subcategories/:id/visibility`, `settings`. Lists take `page`, `limit`, `search`,
`status` and return `{ items, total, page, limit, counts }`.

To give existing categories and sub-categories the bundled icons, run
`npm run images:apply` (see `migrations/apply_catalog_images.js`).

## Where to look in the codebase
- `server.js` — main entry, route registration, DB sync
- `src/controllers/` — controllers for auth, product, cart, order, master, user
- `src/services/` — business logic used by controllers
- `src/models/` — Sequelize models and associations
- `src/utils/file-upload.js` — multer setup and file handling
- `seed-masters.js`, `seed-products.js` — data seeding scripts


## How to run (quick)
1. Install dependencies: `npm install`
2. Create `.env` with DB credentials and `JWT_SECRET`
3. Start Postgres and create DB if needed
4. Optional: Seed masters and products with `node seed-masters.js` and `node seed-products.js`
5. Start server: `npm run dev` or `npm start`


---
If you want this written to `README.md` instead of `BACKEND_FEATURES.md`, or want additional details (OpenAPI spec, Postman collection), tell me and I will add them.