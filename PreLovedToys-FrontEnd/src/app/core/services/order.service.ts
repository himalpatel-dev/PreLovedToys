import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class OrderService {

  constructor(private api: ApiService) { }

  // 1. Place Order
  placeOrder(address: string) {
    return this.api.post('orders', { address });
  }

  // 2. Get Order History (We will use this later)
  getMyOrders() {
    return this.api.get('orders');
  }
}