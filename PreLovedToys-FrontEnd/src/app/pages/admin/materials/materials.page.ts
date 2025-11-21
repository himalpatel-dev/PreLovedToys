import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, ToastController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { createOutline, trashOutline, add } from 'ionicons/icons';

@Component({
  selector: 'app-materials',
  templateUrl: './materials.page.html',
  styleUrls: ['./materials.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class MaterialsPage implements OnInit {
  items: any[] = [];
  isLoading = false;

  constructor(private masterService: AdminMasterService, private alertCtrl: AlertController, private toastCtrl: ToastController) {
    addIcons({ createOutline, trashOutline, add });
  }

  ngOnInit() { this.loadData(); }

  loadData() {
    this.isLoading = true;
    this.masterService.getAllMaterials().subscribe({
      next: (res: any) => { this.items = res; this.isLoading = false; },
      error: () => this.isLoading = false
    });
  }

  async openModal(item?: any) {
    const isEdit = !!item;
    const alert = await this.alertCtrl.create({
      header: isEdit ? 'Edit Material' : 'Add Material',
      inputs: [{ name: 'name', type: 'text', placeholder: 'e.g. Plastic', value: item ? item.name : '' }],
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Save',
          handler: (data) => {
            if (!data.name) return false;
            const obs = isEdit ? this.masterService.updateMaterial(item.id, data) : this.masterService.createMaterial(data);
            obs.subscribe(() => { this.showToast('Saved'); this.loadData(); });
            return true;
          }
        }
      ]
    });
    await alert.present();
  }

  async deleteItem(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Delete?',
      buttons: [{ text: 'Cancel', role: 'cancel' }, {
        text: 'Delete', role: 'destructive', handler: () => {
          this.masterService.deleteMaterial(id).subscribe(() => { this.showToast('Deleted'); this.loadData(); });
        }
      }]
    });
    await alert.present();
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 1500 });
    toast.present();
  }
}