import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router'; // To read the mobile number
import { AuthService } from 'src/app/core/services/auth.service';

@Component({
  selector: 'app-otp',
  templateUrl: './otp.page.html',
  styleUrls: ['./otp.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class OtpPage implements OnInit {

  mobile: string = '';
  otp: string = '';

  constructor(
    private route: ActivatedRoute, // Reads URL data
    private authService: AuthService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) { }

  ngOnInit() {
    // Read the mobile number passed from Login Page
    this.route.queryParams.subscribe(params => {
      if (params && params['mobile']) {
        this.mobile = params['mobile'];
      }
    });
  }

  onVerify() {
    if (!this.otp) return;

    this.authService.verifyOtp(this.mobile, this.otp).subscribe({
      next: (res) => {
        this.showToast('Login Successful!');
        // Navigate to the Main App (Home)
        this.navCtrl.navigateRoot('/home');
      },
      error: (err) => {
        this.showToast(err.error?.message || 'Invalid OTP');
      }
    });
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({
      message: msg,
      duration: 2000,
      position: 'bottom'
    });
    toast.present();
  }
}