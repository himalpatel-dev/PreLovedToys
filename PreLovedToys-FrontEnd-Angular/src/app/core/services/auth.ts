import { Injectable } from '@angular/core';
import { ApiService } from './api';
import { tap } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor(private api: ApiService) { }

  sendOtp(mobile: string) {
    return this.api.post('auth/send-otp', { mobile });
  }

  verifyOtp(mobile: string, otp: string) {
    return this.api.post('auth/verify-otp', { mobile, otp }).pipe(
      tap((response: any) => {
        if (response && response.token) {
          localStorage.setItem('token', response.token);
          localStorage.setItem('user', JSON.stringify(response.user));
        }
      })
    );
  }

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  }

  isLoggedIn(): boolean {
    return !!localStorage.getItem('token');
  }
}
