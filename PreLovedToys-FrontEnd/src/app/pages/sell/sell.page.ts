import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { ProductService } from 'src/app/core/services/product.service';
import { CategoryService } from 'src/app/core/services/category.service';
import { addIcons } from 'ionicons';
import { cameraOutline } from 'ionicons/icons';

@Component({
  selector: 'app-sell',
  templateUrl: './sell.page.html',
  styleUrls: ['./sell.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class SellPage implements OnInit {

  categories: any[] = [];
  previewImage: string | ArrayBuffer | null = null;
  selectedFile: File | null = null;
  isSubmitting = false;

  product = {
    title: '',
    price: null,
    description: '',
    categoryId: null,
    condition: '',
    ageGroup: '3-10 Years' // Default for now
  };

  constructor(
    private productService: ProductService,
    private categoryService: CategoryService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) {
    addIcons({ cameraOutline });
  }

  ngOnInit() {
    this.loadCategories();
  }

  loadCategories() {
    this.categoryService.getAllCategories().subscribe((res: any) => {
      this.categories = res;
    });
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;

      // Create preview
      const reader = new FileReader();
      reader.onload = () => {
        this.previewImage = reader.result;
      };
      reader.readAsDataURL(file);
    }
  }

  async onSubmit() {
    if (!this.selectedFile) return;
    this.isSubmitting = true;

    // Step 1: Upload Image
    this.productService.uploadImage(this.selectedFile).subscribe({
      next: (uploadRes: any) => {
        const imageUrl = uploadRes.imageUrl;

        // Step 2: Create Product with that Image URL
        const productData = {
          ...this.product,
          images: [imageUrl] // Backend expects an array
        };

        this.productService.createProduct(productData).subscribe({
          next: async () => {
            this.isSubmitting = false;
            await this.showToast('Product Listed Successfully!', 'success');
            this.navCtrl.navigateRoot('/home');
          },
          error: (err) => {
            console.error(err);
            this.isSubmitting = false;
            this.showToast('Failed to list product');
          }
        });
      },
      error: (err) => {
        console.error(err);
        this.isSubmitting = false;
        this.showToast('Image Upload Failed');
      }
    });
  }

  async showToast(msg: string, color: string = 'dark') {
    const toast = await this.toastCtrl.create({
      message: msg,
      duration: 2000,
      color: color
    });
    toast.present();
  }
}