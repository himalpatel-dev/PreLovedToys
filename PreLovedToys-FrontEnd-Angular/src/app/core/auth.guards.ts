import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './services/auth';

/** Lets only a signed-in admin through; everyone else goes to /login. */
export const adminGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.isAdmin()) return true;
  auth.logout();
  return inject(Router).createUrlTree(['/login']);
};

/** Keeps a signed-in admin away from the login screens. */
export const guestGuard: CanActivateFn = () => {
  return inject(AuthService).isAdmin() ? inject(Router).createUrlTree(['/dashboard']) : true;
};
