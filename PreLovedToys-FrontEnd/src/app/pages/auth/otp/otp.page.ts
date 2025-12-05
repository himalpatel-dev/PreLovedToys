import { Component, OnInit, ViewChild, ElementRef, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, NavController, ToastController } from '@ionic/angular';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { AuthService } from 'src/app/core/services/auth.service';
import { addIcons } from 'ionicons';
import { lockClosed, timeOutline, refreshOutline, checkmarkCircle, createOutline } from 'ionicons/icons';

@Component({
  selector: 'app-otp',
  templateUrl: './otp.page.html',
  styleUrls: ['./otp.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule, RouterModule]
})
export class OtpPage implements OnInit, OnDestroy {

  mobile: string = '';
  otp: string = '';
  otpDigits: string[] = ['', '', '', ''];
  isLoading: boolean = false;
  otpTimer: number = 60;
  private timerInterval: any;

  // ViewChild references for OTP inputs
  @ViewChild('otp1') otp1!: ElementRef;
  @ViewChild('otp2') otp2!: ElementRef;
  @ViewChild('otp3') otp3!: ElementRef;
  @ViewChild('otp4') otp4!: ElementRef;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService,
    private navCtrl: NavController,
    private toastCtrl: ToastController
  ) {
    addIcons({
      lockClosed,
      timeOutline,
      refreshOutline,
      checkmarkCircle,
      createOutline
    });
  }

  ngOnInit() {
    // Read the mobile number passed from Login Page
    this.route.queryParams.subscribe(params => {
      if (params && params['mobile']) {
        this.mobile = params['mobile'];
      } else {
        // If no mobile number, redirect to login
        this.navCtrl.navigateRoot('/login');
      }
    });

    // Start OTP timer
    this.startOtpTimer();
  }

  ngOnDestroy() {
    // Clear timer when component is destroyed
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }
  }

  // Handle OTP input with auto-focus
  onOtpInput(event: any, index: number) {
    const value = event.target.value;

    // Only allow numbers
    if (value && !/^[0-9]$/.test(value)) {
      this.otpDigits[index] = '';
      return;
    }

    // Update the digit
    this.otpDigits[index] = value;

    // Combine all digits to form OTP
    this.otp = this.otpDigits.join('');

    // Auto-focus to next input
    if (value && index < 3) {
      const nextInput = this.getOtpInput(index + 1);
      if (nextInput) {
        nextInput.nativeElement.focus();
      }
    }

    // Auto-verify when all 4 digits are entered
    if (this.otp.length === 4) {
      setTimeout(() => {
        this.onVerify();
      }, 300);
    }
  }

  // Handle backspace and arrow keys
  onOtpKeydown(event: KeyboardEvent, index: number) {
    if (event.key === 'Backspace' && !this.otpDigits[index] && index > 0) {
      // Move to previous input on backspace if current is empty
      const prevInput = this.getOtpInput(index - 1);
      if (prevInput) {
        prevInput.nativeElement.focus();
      }
    } else if (event.key === 'ArrowLeft' && index > 0) {
      const prevInput = this.getOtpInput(index - 1);
      if (prevInput) {
        prevInput.nativeElement.focus();
      }
    } else if (event.key === 'ArrowRight' && index < 3) {
      const nextInput = this.getOtpInput(index + 1);
      if (nextInput) {
        nextInput.nativeElement.focus();
      }
    }
  }

  // Get OTP input reference by index
  private getOtpInput(index: number): ElementRef | null {
    switch (index) {
      case 0: return this.otp1;
      case 1: return this.otp2;
      case 2: return this.otp3;
      case 3: return this.otp4;
      default: return null;
    }
  }

  onVerify() {
    if (!this.otp || this.otp.length < 4) {
      this.showToast('Please enter a valid OTP');
      return;
    }

    this.isLoading = true;

    this.authService.verifyOtp(this.mobile, this.otp).subscribe({
      next: (res: any) => {
      }
    });
    this.isLoading = false;
    this.navCtrl.navigateRoot('/home');
  }

  onResendOtp() {
    this.isLoading = true;

    this.authService.sendOtp(this.mobile).subscribe({
      next: (res: any) => {
        this.isLoading = false;
        this.showToast('OTP sent successfully');
        this.otp = '';
        this.otpDigits = ['', '', '', ''];
        this.startOtpTimer();
      },
      error: (err: any) => {
        this.isLoading = false;
        this.showToast(err.error?.message || 'Failed to resend OTP');
      }
    });
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