import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController } from '@ionic/angular'; // Import NavController
import { MasterService } from 'src/app/core/services/master.service';
import { ProductService } from 'src/app/core/services/product.service';
import { addIcons } from 'ionicons';
import { cartOutline, receiptOutline, add, personCircleOutline, searchOutline, eyeOutline, checkmarkCircle, heartOutline } from 'ionicons/icons';
import { RouterLink } from '@angular/router';
@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterLink],
})
export class HomePage implements OnInit {

  categories: any[] = [];
  products: any[] = [];

  constructor(
    private masterService: MasterService,
    private productService: ProductService,
    private navCtrl: NavController
  ) {
    addIcons({ cartOutline, receiptOutline, add, personCircleOutline, searchOutline, eyeOutline, checkmarkCircle, heartOutline });
  }

  ngOnInit() {
    this.loadData();
  }

  handleRefresh(event: any) {
    // 1. Re-fetch Categories
    // Add ': any' here vvv
    this.masterService.getAllCategories().subscribe((res: any) => {
      this.categories = res;
    });

    // 2. Re-fetch Products
    // Add ': any' here vvv
    this.productService.getAllProducts().subscribe((res: any) => {
      this.products = res;
      // Stop the spinner
      event.target.complete();
    });
  }

  loadData() {
    // 1. Fetch Categories
    this.masterService.getAllCategories().subscribe({
      next: (res: any) => {
        console.log('Categories loaded:', res); // Debug log
        this.categories = res;
      },
      error: (err: any) => console.error('Error fetching categories', err)
    });

    // 2. Fetch Products
    this.productService.getAllProducts().subscribe({
      next: (res: any) => {
        console.log('Products:', res); // Check console to see if images array exists
        this.products = res;
      },
      error: (err: any) => console.error('Error fetching products', err)
    });
  }

  // Helper to get the primary image or a placeholder
  getProductImage(product: any): string {
    if (product.images && product.images.length > 0) {
      // Find the one marked isPrimary, or just take the first one
      const cover = product.images.find((img: any) => img.isPrimary) || product.images[0];
      return cover.imageUrl;
    }
    return 'https://placehold.co/200x200?text=No+Image';
  }

  goToProduct(product: any) {
    // Navigate to details page with the product ID
    this.navCtrl.navigateForward(['/productdetails', product.id]);
  }

  onCategoryClick(category: any) {
    // Navigate to SubCategory Page with ID
    this.navCtrl.navigateForward(['/sub-categories', category.id]);
  }
}