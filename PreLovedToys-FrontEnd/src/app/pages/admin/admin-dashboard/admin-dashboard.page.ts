import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController } from '@ionic/angular';
import { AuthService } from 'src/app/core/services/auth.service';
import { addIcons } from 'ionicons';
import { logOutOutline, gridOutline, listOutline, colorPaletteOutline, happy, happyOutline, peopleOutline, cubeOutline, receiptOutline, walletOutline } from 'ionicons/icons';
import { RouterLink } from '@angular/router';
import { AdminMasterService } from 'src/app/core/services/admin-master.service';

@Component({
  selector: 'app-admin-dashboard',
  templateUrl: './admin-dashboard.page.html',
  styleUrls: ['./admin-dashboard.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, RouterLink]
})
export class AdminDashboardPage implements OnInit {

  stats = {
    totalUsers: 0,
    totalOrders: 0,
    activeProducts: 0,
    totalRevenue: 0,
    recentOrders: []
  };
  isLoading = true;

  constructor(
    private authService: AuthService,
    private adminService: AdminMasterService,
    private navCtrl: NavController
  ) {
    addIcons({ logOutOutline, gridOutline, listOutline, colorPaletteOutline, receiptOutline, peopleOutline, walletOutline, cubeOutline, happyOutline });
  }

  ngOnInit() {
    this.loadStats();
  }

  // Reload stats whenever the page becomes active
  ionViewWillEnter() {
    this.loadStats();
  }

  loadStats() {
    this.adminService.getDashboardStats().subscribe({
      next: (res: any) => {
        this.stats = res;
        this.isLoading = false;
      },
      error: () => {
        this.isLoading = false;
      }
    });
  }

  logout() {
    this.authService.logout();
    this.navCtrl.navigateRoot('/login');
  }
}