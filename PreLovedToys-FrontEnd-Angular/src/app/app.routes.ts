import { Routes } from '@angular/router';
import { LoginComponent } from './pages/auth/login/login';
import { HomeComponent } from './pages/home/home';
import { ProductDetailComponent } from './pages/product-detail/product-detail';
import { SubCategoryComponent } from './pages/subcategory/subcategory';
import { SellComponent } from './pages/sell/sell';

export const routes: Routes = [
    { path: '', redirectTo: 'home', pathMatch: 'full' },
    { path: 'home', component: HomeComponent },
    { path: 'product/:id', component: ProductDetailComponent },
    { path: 'category/:id', component: SubCategoryComponent },
    { path: 'sell', component: SellComponent },
    { path: 'login', component: LoginComponent },
    { path: 'otp', loadComponent: () => import('./pages/auth/otp/otp').then(m => m.OtpComponent) }
];
