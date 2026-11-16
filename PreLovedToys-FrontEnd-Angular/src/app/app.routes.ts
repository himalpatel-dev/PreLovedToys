import { Routes } from '@angular/router';
import { adminGuard, guestGuard } from './core/auth.guards';
import { AdminLayout } from './layout/admin-layout';
import { MASTER_CONFIGS } from './pages/masters/master-configs';

const masters = () => import('./pages/masters/masters').then((m) => m.MastersPage);

export const routes: Routes = [
  {
    path: 'login',
    title: 'Sign in · PreLovedToys Admin',
    canActivate: [guestGuard],
    loadComponent: () => import('./pages/auth/login/login').then((m) => m.LoginComponent),
  },
  {
    path: 'otp',
    title: 'Verify · PreLovedToys Admin',
    canActivate: [guestGuard],
    loadComponent: () => import('./pages/auth/otp/otp').then((m) => m.OtpComponent),
  },
  {
    path: '',
    component: AdminLayout,
    canActivate: [adminGuard],
    canActivateChild: [adminGuard],
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        title: 'Dashboard · PreLovedToys Admin',
        loadComponent: () => import('./pages/dashboard/dashboard').then((m) => m.DashboardPage),
      },
      {
        path: 'orders',
        title: 'Orders · PreLovedToys Admin',
        loadComponent: () => import('./pages/orders/orders').then((m) => m.OrdersPage),
      },
      {
        path: 'products',
        title: 'Products · PreLovedToys Admin',
        loadComponent: () => import('./pages/products/products').then((m) => m.ProductsPage),
      },
      {
        path: 'products/:id',
        title: 'Product · PreLovedToys Admin',
        loadComponent: () =>
          import('./pages/product-detail/product-detail').then((m) => m.ProductDetailPage),
      },
      {
        path: 'users',
        title: 'Users · PreLovedToys Admin',
        loadComponent: () => import('./pages/users/users').then((m) => m.UsersPage),
      },
      {
        path: 'users/:id',
        title: 'User · PreLovedToys Admin',
        loadComponent: () => import('./pages/user-detail/user-detail').then((m) => m.UserDetailPage),
      },
      {
        path: 'settings',
        title: 'Points rules · PreLovedToys Admin',
        loadComponent: () => import('./pages/settings/settings').then((m) => m.SettingsPage),
      },
      {
        path: 'points',
        title: 'Points · PreLovedToys Admin',
        loadComponent: () => import('./pages/points/points').then((m) => m.PointsPage),
      },
      {
        path: 'points/:userId',
        title: 'Points history · PreLovedToys Admin',
        loadComponent: () =>
          import('./pages/points-detail/points-detail').then((m) => m.PointsDetailPage),
      },
      {
        path: 'categories',
        title: 'Categories · PreLovedToys Admin',
        loadComponent: () => import('./pages/categories/categories').then((m) => m.CategoriesPage),
      },
      {
        path: 'sub-categories',
        title: 'Sub-categories · PreLovedToys Admin',
        loadComponent: () =>
          import('./pages/subcategories/subcategories').then((m) => m.SubCategoriesPage),
      },
      ...MASTER_CONFIGS.map((config) => ({
        path: config.key,
        title: `${config.title} · PreLovedToys Admin`,
        loadComponent: masters,
        data: { master: config },
      })),
    ],
  },
  { path: '**', redirectTo: '' },
];
