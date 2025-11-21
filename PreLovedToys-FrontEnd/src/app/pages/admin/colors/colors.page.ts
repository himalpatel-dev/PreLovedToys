import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, ToastController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { createOutline, trashOutline, add } from 'ionicons/icons';

@Component({
  selector: 'app-colors',
  templateUrl: './colors.page.html',
  styleUrls: ['./colors.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class ColorsPage implements OnInit {
  items: any[] = [];
  isLoading = false;

  constructor(
    private masterService: AdminMasterService,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) { addIcons({ createOutline, trashOutline, add }); }

  ngOnInit() { this.loadData(); }

  loadData() {
    this.isLoading = true;
    this.masterService.getAllColors().subscribe({
      next: (res: any) => { this.items = res; this.isLoading = false; },
      error: () => this.isLoading = false
    });
  }

  async openModal(item?: any) {
    const isEdit = !!item;
    const alert = await this.alertCtrl.create({
      header: isEdit ? 'Edit Color' : 'Add Color',
      inputs: [
        { name: 'name', type: 'text', placeholder: 'Color Name (e.g. Red)', value: item ? item.name : '' },
        { name: 'hexCode', type: 'text', placeholder: 'Hex Code (e.g. #FF0000)', value: item ? item.hexCode : '' }
      ],
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Save',
          handler: (data) => {
            if (!data.name) return false;
            const obs = isEdit ? this.masterService.updateColor(item.id, data) : this.masterService.createColor(data);
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
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete', role: 'destructive', handler: () => {
            this.masterService.deleteColor(id).subscribe(() => { this.showToast('Deleted'); this.loadData(); });
          }
        }
      ]
    });
    await alert.present();
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 1500 });
    toast.present();
  }
}