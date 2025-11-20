import { Injectable } from '@angular/core';
import { ApiService } from './api.service';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor(private api: ApiService) { }

  // 1. Send OTP
  sendOtp(mobile: string) {
    return this.api.post('auth/send-otp', { mobile });
  }

  // 2. Verify OTP & Save Token
  verifyOtp(mobile: string, otp: string) {
    return this.api.post('auth/verify-otp', { mobile, otp }).pipe(
      tap((response: any) => {
        if (response && response.token) {
          // Save token to LocalStorage (Browser/Phone memory)
          localStorage.setItem('token', response.token);

          // Save basic user info stringified
          localStorage.setItem('user', JSON.stringify(response.user));
        }
      })
    );
  }

  // 3. Logout
  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  }

  // 4. Check if user is logged in
  isLoggedIn(): boolean {
    return !!localStorage.getItem('token'); // Returns true if token exists
  }
}