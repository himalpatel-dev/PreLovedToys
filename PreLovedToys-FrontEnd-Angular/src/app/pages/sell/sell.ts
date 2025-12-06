import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ProductService } from '../../core/services/product.service';
import { CategoryService } from '../../core/services/category.service';

@Component({
    selector: 'app-sell',
    standalone: true,
    imports: [CommonModule, FormsModule],
    templateUrl: './sell.html',
    styleUrls: ['./sell.scss']
})
export class SellComponent implements OnInit {

    categories: any[] = [];
    subCategories: any[] = [];
    ageGroups: any[] = [];
    colors: any[] = [];
    genders: any[] = [];
    materials: any[] = [];

    previewImage: string | ArrayBuffer | null = null;
    selectedFile: File | null = null;
    isSubmitting = false;
    currentStep = 1; // Track wizard step (1: Photo, 2: Details, 3: Pricing)

    // Points/Money System
    completedPointsSales: number = 0;
    canSellRealMoney: boolean = false;
    Math = Math; // Expose Math to template

    product = {
        title: '',
        price: null as number | null,
        description: '',
        condition: 'New',
        categoryId: null as number | null,
        subCategoryId: null as number | null,
        ageGroupId: null as number | null,
        genderId: null as number | null,
        colorId: null as number | null,
        materialId: null as number | null,
        isPoints: true  // true = points, false = real money
    };

    constructor(
        private productService: ProductService,
        private categoryService: CategoryService,
        private router: Router,
        private cdr: ChangeDetectorRef
    ) { }

    ngOnInit() {
        this.loadAllData();
        this.loadPointsSalesCount();
    }

    loadPointsSalesCount() {
        // Load user's completed points-based sales count
        this.productService.getPointsSalesCount().subscribe({
            next: (res: any) => {
                this.completedPointsSales = res.completedPointsSales || 0;
                this.canSellRealMoney = res.canSellRealMoney || false;
                this.cdr.detectChanges();
            },
            error: (err: any) => {
                console.error('Failed to load sales count', err);
                this.completedPointsSales = 0;
                this.canSellRealMoney = false;
            }
        });
    }

    loadAllData() {
        // For now, we'll load categories. Other master data would need API endpoints
        this.categoryService.getAllCategories().subscribe({
            next: (res: any) => {
                this.categories = Array.isArray(res) ? res : res?.data || [];
                this.cdr.detectChanges();
            },
            error: (err: any) => console.error('Error loading categories:', err)
        });

        // Mock data for other fields (you'll need to create services for these)
        this.ageGroups = [
            { id: 1, name: '0-2 years' },
            { id: 2, name: '3-5 years' },
            { id: 3, name: '6-8 years' },
            { id: 4, name: '9-12 years' },
            { id: 5, name: '13+ years' }
        ];

        this.colors = [
            { id: 1, name: 'Red' },
            { id: 2, name: 'Blue' },
            { id: 3, name: 'Green' },
            { id: 4, name: 'Yellow' },
            { id: 5, name: 'Pink' },
            { id: 6, name: 'Multi-color' }
        ];

        this.genders = [
            { id: 1, name: 'Boys' },
            { id: 2, name: 'Girls' },
            { id: 3, name: 'Unisex' }
        ];

        this.materials = [
            { id: 1, name: 'Plastic' },
            { id: 2, name: 'Wood' },
            { id: 3, name: 'Metal' },
            { id: 4, name: 'Fabric' },
            { id: 5, name: 'Mixed' }
        ];
    }

    onCategoryChange() {
        this.product.subCategoryId = null;
        const selectedCat = this.categories.find(c => c.id === this.product.categoryId);
        this.subCategories = selectedCat?.subcategories || [];
        this.cdr.detectChanges();
    }

    onFileSelected(event: any) {
        const file = event.target.files[0];
        if (file) {
            this.selectedFile = file;
            const reader = new FileReader();
            reader.onload = () => {
                this.previewImage = reader.result;
                this.cdr.detectChanges();
            };
            reader.readAsDataURL(file);
        }
    }

    triggerFileInput() {
        const fileInput = document.getElementById('fileInput') as HTMLInputElement;
        fileInput?.click();
    }

    onSubmit() {
        if (!this.selectedFile) {
            alert('Please select an image');
            return;
        }

        // Validate: if not points, user must have 3 completed sales
        if (!this.product.isPoints && this.completedPointsSales < 3) {
            alert('You must complete 3 point-based sales before selling for real money');
            return;
        }

        this.isSubmitting = true;

        this.productService.uploadImage(this.selectedFile).subscribe({
            next: (uploadRes: any) => {
                const productData = {
                    ...this.product,
                    images: [uploadRes.filename]
                };

                this.productService.createProduct(productData).subscribe({
                    next: () => {
                        this.isSubmitting = false;
                        alert('Product Listed Successfully!');
                        this.router.navigate(['/home']);
                    },
                    error: (err) => {
                        this.isSubmitting = false;
                        alert(err.error?.message || 'Failed to list product');
                    }
                });
            },
            error: () => {
                this.isSubmitting = false;
                alert('Image Upload Failed');
            }
        });
    }

    goBack() {
        this.router.navigate(['/home']);
    }
}
