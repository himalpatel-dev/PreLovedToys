import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { filter } from 'rxjs/operators';
import { AuthService } from '../core/services/auth';
import { UiService } from '../core/services/ui';
import { initials } from '../core/utils';
import { IconComponent, IconName } from '../shared/icon';
import { MASTER_CONFIGS } from '../pages/masters/master-configs';

interface NavItem {
  label: string;
  path: string;
  icon: IconName;
}

@Component({
  selector: 'app-admin-layout',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, IconComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './admin-layout.html',
})
export class AdminLayout {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  private readonly ui = inject(UiService);

  protected readonly user = this.auth.user;
  protected readonly initials = initials;
  protected readonly menuOpen = signal(false);

  protected readonly sections: { title: string; items: NavItem[] }[] = [
    {
      title: 'Overview',
      items: [{ label: 'Dashboard', path: '/dashboard', icon: 'dashboard' }],
    },
    {
      title: 'Marketplace',
      items: [
        { label: 'Orders', path: '/orders', icon: 'orders' },
        { label: 'Products', path: '/products', icon: 'products' },
        { label: 'Users', path: '/users', icon: 'users' },
        { label: 'Points', path: '/points', icon: 'wallet' },
      ],
    },
    {
      title: 'Catalogue',
      items: [
        { label: 'Categories', path: '/categories', icon: 'categories' },
        { label: 'Sub-categories', path: '/sub-categories', icon: 'list' },
        ...MASTER_CONFIGS.map((m) => ({ label: m.title, path: `/${m.key}`, icon: m.icon })),
      ],
    },
    {
      title: 'Settings',
      items: [{ label: 'Points rules', path: '/settings', icon: 'wallet' }],
    },
  ];

  constructor() {
    this.router.events
      .pipe(filter((e) => e instanceof NavigationEnd), takeUntilDestroyed())
      .subscribe(() => this.menuOpen.set(false));
  }

  protected async logout(): Promise<void> {
    const ok = await this.ui.confirm({ title: 'Sign out?', confirmText: 'Sign out' });
    if (!ok) return;
    this.auth.logout();
    this.router.navigate(['/login']);
  }
}
