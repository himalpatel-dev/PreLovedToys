import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router';
import { ProductService } from 'src/app/core/services/product.service';
import { CartService } from 'src/app/core/services/cart.service';
import { environment } from 'src/environments/environment';
import { addIcons } from 'ionicons';
import { personCircleOutline } from 'ionicons/icons';
@Component({
  selector: 'app-productdetails',
  templateUrl: './productdetails.page.html',
  styleUrls: ['./productdetails.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class ProductdetailsPage implements OnInit {
  product: any = null;
  selectedImage: string = '';
  isLoading = true;

  constructor(
    private route: ActivatedRoute,
    private productService: ProductService,
    private cartService: CartService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) {
    addIcons({ personCircleOutline });
  }

  ngOnInit() {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.loadProduct(id);
    }
  }

  loadProduct(id: string) {
    this.productService.getProductDetails(Number(id)).subscribe({
      next: (res: any) => {
        this.product = res;
        // Set the first image as default
        if (this.product.images && this.product.images.length > 0) {
          this.selectedImage = this.product.images[0].imageUrl;
        }
        this.isLoading = false;
      },
      error: (err) => {
        console.error(err);
        this.isLoading = false;
      }
    });
  }

  addToCart() {
    if (!this.product) return;

    this.cartService.addToCart(this.product.id).subscribe({
      next: async () => {
        const toast = await this.toastCtrl.create({
          message: 'Added to Cart!',
          duration: 2000,
          color: 'success',
          position: 'bottom'
        });
        toast.present();
      },
      error: async (err) => {
        const toast = await this.toastCtrl.create({
          message: 'Failed to add. Please login again.',
          duration: 2000,
          color: 'danger'
        });
        toast.present();
      }
    });
  }
}