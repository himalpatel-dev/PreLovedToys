# PreLovedToys Admin Portal

Web admin portal for the PreLovedToys marketplace (Angular 21). It replaces the
admin pages of the old Ionic app, which has been removed.

## Run it

1. Start the backend (`PreLovedToys-Backend`, `npm run dev`) on port 4000.
2. In this folder: `npm install`, then `npm start`.
3. Open http://localhost:4200 and sign in with the mobile number of an account
   whose `role` is `admin` (OTP login). Other accounts are refused.

The API address is set in `src/environments/environment.ts` (`apiUrl`).

## What it does

| Page | Backend calls |
|---|---|
| Dashboard: orders, rupee revenue, points spent, new users and new listings for the last 7 / 30 / 90 days or 12 months, each compared with the previous period; a chart (and table) per day or month; recent orders; orders by status | `GET /api/admin/stats?range=` |
| Orders: paged search and status filter; totals show points and rupees separately; cancelling refunds the buyer's points, takes them back from the seller and puts the items back on sale (cancelled orders are final) | `GET /api/admin/orders`, `PUT /api/admin/orders/:id/status` |
| Products: paged search (title, seller, category, #id) and status filter | `GET /api/admin/products` |
| Product detail: set status; edit details; add, remove and reorder photos (first = cover); delete (refused for listings that are in an order, which should be rejected instead) | `GET /api/products/:id`, `PUT /api/products/:id/status`, `PUT /api/admin/products/:id`, `DELETE /api/admin/products/:id`, `POST /api/admin/products/:id/images`, `PUT …/images/order`, `DELETE …/images/:imageId` |
| Users: paged search and filter, points balance, ban / unban (a banned user is signed out at once) | `GET /api/admin/users`, `PUT /api/users/:id/status` |
| User detail: profile, points, listings, purchases and sales in one place | `GET /api/admin/users/:id`, `GET /api/admin/products?sellerId=`, `GET /api/admin/orders?userId=` / `?sellerId=` |
| Points: every balance (highest first) and totals; per user: history and add / remove points with a reason | `GET /api/admin/wallets`, `GET /api/admin/wallets/:userId`, `POST /api/admin/wallets/:userId/adjust` |
| Categories, Sub-categories: add, edit (with image), show / hide in the app, delete (only when nothing uses them; otherwise hide) | `GET /api/admin/categories`, `PUT /api/admin/categories/:id/visibility`, `PUT /api/admin/subcategories/:id/visibility`, `/api/master/categories`, `/api/master/subcategories`, `POST /api/upload` |
| Age groups, Genders, Materials, Colors: add, edit, delete (only when no listing uses them) | `/api/master/{age-groups,genders,materials,colors}` |
| Points rules: welcome bonus, points per profile field, point-based sales needed before rupee listings | `GET /api/admin/settings`, `PUT /api/admin/settings` |

Lists are paged on the server (20 per page) with `?page=&limit=&search=&status=` and
return `{ items, total, page, limit, counts }`; `counts` feeds the filter chips.

Category images are saved as `/uploads/<filename>`, the form the Flutter app expects
(it builds image URLs as `serverUrl + image`). Product photos are saved as bare
filenames; the backend turns them into full URLs.

## Code layout

- `src/app/core`: API client, auth (session, guards, `Authorization: Bearer` interceptor), data types, paged-list helper, formatting helpers
- `src/app/layout`: sidebar shell
- `src/app/pages`: one folder per page; `masters` serves the four simple lists
- `src/app/shared`: icon, modal, image picker, thumbnail, badge, pager, bar chart
- `src/styles.scss`: all portal styling (brand colors match the Flutter app)

## Commands

- `npm start`: dev server on http://localhost:4200
- `npm run build`: production build into `dist/`
- `npm test`: unit tests (Vitest)

## Security note

Everything under `/api/admin` checks on the server that the caller is an active
admin (`src/middlewares/admin.middleware.js`, which reads the role from the
database, not the token), and so do the old `/api/orders/admin/*` routes. Some older
endpoints the portal still uses (product and user status changes, catalogue edits)
accept any logged-in user's token, so they need the same check before this is deployed.
