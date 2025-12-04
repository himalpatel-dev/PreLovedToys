import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class ProductService {

  constructor(private api: ApiService) { }

  getAllProducts() {
    return this.api.get('products');
  }

  // We will use this later
  getProductDetails(id: number) {
    return this.api.get(`products/${id}`);
  }

  // New Function: Upload Image
  uploadImage(file: File) {
    const formData = new FormData();
    formData.append('image', file); // 'image' must match backend key
    return this.api.post('upload', formData); // Note: Your ApiService might need tweaking for FormData
  }

  // Create Product (Already exists, just verifying)
  createProduct(data: any) {
    return this.api.post('products', data);
  }

  getMyListings() {
    return this.api.get('products/my-listings');
  }

  getPointsSalesCount() {
    return this.api.get('products/sales-count/points');
  }

  deleteProduct(id: number) {
    return this.api.delete(`products/${id}`);
  }
}