import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, ToastController, NavController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { cubeOutline, trashOutline, pricetagOutline, personOutline } from 'ionicons/icons';
import { environment } from 'src/environments/environment';

@Component({
  selector: 'app-products',
  templateUrl: './products.page.html',
  styleUrls: ['./products.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class ProductsPage implements OnInit {

  products: any[] = [];
  filteredProducts: any[] = [];
  isLoading = false;
  readonly baseUrl = environment.apiUrl.replace(/\/api\/?$/, '');

  constructor(
    private adminService: AdminMasterService,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController,
    private navCtrl: NavController
  ) { 
    addIcons({ cubeOutline, trashOutline, pricetagOutline, personOutline });
  }

  ngOnInit() {
    this.loadInventory();
  }

  ionViewWillEnter() {
    this.loadInventory();
  }

  loadInventory() {
    this.isLoading = true;
    this.adminService.getInventory().subscribe({
      next: (res: any) => {
        this.products = res;
        this.filteredProducts = res;
        this.isLoading = false;
      },
      error: () => this.isLoading = false
    });
  }

  // Search Logic
  handleSearch(event: any) {
    const query = event.target.value.toLowerCase();
    this.filteredProducts = this.products.filter(p => 
      p.title.toLowerCase().includes(query) || 
      p.seller?.name?.toLowerCase().includes(query)
    );
  }

  goToDetail(product: any) {
    this.navCtrl.navigateForward(['/product-detail/', product.id]);
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}