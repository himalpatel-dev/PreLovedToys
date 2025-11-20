import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class CartService {

  constructor(private api: ApiService) { }

  // Add item to cart
  addToCart(productId: number, quantity: number = 1) {
    return this.api.post('cart', { productId, quantity });
  }

  // Get cart items (We will use this later for the Cart Page)
  getCart() {
    return this.api.get('cart');
  }

  // Remove item from cart
  removeItem(cartItemId: number) {
    return this.api.delete(`cart/${cartItemId}`);
  }
}