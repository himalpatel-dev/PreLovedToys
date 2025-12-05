import { Routes } from '@angular/router';
import { LoginComponent } from './pages/auth/login/login';

export const routes: Routes = [
    { path: '', redirectTo: 'login', pathMatch: 'full' },
    { path: 'login', component: LoginComponent },
    { path: 'otp', loadComponent: () => import('./pages/auth/otp/otp').then(m => m.OtpComponent) }
];
