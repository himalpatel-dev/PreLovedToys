import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, ToastController } from '@ionic/angular';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';
import { addIcons } from 'ionicons';
import { personCircleOutline, banOutline, checkmarkCircleOutline } from 'ionicons/icons';

@Component({
  selector: 'app-users',
  templateUrl: './users.page.html',
  styleUrls: ['./users.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class UsersPage implements OnInit {

  users: any[] = [];
  isLoading = false;

  constructor(
    private adminService: AdminMasterService,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController
  ) {
    addIcons({ personCircleOutline, banOutline, checkmarkCircleOutline });
  }

  ngOnInit() {
    this.loadUsers();
  }

  loadUsers() {
    this.isLoading = true;
    this.adminService.getAllUsers().subscribe({
      next: (res: any) => {
        this.users = res;
        this.isLoading = false;
      },
      error: () => {
        this.isLoading = false;
      }
    });
  }

  async confirmStatusChange(user: any) {
    const action = user.isActive ? 'Ban' : 'Unban';
    const alert = await this.alertCtrl.create({
      header: `${action} User?`,
      message: `Are you sure you want to ${action.toLowerCase()} ${user.name || 'this user'}?`,
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Yes',
          role: user.isActive ? 'destructive' : 'confirm',
          handler: () => {
            this.toggleStatus(user);
          }
        }
      ]
    });
    await alert.present();
  }

  toggleStatus(user: any) {
    const newStatus = !user.isActive;
    this.adminService.toggleUserStatus(user.id, newStatus).subscribe({
      next: () => {
        user.isActive = newStatus; // Update UI locally
        this.showToast(`User ${newStatus ? 'Unbanned' : 'Banned'}`);
      },
      error: () => this.showToast('Action Failed')
    });
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}