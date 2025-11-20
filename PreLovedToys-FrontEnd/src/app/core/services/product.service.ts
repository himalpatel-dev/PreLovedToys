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
}