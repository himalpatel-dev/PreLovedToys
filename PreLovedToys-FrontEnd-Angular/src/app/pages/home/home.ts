import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { CategoryService } from '../../core/services/category.service';
import { ProductService } from '../../core/services/product.service';
import { forkJoin } from 'rxjs';

@Component({
    selector: 'app-home',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './home.html',
    styleUrls: ['./home.scss']
})
export class HomeComponent implements OnInit {

    categories: any[] = [];
    products: any[] = [];
    isLoading = false;

    constructor(
        private categoryService: CategoryService,
        private productService: ProductService,
        private router: Router,
        private cdr: ChangeDetectorRef
    ) { }

    ngOnInit() {
        this.loadData();
    }

    loadData() {
        this.isLoading = true;
        console.log('Starting to load data...');

        // Use forkJoin to load both categories and products simultaneously
        forkJoin({
            categories: this.categoryService.getAllCategories(),
            products: this.productService.getAllProducts()
        }).subscribe({
            next: (result: any) => {
                console.log('API Response:', result);

                // Handle categories - check if data is nested
                if (Array.isArray(result.categories)) {
                    this.categories = result.categories;
                } else if (result.categories?.data && Array.isArray(result.categories.data)) {
                    this.categories = result.categories.data;
                } else {
                    this.categories = [];
                }

                // Handle products - check if data is nested
                if (Array.isArray(result.products)) {
                    this.products = result.products;
                } else if (result.products?.data && Array.isArray(result.products.data)) {
                    this.products = result.products.data;
                } else {
                    this.products = [];
                }

                console.log('Categories loaded:', this.categories.length);
                console.log('Products loaded:', this.products.length);

                this.isLoading = false;

                // Manually trigger change detection
                this.cdr.detectChanges();
            },
            error: (err: any) => {
                console.error('Error loading data:', err);
                this.isLoading = false;
                // Set empty arrays on error
                this.categories = [];
                this.products = [];
                this.cdr.detectChanges();
            }
        });
    }

    refreshData() {
        this.loadData();
    }

    // Helper to get the primary image or a placeholder
    getProductImage(product: any): string {
        if (product.images && product.images.length > 0) {
            const cover = product.images.find((img: any) => img.isPrimary) || product.images[0];
            return cover.imageUrl;
        }
        return 'https://placehold.co/200x200?text=No+Image';
    }

    goToProduct(product: any) {
        // Navigate to product details page
        this.router.navigate(['/product', product.id]);
    }

    onCategoryClick(category: any) {
        // Navigate to category products page
        this.router.navigate(['/category', category.id]);
    }

    goToCart() {
        this.router.navigate(['/cart']);
    }

    goToProfile() {
        this.router.navigate(['/profile']);
    }

    goToOrders() {
        this.router.navigate(['/orders']);
    }

    goToSell() {
        this.router.navigate(['/sell']);
    }

    // Helper method for random category count (for demo purposes)
    getRandomCount(): number {
        return Math.floor(Math.random() * 50) + 10;
    }

    // Toggle wishlist (placeholder)
    toggleWishlist(event: Event, product: any) {
        event.stopPropagation();
        console.log('Toggle wishlist for:', product.title);
        // TODO: Implement wishlist functionality
    }

    // Add to cart (placeholder)
    addToCart(event: Event, product: any) {
        event.stopPropagation();
        console.log('Add to cart:', product.title);
        // TODO: Implement add to cart functionality
    }
}
