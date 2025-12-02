import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController, AlertController, ToastController } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { environment } from 'src/environments/environment';
import { addIcons } from 'ionicons';
import { trashOutline, personCircleOutline, timeOutline, pricetagOutline } from 'ionicons/icons';

@Component({
  selector: 'app-admin-product-detail',
  templateUrl: './product-detail.page.html',
  styleUrls: ['./product-detail.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class ProductDetailPage implements OnInit {

  product: any = null;
  isLoading = true;
  selectedImage: string = '';
  
  // Dynamic Base URL
  readonly baseUrl = environment.apiUrl.replace(/\/api\/?$/, '');

  constructor(
    private route: ActivatedRoute,
    private adminService: AdminMasterService,
    private navCtrl: NavController,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) { 
    addIcons({ trashOutline, personCircleOutline, timeOutline, pricetagOutline });
  }

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadProduct(Number(id));
    }
  }

  loadProduct(id: number) {
    this.isLoading = true;
    this.adminService.getProductDetails(id).subscribe({
      next: (res: any) => {
        this.product = res;
        // Handle Image URL logic
        if (this.product.images && this.product.images.length > 0) {
          const firstImg = this.product.images[0].imageUrl;
          this.selectedImage = this.getImageUrl(firstImg);
        }
        this.isLoading = false;
      },
      error: (err) => {
        console.error(err);
        this.showToast('Error loading product');
        this.isLoading = false;
      }
    });
  }

  // Helper to format image URL
  getImageUrl(url: string): string {
    if (!url) return 'https://placehold.co/600x600';
    if (url.startsWith('http') || url.startsWith('data:')) return url;
    return `${this.baseUrl}/uploads/${url}`;
  }

  async confirmDelete() {
    const alert = await this.alertCtrl.create({
      header: 'Delete Product?',
      message: 'This action cannot be undone.',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        { 
          text: 'Delete', 
          role: 'destructive', 
          handler: () => this.deleteProduct() 
        }
      ]
    });
    await alert.present();
  }

  deleteProduct() {
    if (!this.product) return;
    this.adminService.deleteProduct(this.product.id).subscribe({
      next: () => {
        this.showToast('Product Deleted');
        this.navCtrl.navigateBack('/products');
      },
      error: () => this.showToast('Delete Failed')
    });
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}