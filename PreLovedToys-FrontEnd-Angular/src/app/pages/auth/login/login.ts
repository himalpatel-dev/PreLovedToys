import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrls: ['./login.scss']
})
export class LoginComponent {

  mobile: string = '9727376727';
  isLoading: boolean = false;

  constructor(
    private authService: AuthService,
    private router: Router
  ) { }

  onSendOtp() {
    if (!this.mobile || this.mobile.length < 10) {
      alert('Please enter a valid mobile number');
      return;
    }

    this.isLoading = true;

    this.authService.sendOtp(this.mobile).subscribe({
      next: (res: any) => {
        console.log('Response:', res);
        alert(`${res.message}`);
        this.isLoading = false;

        // Navigate to OTP page with mobile number
        this.router.navigate(['/otp'], {
          queryParams: { mobile: this.mobile }
        });
      },
      error: (err) => {
        console.error(err);
        this.isLoading = false;
        alert(err.error?.message || 'Something went wrong');
      }
    });
  }

  showTerms() {
    console.log('Show Terms');
    // Implement modal or navigation
  }
}
