import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { ProductService } from 'src/app/core/services/product.service';
import { MasterService } from 'src/app/core/services/master.service';
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
  subCategories: any[] = [];

  ageGroups: any[] = [];
  colors: any[] = [];
  genders: any[] = [];
  materials: any[] = [];
  previewImage: string | ArrayBuffer | null = null;
  selectedFile: File | null = null;
  isSubmitting = false;

  product = {
    title: '',
    price: null,
    description: '',
    condition: 'New',
    categoryId: null,
    subCategoryId: null,
    ageGroupId: null,
    genderId: null,
    colorId: null,
    materialId: null
  };

  constructor(
    private productService: ProductService,
    private masterService: MasterService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) {
    addIcons({ cameraOutline });
  }

  ngOnInit() {
    this.loadAllData();
  }

  loadAllData() {
    // 1. Load Categories
    this.masterService.getAllCategories().subscribe((res: any) => {
      this.categories = res;
    });

    // 2. Load Age Groups (Separate Call)
    this.masterService.getAgeGroups().subscribe((res: any) => {
      this.ageGroups = res;
    });

    // 3. Load Colors (Separate Call)
    this.masterService.getColors().subscribe((res: any) => {
      this.colors = res;
    });

    // 4. Load Genders (Separate Call)
    this.masterService.getGenders().subscribe((res: any) => {
      this.genders = res;
    });

    // 5. Load Materials (Separate Call)
    this.masterService.getMaterials().subscribe((res: any) => {
      this.materials = res;
    });
  }

  onCategoryChange() {
    this.product.subCategoryId = null;
    const selectedCat = this.categories.find(c => c.id === this.product.categoryId);
    this.subCategories = selectedCat ? selectedCat.subcategories : [];
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
      const reader = new FileReader();
      reader.onload = () => { this.previewImage = reader.result; };
      reader.readAsDataURL(file);
    }
  }

  async onSubmit() {
    if (!this.selectedFile) return;
    this.isSubmitting = true;

    this.productService.uploadImage(this.selectedFile).subscribe({
      next: (uploadRes: any) => {
        const productData = {
          ...this.product,
          images: [uploadRes.filename]
        };

        this.productService.createProduct(productData).subscribe({
          next: async () => {
            this.isSubmitting = false;
            await this.showToast('Product Listed Successfully!', 'success');
            this.navCtrl.navigateRoot('/home');
          },
          error: (err) => {
            this.isSubmitting = false;
            this.showToast('Failed to list product');
          }
        });
      },
      error: () => {
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