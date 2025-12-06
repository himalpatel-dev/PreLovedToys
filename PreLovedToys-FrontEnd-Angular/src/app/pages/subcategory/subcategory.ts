import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import { CategoryService } from '../../core/services/category.service';
import { SubCategoryService } from '../../core/services/subcategory.service';
import { ProductService } from '../../core/services/product.service';
import { forkJoin } from 'rxjs';

@Component({
    selector: 'app-subcategory',
    standalone: true,
    imports: [CommonModule],
    templateUrl: './subcategory.html',
    styleUrls: ['./subcategory.scss']
})
export class SubCategoryComponent implements OnInit {

    category: any = null;
    subcategories: any[] = [];
    products: any[] = [];
    isLoading = true;

    constructor(
        private route: ActivatedRoute,
        private router: Router,
        private categoryService: CategoryService,
        private subcategoryService: SubCategoryService,
        private productService: ProductService,
        private cdr: ChangeDetectorRef
    ) { }

    ngOnInit() {
        const categoryId = this.route.snapshot.paramMap.get('id');
        if (categoryId) {
            this.loadCategoryData(+categoryId);
        }
    }

    loadCategoryData(categoryId: number) {
        this.isLoading = true;
        console.log('Loading category ID:', categoryId);

        forkJoin({
            category: this.categoryService.getCategoryById(categoryId),
            subcategories: this.subcategoryService.getAllSubCategories(),
            products: this.productService.getAllProducts()
        }).subscribe({
            next: (result: any) => {
                console.log('Category data received:', result);

                // Set category
                this.category = result.category;

                // Filter subcategories by categoryId
                const allSubcategories = Array.isArray(result.subcategories)
                    ? result.subcategories
                    : result.subcategories?.data || [];

                this.subcategories = allSubcategories.filter((sub: any) => sub.categoryId === categoryId);

                // Filter products by categoryId
                const allProducts = Array.isArray(result.products)
                    ? result.products
                    : result.products?.data || [];

                this.products = allProducts.filter((p: any) => p.categoryId === categoryId);

                console.log('Filtered subcategories:', this.subcategories.length);
                console.log('Filtered products:', this.products.length);

                this.isLoading = false;
                this.cdr.detectChanges();
            },
            error: (err: any) => {
                console.error('Error loading category data:', err);
                this.isLoading = false;
                this.cdr.detectChanges();
                this.router.navigate(['/home']);
            }
        });
    }

    getProductImage(product: any): string {
        if (product.images && product.images.length > 0) {
            const cover = product.images.find((img: any) => img.isPrimary) || product.images[0];
            return cover.imageUrl;
        }
        return 'https://placehold.co/200x200?text=No+Image';
    }

    goToProduct(product: any) {
        this.router.navigate(['/product', product.id]);
    }

    onSubCategoryClick(subcategory: any) {
        console.log('SubCategory clicked:', subcategory.name);
        // TODO: Navigate to subcategory products or filter products
    }

    goBack() {
        this.router.navigate(['/home']);
    }
}
