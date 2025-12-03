# PreLovedToys — Frontend Features

This document summarizes what the frontend (Ionic + Angular) currently provides and what each page does.

## Tech stack
- Ionic + Angular (Angular 20)
- Standalone components
- `HttpClient` used via `src/app/core/services/ApiService`

## Overall behavior
- Authentication: OTP based. `AuthService` handles `sendOtp` and `verifyOtp`. On successful verify the app stores `token` and `user` in `localStorage`.
- `ApiService` attaches `x-access-token` header from `localStorage` to protected requests.
- Image uploads: `ProductService.uploadImage(file)` posts `FormData` with key `image` to `/api/upload` and expects `{ filename }`. Product create uses `images: [filename]`.
- Many pages depend on master data from `MasterService` (categories, subcategories, age groups, colors, genders, materials).


## Page-by-page capabilities

### Home (`/home`)
- Loads categories and latest products.
- UI elements:
  - Searchbar (currently UI-only, not wired to API)
  - Category carousel: click navigates to Sub-Categories page
  - Product grid: click opens Product Details
  - Floating Sell button -> `/sell`
- Services used: `MasterService.getAllCategories()`, `ProductService.getAllProducts()`


### Sub Categories (`/sub-categories/:categoryId`)
- Loads category from `MasterService.getAllCategories()` and displays its `subcategories`.
- Clicking a subcategory navigates to `/product-list` with `subCategoryId` as query param.


### Product List (`/product-list`)
- Loads products filtered by query param `subCategoryId` using `ApiService.get('products?subCategoryId=...')`.
- Displays product cards with image, title, and price. Click to open product details.


### Product Details (`/productdetails/:id`)
- Loads a product by ID using `ProductService.getProductDetails(id)`.
- Shows image gallery, specifications (age group, ideal for, material, color), seller info, description.
- Add to Cart: calls `CartService.addToCart(product.id)` and shows success/failure toast.


### Cart (`/cart`)
- Shows cart items fetched by `CartService.getCart()` (called on `ionViewWillEnter`).
- Displays thumbnail, qty, subtotal. Slide-to-delete calls `CartService.removeItem(id)`.
- Shows total and button to go to `/checkout`.


### Checkout (`/checkout`)
- Collects shipping address and supports Cash-on-Delivery payment option.
- `placeOrder()` calls `OrderService.placeOrder(address)` and on success navigates to `/home`.
- Note: No order item summary shown on this page currently.


### Orders (`/orders`)
- Lists user orders via `OrderService.getMyOrders()`.
- Each order shows id, total amount, status, date and the list of items with thumbnails.


### Sell (`/sell`)
- Lets users list a product for sale:
  - Loads categories, age groups, colors, genders, materials via `MasterService` calls.
  - Allows image selection and preview via FileReader.
  - Uploads the image to `/api/upload` via `ProductService.uploadImage(file)` and on success creates the product via `ProductService.createProduct(...)`.
- Only single-image upload and one listing per submit supported.


### Profile (`/profile`)
- Reads `user` from `localStorage` to display basic info.
- Shows current user's listings from `ProductService.getMyListings()`.
- Allows deleting a listing (`ProductService.deleteProduct(id)`) and logging out via `AuthService.logout()`.


### Auth pages
- Login (`/login`): collects mobile and calls `AuthService.sendOtp(mobile)`, then navigates to `/otp` with the mobile number.
- OTP (`/otp`): collects OTP and calls `AuthService.verifyOtp(mobile, otp)`. On success navigates to `/admin-dashboard` if user role is `admin`, else `/home`.


### Admin pages (behind `AdminGuard`)
- Admin dashboard and multiple admin pages exist to manage categories, subcategories, age groups, colors, genders, materials, products, orders and users.
- Example capabilities implemented in admin pages:
  - List & manage all products (admin view)
  - View & update product status
  - List & update orders and statuses
  - Create/update/delete master data entries


## Important frontend notes & recommendations
- Image URLs: Backend upload returns a `filename`. Ensure product objects include full `imageUrl` values (e.g., `https://<host>/uploads/<filename>`) or have the client prefix filenames with `${environment.apiUrl.replace('/api','')}/uploads/${filename}`.
- Centralize API usage: Prefer `ProductService`/`MasterService` instead of direct `ApiService.get(...)` calls in components for consistency.
- Add an HTTP interceptor to handle 401 responses globally (redirect to login and clear token).
- Implement search, pagination/infinite scroll for product lists and add client-side form validation for sell & checkout forms.
- Remove an OTP echo in production by changing backend behavior.


## How to run (quick)
1. Ensure backend is running and `environment.apiUrl` points to the backend API (e.g., `http://localhost:4000/api`).
2. Install frontend dependencies: `npm install` in `PreLovedToys-FrontEnd`.
3. Start dev server: `npm start` or `ng serve`.


---
If you want a single combined file at repo root or prefer these placed as `README.md` files, I can rename/move them. I can also generate a per-page API reference document (endpoints + request/response shapes) if you want.