import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ActionSheetController, ToastController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { receiptOutline, timeOutline, chevronForward, ellipse } from 'ionicons/icons';

@Component({
  selector: 'app-orders',
  templateUrl: './orders.page.html',
  styleUrls: ['./orders.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class OrdersPage implements OnInit {

  orders: any[] = [];
  isLoading = false;

  constructor(
    private adminService: AdminMasterService,
    private actionSheetCtrl: ActionSheetController,
    private toastCtrl: ToastController
  ) {
    addIcons({ receiptOutline, timeOutline, chevronForward, ellipse });
  }

  ngOnInit() {
    this.loadOrders();
  }

  loadOrders() {

    this.isLoading = true;
    this.adminService.getAllOrders().subscribe({
      next: (res: any) => {
        this.orders = res;
        this.isLoading = false;
      },
      error: () => this.isLoading = false
    });
  }

  async openStatusActionSheet(order: any) {
    const actionSheet = await this.actionSheetCtrl.create({
      header: 'Update Order Status',
      buttons: [
        { text: 'Placed', role: order.status === 'placed' ? 'selected' : '', handler: () => this.updateStatus(order, 'placed') },
        { text: 'Packed', role: order.status === 'packed' ? 'selected' : '', handler: () => this.updateStatus(order, 'packed') },
        { text: 'Shipped', role: order.status === 'shipped' ? 'selected' : '', handler: () => this.updateStatus(order, 'shipped') },
        { text: 'Delivered', role: order.status === 'delivered' ? 'selected' : '', handler: () => this.updateStatus(order, 'delivered') },
        { text: 'Cancelled', role: 'destructive', handler: () => this.updateStatus(order, 'cancelled') },
        { text: 'Cancel', role: 'cancel' }
      ]
    });
    await actionSheet.present();
  }

  updateStatus(order: any, newStatus: string) {
    this.adminService.updateOrderStatus(order.id, newStatus).subscribe({
      next: () => {
        order.status = newStatus; // Update locally
        this.showToast(`Order marked as ${newStatus}`);
      },
      error: () => this.showToast('Failed to update status')
    });
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 1500 });
    toast.present();
  }

  // Helper for Status Colors
  getStatusColor(status: string) {
    switch (status) {
      case 'placed': return 'primary';
      case 'packed': return 'warning';
      case 'shipped': return 'secondary';
      case 'delivered': return 'success';
      case 'cancelled': return 'danger';
      default: return 'medium';
    }
  }
}