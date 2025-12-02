import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class AdminMasterService {

  // This matches your backend route /api/master
  private readonly BASE = 'master';

  constructor(private api: ApiService) { }

  // === IMAGE UPLOAD ===
  uploadImage(file: File) {
    const formData = new FormData();
    formData.append('image', file);
    return this.api.post('upload', formData);
  }

  // =============================
  // 1. CATEGORIES
  // =============================
  getAllCategories() {
    return this.api.get(`${this.BASE}/categories`);
  }
  createCategory(data: any) {
    return this.api.post(`${this.BASE}/categories`, data);
  }
  updateCategory(id: number, data: any) {
    return this.api.put(`${this.BASE}/categories/${id}`, data);
  }
  deleteCategory(id: number) {
    return this.api.delete(`${this.BASE}/categories/${id}`);
  }

  // =============================
  // 2. SUB-CATEGORIES
  // =============================
  getAllSubCategories() {
    return this.api.get(`${this.BASE}/subcategories`);
  }
  createSubCategory(data: any) {
    return this.api.post(`${this.BASE}/subcategories`, data);
  }
  updateSubCategory(id: number, data: any) {
    return this.api.put(`${this.BASE}/subcategories/${id}`, data);
  }
  deleteSubCategory(id: number) {
    return this.api.delete(`${this.BASE}/subcategories/${id}`);
  }

  // =============================
  // 3. AGE GROUPS
  // =============================
  getAllAgeGroups() {
    return this.api.get(`${this.BASE}/age-groups`);
  }
  createAgeGroup(data: any) {
    return this.api.post(`${this.BASE}/age-groups`, data);
  }
  updateAgeGroup(id: number, data: any) {
    return this.api.put(`${this.BASE}/age-groups/${id}`, data);
  }
  deleteAgeGroup(id: number) {
    return this.api.delete(`${this.BASE}/age-groups/${id}`);
  }

  // =============================
  // 4. COLORS
  // =============================
  getAllColors() {
    return this.api.get(`${this.BASE}/colors`);
  }
  createColor(data: any) {
    return this.api.post(`${this.BASE}/colors`, data);
  }
  updateColor(id: number, data: any) {
    return this.api.put(`${this.BASE}/colors/${id}`, data);
  }
  deleteColor(id: number) {
    return this.api.delete(`${this.BASE}/colors/${id}`);
  }

  // =============================
  // 5. GENDERS
  // =============================
  getAllGenders() {
    return this.api.get(`${this.BASE}/genders`);
  }
  createGender(data: any) {
    return this.api.post(`${this.BASE}/genders`, data);
  }
  updateGender(id: number, data: any) {
    return this.api.put(`${this.BASE}/genders/${id}`, data);
  }
  deleteGender(id: number) {
    return this.api.delete(`${this.BASE}/genders/${id}`);
  }

  // =============================
  // 6. MATERIALS
  // =============================
  getAllMaterials() {
    return this.api.get(`${this.BASE}/materials`);
  }
  createMaterial(data: any) {
    return this.api.post(`${this.BASE}/materials`, data);
  }
  updateMaterial(id: number, data: any) {
    return this.api.put(`${this.BASE}/materials/${id}`, data);
  }
  deleteMaterial(id: number) {
    return this.api.delete(`${this.BASE}/materials/${id}`);
  }

  // =============================
  // 7. User Master
  // =============================

  getAllUsers() {
    return this.api.get('users');
  }

  toggleUserStatus(userId: number, isActive: boolean) {
    return this.api.put(`users/${userId}/status`, { isActive });
  }

  // === ORDER MANAGEMENT (NEW) ===
  getAllOrders() {
    return this.api.get('orders/admin/all');
  }

  updateOrderStatus(orderId: number, status: string) {
    return this.api.put(`orders/admin/${orderId}/status`, { status });
  }

  // === STATS (NEW) ===
  getDashboardStats() {
    return this.api.get('stats');
  }

  // === PRODUCT INVENTORY ===
  getInventory() {
    return this.api.get('products/admin/all');
  }

  getProductDetails(id: number) {
    return this.api.get(`products/${id}`);
  }

  deleteProduct(id: number) { 
    return this.api.delete(`products/${id}`);
  }
}