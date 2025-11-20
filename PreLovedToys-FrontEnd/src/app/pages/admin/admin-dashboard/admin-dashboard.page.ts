import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, ToastController, NavController } from '@ionic/angular';
import { ApiService } from 'src/app/core/services/api.service';
import { addIcons } from 'ionicons';
import { checkmarkCircle, closeCircle } from 'ionicons/icons';
import { AuthService } from 'src/app/core/services/auth.service'; // <--- Import Auth Service
@Component({
  selector: 'app-admin-dashboard',
  templateUrl: './admin-dashboard.page.html',
  styleUrls: ['./admin-dashboard.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class AdminDashboardPage {

  pendingProducts: any[] = [];

  constructor(
    private api: ApiService,
    private authService: AuthService, // <--- Inject Auth Service
    private navCtrl: NavController,   // <--- Inject Nav Controller
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) {
    addIcons({ checkmarkCircle, closeCircle });
  }

  ionViewWillEnter() {
    this.loadPendingProducts();
  }

  loadPendingProducts() {
    this.api.get('products?status=pending').subscribe({
      next: (res: any) => {
        this.pendingProducts = res;
      },
      error: (err) => console.error(err)
    });
  }

  updateStatus(id: number, newStatus: string) {
    this.api.put(`products/${id}/status`, { status: newStatus }).subscribe({
      next: () => {
        this.showToast(`Product marked as ${newStatus}`);
        this.loadPendingProducts();
      },
      error: () => this.showToast('Error updating status')
    });
  }

  // <--- ADD THIS FUNCTION
  logout() {
    // 1. Clear local storage
    this.authService.logout();

    // 2. Redirect to Login Page
    this.navCtrl.navigateRoot('/login');
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}