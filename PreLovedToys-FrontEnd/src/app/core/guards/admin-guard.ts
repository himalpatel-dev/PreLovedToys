import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AdminGuard implements CanActivate {

  constructor(private router: Router) { }

  canActivate(): boolean {
    // 1. Get User from local storage
    const userStr = localStorage.getItem('user');

    if (userStr) {
      const user = JSON.parse(userStr);
      // 2. Check if role is admin
      if (user.role === 'admin') {
        return true; // Allow access
      }
    }

    // 3. If not admin, kick them out to home
    this.router.navigate(['/home']);
    return false;
  }
}