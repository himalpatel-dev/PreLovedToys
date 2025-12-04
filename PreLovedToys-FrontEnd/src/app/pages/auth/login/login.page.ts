import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, ToastController, NavController } from '@ionic/angular';
import { AuthService } from 'src/app/core/services/auth.service';
import { addIcons } from 'ionicons';
import { arrowForward, chevronBack } from 'ionicons/icons';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class LoginPage implements OnInit, OnDestroy {

  mobile: string = '9727376727';
  otp: string = '';

  // Multi-step form state
  showOtpStep: boolean = false;
  isLoading: boolean = false;
  otpTimer: number = 0;
  private timerInterval: any;

  constructor(
    private authService: AuthService,
    private toastCtrl: ToastController,
    private navCtrl: NavController
  ) {
    addIcons({
      arrowForward,
      chevronBack
    });
  }

  ngOnInit() {
    // Initialize component
  }

  ngOnDestroy() {
    // Clear timer when component is destroyed
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }
  }

  async onSendOtp() {
    if (!this.mobile || this.mobile.length < 10) {
      this.showToast('Please enter a valid mobile number');
      return;
    }

    this.isLoading = true;

    this.authService.sendOtp(this.mobile).subscribe({
      next: async (res: any) => {
        console.log('Response:', res);
        await this.showToast(`${res.message}`);

        // Transition to OTP verification step
        this.showOtpStep = true;
        this.otp = '';

        // Start OTP timer (60 seconds)
        this.startOtpTimer();
        this.isLoading = false;
      },
      error: async (err) => {
        console.error(err);
        this.isLoading = false;
        await this.showToast(err.error?.message || 'Something went wrong');
      }
    });
  }

  async onVerify() {
    if (!this.otp || this.otp.length < 4) {
      this.showToast('Please enter a valid OTP');
      return;
    }

    this.isLoading = true;

    this.authService.verifyOtp(this.mobile, this.otp).subscribe({
      next: async (res: any) => {
        this.isLoading = false;
        await this.showToast('Login Successful!');

        // Get the role from response
        const role = res.user?.role;

        if (role === 'admin') {
          this.navCtrl.navigateRoot('/admin-dashboard');
        } else {
          this.navCtrl.navigateRoot('/home');
        }
      },
      error: async (err) => {
        this.isLoading = false;
        console.error(err);
        await this.showToast(err.error?.message || 'Invalid OTP');
      }
    });
  }

  async onResendOtp() {
    this.isLoading = true;

    this.authService.sendOtp(this.mobile).subscribe({
      next: async (res: any) => {
        this.isLoading = false;
        await this.showToast('OTP sent successfully');
        this.otp = '';
        this.startOtpTimer();
      },
      error: async (err) => {
        this.isLoading = false;
        await this.showToast(err.error?.message || 'Failed to resend OTP');
      }
    });
  }

  backToMobile() {
    // Clear OTP timer
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }

    this.showOtpStep = false;
    this.otp = '';
    this.otpTimer = 0;
  }

  private startOtpTimer() {
    this.otpTimer = 60;

    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }

    this.timerInterval = setInterval(() => {
      this.otpTimer--;

      if (this.otpTimer <= 0) {
        clearInterval(this.timerInterval);
        this.otpTimer = 0;
      }
    }, 1000);
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
