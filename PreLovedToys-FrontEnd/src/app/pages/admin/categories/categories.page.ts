import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, AlertController, ToastController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { createOutline, trashOutline, add, close, cameraOutline } from 'ionicons/icons';
import { environment } from 'src/environments/environment'; // <--- Import Environment

@Component({
  selector: 'app-categories',
  templateUrl: './categories.page.html',
  styleUrls: ['./categories.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class CategoriesPage implements OnInit {

  categories: any[] = [];
  isLoading = false;

  // Dynamic Base URL (Removes '/api' from the end if present)
  // e.g. 'http://localhost:3000/api' -> 'http://localhost:3000'
  readonly baseUrl = environment.apiUrl.replace(/\/api\/?$/, '');

  // Modal State
  isModalOpen = false;
  isEditMode = false;

  // Form Data
  formData = {
    id: null,
    name: '',
    image: ''
  };

  // Image Upload State
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
    this.loadCategories();
  }

  loadCategories() {
    this.isLoading = true;
    this.masterService.getAllCategories().subscribe({
      next: (res: any) => {
        this.categories = res;
        this.isLoading = false;
      },
      error: () => {
        this.showToast('Error loading categories');
        this.isLoading = false;
      }
    });
  }

  // --- MODAL LOGIC ---

  openModal(category?: any) {
    this.isModalOpen = true;
    this.selectedFile = null; // Reset file

    if (category) {
      this.isEditMode = true;
      this.formData = { id: category.id, name: category.name, image: category.image };
      this.previewImage = category.image; // Show existing image
    } else {
      this.isEditMode = false;
      this.formData = { id: null, name: '', image: '' };
      this.previewImage = null;
    }
  }

  closeModal() {
    this.isModalOpen = false;
  }

  // --- IMAGE UPLOAD ---

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
      const reader = new FileReader();
      reader.onload = () => { this.previewImage = reader.result as string; };
      reader.readAsDataURL(file);
    }
  }

  // --- SAVE LOGIC ---

  async saveCategory() {
    if (!this.formData.name) {
      this.showToast('Name is required');
      return;
    }

    // If a new file is selected, upload it first
    if (this.selectedFile) {
      try {
        const uploadRes: any = await this.masterService.uploadImage(this.selectedFile).toPromise();
        this.formData.image = uploadRes.filename;
      } catch (err) {
        this.showToast('Image upload failed');
        return;
      }
    }

    const payload = { name: this.formData.name, image: this.formData.image };

    if (this.isEditMode && this.formData.id) {
      this.masterService.updateCategory(this.formData.id, payload).subscribe({
        next: () => {
          this.showToast('Updated Successfully');
          this.closeModal();
          this.loadCategories();
        },
        error: () => this.showToast('Update Failed')
      });
    } else {
      this.masterService.createCategory(payload).subscribe({
        next: () => {
          this.showToast('Created Successfully');
          this.closeModal();
          this.loadCategories();
        },
        error: () => this.showToast('Create Failed')
      });
    }
  }

  // --- DELETE LOGIC ---

  async confirmDelete(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Delete Category?',
      message: 'This might delete subcategories!',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete',
          role: 'destructive',
          handler: () => {
            this.masterService.deleteCategory(id).subscribe({
              next: () => {
                this.showToast('Deleted');
                this.loadCategories();
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