import { Routes } from '@angular/router';
import { AdminGuard } from './core/guards/admin-guard';

export const routes: Routes = [
  {
    path: 'home',
    loadComponent: () => import('./pages/home/home.page').then((m) => m.HomePage),
  },
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full',
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/auth/login/login.page').then(m => m.LoginPage)
  },
  {
    path: 'otp',
    loadComponent: () => import('./pages/auth/otp/otp.page').then(m => m.OtpPage)
  },
  {
    path: 'productdetails/:id',
    loadComponent: () => import('./pages/productdetails/productdetails.page').then(m => m.ProductdetailsPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'cart',
    loadComponent: () => import('./pages/cart/cart.page').then(m => m.CartPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'checkout',
    loadComponent: () => import('./pages/checkout/checkout.page').then(m => m.CheckoutPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'orders',
    loadComponent: () => import('./pages/orders/orders.page').then(m => m.OrdersPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'sell',
    loadComponent: () => import('./pages/sell/sell.page').then(m => m.SellPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'admin-dashboard',
    loadComponent: () => import('./pages/admin/admin-dashboard/admin-dashboard.page').then(m => m.AdminDashboardPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'profile',
    loadComponent: () => import('./pages/profile/profile.page').then(m => m.ProfilePage),
    canActivate: [AdminGuard]
  },
  {
    path: 'sub-categories/:categoryId',
    loadComponent: () => import('./pages/sub-categories/sub-categories.page').then(m => m.SubCategoriesPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'product-list',
    loadComponent: () => import('./pages/product-list/product-list.page').then(m => m.ProductListPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'categories',
    loadComponent: () => import('./pages/admin/categories/categories.page').then(m => m.CategoriesPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'sub-categories',
    loadComponent: () => import('./pages/admin/sub-categories/sub-categories.page').then(m => m.SubCategoriesPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'age-groups',
    loadComponent: () => import('./pages/admin/age-groups/age-groups.page').then(m => m.AgeGroupsPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'colors',
    loadComponent: () => import('./pages/admin/colors/colors.page').then(m => m.ColorsPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'genders',
    loadComponent: () => import('./pages/admin/genders/genders.page').then(m => m.GendersPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'materials',
    loadComponent: () => import('./pages/admin/materials/materials.page').then(m => m.MaterialsPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'users',
    loadComponent: () => import('./pages/admin/users/users.page').then(m => m.UsersPage),
    canActivate: [AdminGuard]
  },
  {
    path: 'admin-orders',
    loadComponent: () => import('./pages/admin/orders/orders.page').then(m => m.OrdersPage),
    canActivate: [AdminGuard]
  },





];
