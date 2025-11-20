import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, NavController, ToastController } from '@ionic/angular';
import { ProductService } from 'src/app/core/services/product.service';
import { AuthService } from 'src/app/core/services/auth.service';
import { addIcons } from 'ionicons';
import { trashOutline, logOutOutline } from 'ionicons/icons';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.page.html',
  styleUrls: ['./profile.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class ProfilePage {

  user: any = null;
  myProducts: any[] = [];

  constructor(
    private productService: ProductService,
    private authService: AuthService,
    private navCtrl: NavController,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) {
    addIcons({ trashOutline, logOutOutline });
  }

  ionViewWillEnter() {
    // 1. Get User info from Local Storage
    const userStr = localStorage.getItem('user');
    if (userStr) this.user = JSON.parse(userStr);

    // 2. Get My Listings
    this.loadMyListings();
  }

  loadMyListings() {
    this.productService.getMyListings().subscribe({
      next: (res: any) => this.myProducts = res,
      error: (err) => console.error(err)
    });
  }

  async confirmDelete(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Delete Listing?',
      message: 'This cannot be undone.',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete',
          role: 'destructive',
          handler: () => this.deleteProduct(id)
        }
      ]
    });
    await alert.present();
  }

  deleteProduct(id: number) {
    this.productService.deleteProduct(id).subscribe({
      next: () => {
        this.showToast('Listing removed');
        this.loadMyListings(); // Refresh list
      },
      error: () => this.showToast('Could not delete')
    });
  }

  logout() {
    this.authService.logout();
    this.navCtrl.navigateRoot('/login');
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}