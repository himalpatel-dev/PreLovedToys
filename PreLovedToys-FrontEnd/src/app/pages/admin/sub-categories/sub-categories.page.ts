import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, AlertController, ToastController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { createOutline, trashOutline, add, close, cameraOutline } from 'ionicons/icons';
import { environment } from 'src/environments/environment'; // <--- Import Environment

@Component({
  selector: 'app-sub-categories',
  templateUrl: './sub-categories.page.html',
  styleUrls: ['./sub-categories.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class SubCategoriesPage implements OnInit {

  subCategories: any[] = [];
  categories: any[] = [];
  isLoading = false;

  // Dynamic Base URL
  readonly baseUrl = environment.apiUrl.replace(/\/api\/?$/, '');

  // Modal
  isModalOpen = false;
  isEditMode = false;

  // Form
  formData = {
    id: null,
    name: '',
    categoryId: null,
    image: ''
  };

  // Image Upload - FIXED TYPE
  previewImage: string | null = null;
  selectedFile: File | null = null;

  constructor(
    private masterService: AdminMasterService,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) {
    addIcons({ createOutline, trashOutline, add, close, cameraOutline });
  }

  ngOnInit() {
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    this.masterService.getAllCategories().subscribe({
      next: (res: any) => this.categories = res,
      error: () => this.showToast('Error loading categories')
    });

    this.masterService.getAllSubCategories().subscribe({
      next: (res: any) => {
        this.subCategories = res;
        this.isLoading = false;
      },
      error: () => {
        this.showToast('Error loading subcategories');
        this.isLoading = false;
      }
    });
  }

  openModal(sub?: any) {
    this.isModalOpen = true;
    this.selectedFile = null;

    if (sub) {
      this.isEditMode = true;
      this.formData = {
        id: sub.id,
        name: sub.name,
        categoryId: sub.categoryId,
        image: sub.image
      };
      this.previewImage = sub.image;
    } else {
      this.isEditMode = false;
      this.formData = { id: null, name: '', categoryId: null, image: '' };
      this.previewImage = null;
    }
  }

  closeModal() {
    this.isModalOpen = false;
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
      const reader = new FileReader();
      reader.onload = () => { this.previewImage = reader.result as string; };
      reader.readAsDataURL(file);
    }
  }

  async saveSubCategory() {
    if (!this.formData.name || !this.formData.categoryId) {
      this.showToast('Name and Parent Category are required');
      return;
    }

    // Upload new image if selected
    if (this.selectedFile) {
      try {
        const uploadRes: any = await this.masterService.uploadImage(this.selectedFile).toPromise();
        this.formData.image = uploadRes.filename;
      } catch (err) {
        this.showToast('Image upload failed');
        return;
      }
    }

    const payload = {
      name: this.formData.name,
      categoryId: this.formData.categoryId,
      image: this.formData.image
    };

    if (this.isEditMode && this.formData.id) {
      this.masterService.updateSubCategory(this.formData.id, payload).subscribe({
        next: () => {
          this.showToast('Updated Successfully');
          this.closeModal();
          this.loadData();
        },
        error: () => this.showToast('Update Failed')
      });
    } else {
      this.masterService.createSubCategory(payload).subscribe({
        next: () => {
          this.showToast('Created Successfully');
          this.closeModal();
          this.loadData();
        },
        error: () => this.showToast('Create Failed')
      });
    }
  }

  async confirmDelete(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Delete SubCategory?',
      message: 'Products might lose their link!',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete',
          role: 'destructive',
          handler: () => {
            this.masterService.deleteSubCategory(id).subscribe({
              next: () => {
                this.showToast('Deleted');
                this.loadData();
              },
              error: () => this.showToast('Delete Failed')
            });
          }
        }
      ]
    });
    await alert.present();
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}