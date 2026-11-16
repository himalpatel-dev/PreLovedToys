import { Injectable, inject } from '@angular/core';
import { ApiService } from './api';
import {
  Category,
  DashboardData,
  ListParams,
  MasterItem,
  Order,
  OrderReversal,
  OrderStatus,
  Page,
  PointsSettings,
  Product,
  ProductStatus,
  ProductUpdate,
  StatsRange,
  SubCategory,
  UserDetail,
  UserRecord,
  WalletDetail,
  WalletHolder,
  WalletSummary,
  WalletTransaction,
} from '../models';

/** Extra list filters, e.g. { sellerId: 5 }. */
export type ListFilters = Record<string, string | number>;

/** Query params for the paged /api/admin list endpoints. */
function listQuery(p: Partial<ListParams>, extra: ListFilters = {}): Record<string, string | number> {
  const q: Record<string, string | number> = { page: p.page ?? 1, limit: p.limit ?? 20, ...extra };
  if (p.search) q['search'] = p.search;
  if (p.status && p.status !== 'all') q['status'] = p.status;
  return q;
}

/** Simple master tables that only have a name (colors also have hexCode). */
export type MasterKey = 'age-groups' | 'genders' | 'materials' | 'colors';

export interface CategoryPayload {
  name: string;
  image?: string | null;
}

export interface SubCategoryPayload extends CategoryPayload {
  categoryId: number;
}

export interface MasterPayload {
  name: string;
  hexCode?: string | null;
}

/** Every backend call the admin portal makes. */
@Injectable({ providedIn: 'root' })
export class AdminService {
  private readonly api = inject(ApiService);

  // Dashboard
  getDashboard(range: StatsRange) {
    return this.api.get<DashboardData>('admin/stats', { range });
  }

  // Uploads: POST /api/upload, field "image", returns { filename }
  uploadImage(file: File) {
    const form = new FormData();
    form.append('image', file);
    return this.api.post<{ message: string; filename: string }>('upload', form);
  }

  // Users (paged; status = all | active | banned)
  getUsers(p: Partial<ListParams>) {
    return this.api.get<Page<UserRecord>>('admin/users', listQuery(p));
  }
  getUserDetail(id: number) {
    return this.api.get<UserDetail>(`admin/users/${id}`);
  }
  setUserActive(id: number, isActive: boolean) {
    return this.api.put<{ message: string }>(`users/${id}/status`, { isActive });
  }

  // Orders (paged; filters: userId = buyer, sellerId)
  getOrders(p: Partial<ListParams>, filters?: ListFilters) {
    return this.api.get<Page<Order>>('admin/orders', listQuery(p, filters));
  }
  /** Cancelling refunds the buyer's points, takes them back from sellers and relists the items. */
  setOrderStatus(id: number, status: OrderStatus) {
    return this.api.put<{ order: Order; reversal: OrderReversal | null }>(`admin/orders/${id}/status`, { status });
  }

  // Products (paged; filters: sellerId)
  getProducts(p: Partial<ListParams>, filters?: ListFilters) {
    return this.api.get<Page<Product>>('admin/products', listQuery(p, filters));
  }
  getProduct(id: number) {
    return this.api.get<Product>(`products/${id}`);
  }
  setProductStatus(id: number, status: ProductStatus) {
    return this.api.put<{ message: string }>(`products/${id}/status`, { status });
  }
  updateProduct(id: number, data: Partial<ProductUpdate>) {
    return this.api.put<Product>(`admin/products/${id}`, data);
  }
  deleteProduct(id: number) {
    return this.api.delete<{ deleted: boolean; title: string }>(`admin/products/${id}`);
  }
  /** imageUrl = the filename returned by uploadImage. */
  addProductImage(id: number, imageUrl: string) {
    return this.api.post<Product>(`admin/products/${id}/images`, { imageUrl });
  }
  removeProductImage(id: number, imageId: number) {
    return this.api.delete<Product>(`admin/products/${id}/images/${imageId}`);
  }
  /** Every photo id of the listing, in the new order (first = cover). */
  reorderProductImages(id: number, imageIds: number[]) {
    return this.api.put<Product>(`admin/products/${id}/images/order`, { imageIds });
  }

  // Points (wallets)
  getWallets(p: Partial<ListParams>) {
    return this.api.get<Page<WalletHolder, WalletSummary>>('admin/wallets', listQuery(p));
  }
  getWallet(userId: number, p: Partial<ListParams>) {
    return this.api.get<WalletDetail>(`admin/wallets/${userId}`, listQuery(p));
  }
  /** Positive amount adds points, negative removes them. */
  adjustPoints(userId: number, amount: number, reason: string) {
    return this.api.post<{ balance: string; transaction: WalletTransaction }>(
      `admin/wallets/${userId}/adjust`,
      { amount, reason }
    );
  }

  // Points rules
  getSettings() {
    return this.api.get<PointsSettings>('admin/settings');
  }
  updateSettings(changes: Partial<PointsSettings>) {
    return this.api.put<PointsSettings>('admin/settings', changes);
  }

  // Categories (admin view: hidden ones too, with sub-categories and listing counts)
  getCatalogue() {
    return this.api.get<Category[]>('admin/categories');
  }
  setCategoryVisible(id: number, isActive: boolean) {
    return this.api.put<Category>(`admin/categories/${id}/visibility`, { isActive });
  }
  setSubCategoryVisible(id: number, isActive: boolean) {
    return this.api.put<SubCategory>(`admin/subcategories/${id}/visibility`, { isActive });
  }
  createCategory(data: CategoryPayload) {
    return this.api.post<Category>('master/categories', data);
  }
  updateCategory(id: number, data: CategoryPayload) {
    return this.api.put<Category>(`master/categories/${id}`, data);
  }
  /** Refused (409) while sub-categories or listings still use it. */
  deleteCategory(id: number) {
    return this.api.delete<unknown>(`master/categories/${id}`);
  }

  // Sub-categories
  createSubCategory(data: SubCategoryPayload) {
    return this.api.post<SubCategory>('master/subcategories', data);
  }
  updateSubCategory(id: number, data: SubCategoryPayload) {
    return this.api.put<SubCategory>(`master/subcategories/${id}`, data);
  }
  deleteSubCategory(id: number) {
    return this.api.delete<unknown>(`master/subcategories/${id}`);
  }

  // Age groups, genders, materials, colors
  getMasters(key: MasterKey) {
    return this.api.get<MasterItem[]>(`master/${key}`);
  }
  createMaster(key: MasterKey, data: MasterPayload) {
    return this.api.post<MasterItem>(`master/${key}`, data);
  }
  updateMaster(key: MasterKey, id: number, data: MasterPayload) {
    return this.api.put<MasterItem>(`master/${key}/${id}`, data);
  }
  deleteMaster(key: MasterKey, id: number) {
    return this.api.delete<unknown>(`master/${key}/${id}`);
  }
}
