import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { ProductService } from '../../core/services/product.service';

@Component({
    selector: 'app-product-detail',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './product-detail.html',
    styleUrls: ['./product-detail.scss']
})
export class ProductDetailComponent implements OnInit {

    product: any = null;
    isLoading = true;
    selectedImageIndex = 0;
    quantity = 1;

    constructor(
        private route: ActivatedRoute,
        private router: Router,
        private productService: ProductService,
        private cdr: ChangeDetectorRef
    ) { }

    ngOnInit() {
        const productId = this.route.snapshot.paramMap.get('id');
        if (productId) {
            this.loadProductDetails(+productId);
        }
    }

    loadProductDetails(id: number) {
        this.isLoading = true;
        console.log('Loading product ID:', id);

        this.productService.getProductById(id).subscribe({
            next: (res: any) => {
                console.log('Product details received:', res);
                this.product = res;
                this.isLoading = false;
                console.log('isLoading set to false, product:', this.product);

                // Manually trigger change detection
                this.cdr.detectChanges();
            },
            error: (err: any) => {
                console.error('Error loading product:', err);
                this.isLoading = false;
                this.cdr.detectChanges();
                // Redirect back to home if product not found
                this.router.navigate(['/home']);
            }
        });
    }

    getProductImages(): string[] {
        if (this.product?.images && this.product.images.length > 0) {
            return this.product.images.map((img: any) => img.imageUrl);
        }
        return ['https://placehold.co/600x600?text=No+Image'];
    }

    getCurrentImage(): string {
        const images = this.getProductImages();
        return images[this.selectedImageIndex] || images[0];
    }

    selectImage(index: number) {
        this.selectedImageIndex = index;
    }

    incrementQuantity() {
        this.quantity++;
    }

    decrementQuantity() {
        if (this.quantity > 1) {
            this.quantity--;
        }
    }

    addToCart() {
        console.log('Add to cart:', this.product.title, 'Quantity:', this.quantity);
        // TODO: Implement add to cart functionality
    }

    buyNow() {
        console.log('Buy now:', this.product.title, 'Quantity:', this.quantity);
        // TODO: Implement buy now functionality
    }

    addToWishlist() {
        console.log('Add to wishlist:', this.product.title);
        // TODO: Implement wishlist functionality
    }

    shareProduct() {
        console.log('Share product:', this.product.title);
        // TODO: Implement share functionality
    }

    contactSeller() {
        console.log('Contact seller for:', this.product.title);
        // TODO: Implement contact seller functionality
    }

    goBack() {
        this.router.navigate(['/home']);
    }
}
