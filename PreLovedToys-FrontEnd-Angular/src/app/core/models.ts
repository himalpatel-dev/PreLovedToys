// Shapes returned by PreLovedToys-Backend. BIGINT columns (price, totalAmount)
// arrive from Postgres as strings, so amounts are typed `number | string`.

export type Role = 'admin' | 'user' | 'seller';
export type OrderStatus = 'placed' | 'packed' | 'shipped' | 'delivered' | 'cancelled';
export type ProductStatus = 'pending' | 'active' | 'sold' | 'rejected';
export type Amount = number | string;

export const ORDER_STATUSES: OrderStatus[] = ['placed', 'packed', 'shipped', 'delivered', 'cancelled'];
export const PRODUCT_STATUSES: ProductStatus[] = ['pending', 'active', 'sold', 'rejected'];
export const CONDITIONS = ['New', 'Like New', 'Good', 'Fair'] as const;

export interface SessionUser {
  id: number;
  mobile: string;
  name?: string | null;
  role: Role;
}

export interface UserRecord {
  id: number;
  mobile: string;
  name?: string | null;
  email?: string | null;
  role: Role;
  isActive: boolean;
  createdAt?: string;
  /** Points balance (admin users list). */
  balance?: Amount;
}

/** One page of a server-side list. `counts` holds per-status totals for the filter chips. */
export interface Page<T, S = undefined> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  counts?: Record<string, number>;
  summary?: S;
}

export interface ListParams {
  page: number;
  limit: number;
  search: string;
  status: string;
}

export interface WalletHolder {
  id: number;
  mobile: string;
  name?: string | null;
  isActive: boolean;
  balance: Amount;
  lastActivity: string | null;
}

export interface WalletSummary {
  totalPoints: Amount;
  holders: number;
}

export type WalletTxType = 'credit' | 'debit' | 'transfer';

export interface WalletTransaction {
  id: number;
  type: WalletTxType;
  amount: Amount;
  balanceAfter: Amount | null;
  description: string | null;
  createdAt: string;
  refUser?: { id: number; name?: string | null; mobile?: string } | null;
}

export interface WalletDetail extends Page<WalletTransaction> {
  user: UserRecord;
  balance: Amount;
}

/** Fields an admin can change on a listing. */
export interface ProductUpdate {
  title: string;
  description: string;
  price: number;
  isPoints: boolean;
  condition: string;
  categoryId: number;
  subCategoryId: number | null;
  ageGroupId: number | null;
  genderId: number | null;
  colorId: number | null;
  materialId: number | null;
}

export interface NamedRef {
  id?: number;
  name?: string | null;
}

export interface MasterItem {
  id: number;
  name: string;
  hexCode?: string | null;
}

export interface Category {
  id: number;
  name: string;
  image?: string | null;
  isActive?: boolean;
  subcategories?: SubCategory[];
  /** Listings in this category (admin categories endpoint). */
  productCount?: number;
}

export interface SubCategory {
  id: number;
  name: string;
  image?: string | null;
  categoryId: number;
  isActive?: boolean;
  category?: (NamedRef & { isActive?: boolean }) | null;
  productCount?: number;
}

export interface ProductImage {
  id?: number;
  imageUrl: string;
  isPrimary?: boolean;
  sortOrder?: number;
}

/** Admin-editable points rules. */
export interface PointsSettings {
  welcomeBonus: number;
  cashUnlockSales: number;
  profilePoints: Record<string, number>;
}

/** GET /api/admin/users/:id */
export interface UserDetail {
  user: UserRecord & {
    gender?: string | null;
    occupation?: string | null;
    collegeOrUniversity?: string | null;
    aboutMe?: string | null;
    purpose?: string | null;
    updatedAt?: string;
  };
  balance: Amount;
  listings: Record<string, number>;
  purchases: { orders: number; cancelled: number; pointsSpent: Amount; cashSpent: Amount };
  sales: { orders: number };
}

export type StatsRange = '7d' | '30d' | '90d' | '12m';

export interface StatsBucket {
  bucket: string;
  orders: number;
  cash: number;
  points: number;
  newUsers: number;
  newListings: number;
}

/** GET /api/admin/stats */
export interface DashboardData {
  range: StatsRange;
  unit: 'day' | 'month';
  from: string;
  totals: { users: number; activeListings: number };
  period: {
    orders: number;
    cancelledOrders: number;
    cashRevenue: Amount;
    pointsSpent: Amount;
    newUsers: number;
    newListings: number;
  };
  previous: { orders: number; cashRevenue: Amount; pointsSpent: Amount; newUsers: number; newListings: number };
  series: StatsBucket[];
  statusBreakdown: Partial<Record<OrderStatus, number>>;
  recentOrders: Order[];
}

export interface Product {
  id: number;
  title: string;
  description?: string | null;
  price: Amount;
  isPoints?: boolean;
  condition?: string | null;
  status: ProductStatus;
  createdAt?: string;
  categoryId?: number | null;
  subCategoryId?: number | null;
  ageGroupId?: number | null;
  genderId?: number | null;
  colorId?: number | null;
  materialId?: number | null;
  images?: ProductImage[];
  category?: NamedRef | null;
  subcategory?: NamedRef | null;
  seller?: (NamedRef & { mobile?: string }) | null;
  ageGroup?: NamedRef | null;
  gender?: NamedRef | null;
  material?: NamedRef | null;
  color?: (NamedRef & { hexCode?: string | null }) | null;
}

export interface OrderItem {
  id: number;
  quantity: number;
  priceAtPurchase?: Amount;
  /** Saved at purchase (null on orders placed before this was recorded). */
  isPoints?: boolean | null;
  sellerId?: number | null;
  product?: Product | null;
}

/** What cancelling an order undid. */
export interface OrderReversal {
  pointsRefunded: number;
  sellersCharged: number;
  listingsRestored: number;
}

export interface Order {
  id: number;
  totalAmount: Amount;
  status: OrderStatus;
  paymentStatus?: string;
  shippingAddress?: string | null;
  isPoints?: boolean;
  /** Separate totals (0 and 0 on orders placed before they were recorded). */
  pointsTotal?: Amount;
  cashTotal?: Amount;
  cancelledAt?: string | null;
  createdAt: string;
  user?: (NamedRef & { mobile?: string; email?: string | null }) | null;
  items?: OrderItem[];
}

