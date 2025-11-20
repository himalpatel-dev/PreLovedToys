import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController } from '@ionic/angular'; // Import NavController
import { CategoryService } from 'src/app/core/services/category.service';
import { ProductService } from 'src/app/core/services/product.service';
import { addIcons } from 'ionicons';
import { cartOutline, receiptOutline, add } from 'ionicons/icons';
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
    private categoryService: CategoryService,
    private productService: ProductService,
    private navCtrl: NavController
  ) {
    addIcons({ cartOutline, receiptOutline, add });
  }

  ngOnInit() {
    this.loadData();
  }

  handleRefresh(event: any) {
    // 1. Re-fetch Categories
    // Add ': any' here vvv
    this.categoryService.getAllCategories().subscribe((res: any) => {
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
    this.categoryService.getAllCategories().subscribe({
      next: (res: any) => {
        this.categories = res;
      },
      error: (err) => console.error('Error fetching categories', err)
    });

    // 2. Fetch Products
    this.productService.getAllProducts().subscribe({
      next: (res: any) => {
        console.log('Products:', res); // Check console to see if images array exists
        this.products = res;
      },
      error: (err) => console.error('Error fetching products', err)
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
}