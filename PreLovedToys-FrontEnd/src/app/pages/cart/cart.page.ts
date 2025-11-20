import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { CartService } from 'src/app/core/services/cart.service';
import { addIcons } from 'ionicons';
import { cartOutline, trash } from 'ionicons/icons';
@Component({
  selector: 'app-cart',
  templateUrl: './cart.page.html',
  styleUrls: ['./cart.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class CartPage implements OnInit {

  cartItems: any[] = [];
  totalAmount: number = 0;
  isLoading = true;

  constructor(
    private cartService: CartService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) {
    addIcons({ cartOutline, trash });
  }

  // Use ionViewWillEnter instead of ngOnInit so it refreshes every time you open the tab
  ionViewWillEnter() {
    this.loadCart();
  }

  ngOnInit() { }

  loadCart() {
    this.isLoading = true;
    this.cartService.getCart().subscribe({
      next: (res: any) => {
        this.cartItems = res;
        this.calculateTotal();
        this.isLoading = false;
      },
      error: (err) => {
        console.error(err);
        this.isLoading = false;
      }
    });
  }

  calculateTotal() {
    this.totalAmount = this.cartItems.reduce((acc, item) => {
      return acc + (item.quantity * item.product.price);
    }, 0);
  }

  removeItem(id: number) {
    this.cartService.removeItem(id).subscribe({
      next: () => {
        // Remove from local array immediately for better UX
        this.cartItems = this.cartItems.filter(item => item.id !== id);
        this.calculateTotal();
        this.showToast('Item removed');
      },
      error: () => this.showToast('Error removing item')
    });
  }

  goToCheckout() {
    this.navCtrl.navigateForward('/checkout');
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({
      message: msg,
      duration: 1500,
      position: 'bottom'
    });
    toast.present();
  }
}