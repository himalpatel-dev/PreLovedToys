import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule } from '@ionic/angular';
import { OrderService } from 'src/app/core/services/order.service';
// Icons
import { addIcons } from 'ionicons';
import { timeOutline, checkmarkCircleOutline, cubeOutline } from 'ionicons/icons';

@Component({
  selector: 'app-orders',
  templateUrl: './orders.page.html',
  styleUrls: ['./orders.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class OrdersPage implements OnInit {

  orders: any[] = [];
  isLoading = true;

  constructor(private orderService: OrderService) {
    addIcons({ timeOutline, checkmarkCircleOutline, cubeOutline });
  }

  ngOnInit() {
    this.loadOrders();
  }

  loadOrders() {
    this.orderService.getMyOrders().subscribe({
      next: (res: any) => {
        this.orders = res;
        this.isLoading = false;
      },
      error: (err) => {
        console.error(err);
        this.isLoading = false;
      }
    });
  }
}