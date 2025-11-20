import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { OrderService } from 'src/app/core/services/order.service';

@Component({
  selector: 'app-checkout',
  templateUrl: './checkout.page.html',
  styleUrls: ['./checkout.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class CheckoutPage implements OnInit {

  address: string = '';
  isSubmitting = false;

  constructor(
    private orderService: OrderService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) { }

  ngOnInit() {
    // In a real app, you might pre-fill this from the User Profile
  }

  placeOrder() {
    if (!this.address) {
      this.showToast('Please enter your delivery address');
      return;
    }

    this.isSubmitting = true;

    this.orderService.placeOrder(this.address).subscribe({
      next: async (res) => {
        this.isSubmitting = false;
        await this.showToast('Order Placed Successfully!', 'success');

        // Navigate back to Home and clear history so back button doesn't return to checkout
        this.navCtrl.navigateRoot('/home');
      },
      error: (err) => {
        this.isSubmitting = false;
        this.showToast('Order failed. Please try again.');
        console.error(err);
      }
    });
  }

  async showToast(msg: string, color: string = 'dark') {
    const toast = await this.toastCtrl.create({
      message: msg,
      duration: 2000,
      color: color,
      position: 'bottom'
    });
    toast.present();
  }
}