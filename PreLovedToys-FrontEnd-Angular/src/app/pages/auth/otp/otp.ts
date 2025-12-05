import { Component, OnInit, OnDestroy, ViewChild, ElementRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth';

@Component({
  selector: 'app-otp',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './otp.html',
  styleUrls: ['./otp.scss']
})
export class OtpComponent implements OnInit, OnDestroy {

  mobile: string = '';
  otp: string = '';
  otpDigits: string[] = ['', '', '', ''];
  isLoading: boolean = false;
  otpTimer: number = 60;
  private timerInterval: any;

  @ViewChild('otp1') otp1!: ElementRef;
  @ViewChild('otp2') otp2!: ElementRef;
  @ViewChild('otp3') otp3!: ElementRef;
  @ViewChild('otp4') otp4!: ElementRef;

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private authService: AuthService
  ) { }

  ngOnInit() {
    this.route.queryParams.subscribe(params => {
      if (params && params['mobile']) {
        this.mobile = params['mobile'];
      } else {
        this.router.navigate(['/login']);
      }
    });

    this.startOtpTimer();
  }

  ngOnDestroy() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
    }
  }

  onOtpInput(event: any, index: number) {
    const value = event.target.value;

    if (value && !/^[0-9]$/.test(value)) {
      this.otpDigits[index] = '';
      return;
    }

    this.otpDigits[index] = value;
    this.otp = this.otpDigits.join('');

    if (value && index < 3) {
      const nextInput = this.getOtpInput(index + 1);
      if (nextInput) {
        nextInput.nativeElement.focus();
      }
    }

    if (this.otp.length === 4) {
      setTimeout(() => {
        this.onVerify();
      }, 300);
    }
  }

  onOtpKeydown(event: KeyboardEvent, index: number) {
    if (event.key === 'Backspace' && !this.otpDigits[index] && index > 0) {
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
      alert('Please enter a valid OTP');
      return;
    }

    this.isLoading = true;

    this.authService.verifyOtp(this.mobile, this.otp).subscribe({
      next: (res: any) => {
        this.isLoading = false;
        alert('Login Successful!');
        this.router.navigate(['/home']);
      },
      error: (err: any) => {
        this.isLoading = false;
        alert(err.error?.message || 'Invalid OTP');
      }
    });
  }

  onResendOtp() {
    this.isLoading = true;

    this.authService.sendOtp(this.mobile).subscribe({
      next: (res: any) => {
        this.isLoading = false;
        alert('OTP sent successfully');
        this.otp = '';
        this.otpDigits = ['', '', '', ''];
        this.startOtpTimer();
      },
      error: (err: any) => {
        this.isLoading = false;
        alert(err.error?.message || 'Failed to resend OTP');
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

  changeMobile() {
    this.router.navigate(['/login']);
  }
}
