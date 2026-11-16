import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal, untracked } from '@angular/core';
import { DatePipe, NgTemplateOutlet, TitleCasePipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { Order, Product, UserDetail } from '../../core/models';
import { PagedList } from '../../core/paged-list';
import { errorMessage, formatAmount, initials, orderTone, orderTotal, productTone } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { ThumbComponent } from '../../shared/thumb';
import { PagerComponent } from '../../shared/pager';

type Tab = 'listings' | 'purchases' | 'sales';

/** Everything about one user: profile, points, listings, what they bought and what they sold. */
@Component({
  selector: 'app-user-detail',
  imports: [DatePipe, TitleCasePipe, NgTemplateOutlet, RouterLink, IconComponent, BadgeComponent, ThumbComponent, PagerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './user-detail.html',
})
export class UserDetailPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  /** Bound from the :id route param. */
  readonly id = input.required<string>();

  protected readonly detail = signal<UserDetail | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal('');
  protected readonly busy = signal(false);
  protected readonly tab = signal<Tab>('listings');

  protected readonly formatAmount = formatAmount;
  protected readonly initials = initials;
  protected readonly orderTone = orderTone;
  protected readonly orderTotal = orderTotal;
  protected readonly productTone = productTone;

  private readonly userId = computed(() => Number(this.id()));

  protected readonly listings = new PagedList<Product>(
    (p) => this.admin.getProducts(p, { sellerId: this.userId() }),
    { limit: 10, autoLoad: false, errorText: 'Could not load listings.' }
  );
  protected readonly purchases = new PagedList<Order>(
    (p) => this.admin.getOrders(p, { userId: this.userId() }),
    { limit: 10, autoLoad: false, errorText: 'Could not load orders.' }
  );
  protected readonly sales = new PagedList<Order>(
    (p) => this.admin.getOrders(p, { sellerId: this.userId() }),
    { limit: 10, autoLoad: false, errorText: 'Could not load sales.' }
  );

  /** Profile fields that are filled in, for the "About" card. */
  protected readonly profile = computed(() => {
    const u = this.detail()?.user;
    if (!u) return [];
    return [
      ['Email', u.email],
      ['Gender', u.gender],
      ['Occupation', u.occupation],
      ['College / university', u.collegeOrUniversity],
      ['Here to', u.purpose],
      ['About', u.aboutMe],
    ].filter(([, v]) => !!v) as [string, string][];
  });

  constructor() {
    effect(() => {
      this.userId();
      untracked(() => this.reload());
    });
  }

  protected reload(): void {
    this.loading.set(true);
    this.error.set('');
    this.admin.getUserDetail(this.userId()).subscribe({
      next: (res) => {
        this.detail.set(res);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, 'Could not load this user.'));
        this.loading.set(false);
      },
    });
    this.listings.goTo(1);
    this.purchases.goTo(1);
    this.sales.goTo(1);
  }

  protected cover(p: Product): string | undefined {
    return (p.images?.find((i) => i.isPrimary) ?? p.images?.[0])?.imageUrl;
  }

  protected async toggleBan(): Promise<void> {
    const d = this.detail();
    if (!d) return;
    const u = d.user;
    const ban = u.isActive;
    const who = u.name || `+91 ${u.mobile}`;
    const ok = await this.ui.confirm({
      title: ban ? `Ban ${who}?` : `Unban ${who}?`,
      message: ban
        ? 'They are signed out at once and can’t sign in again until unbanned. Their listings stay as they are.'
        : 'They can sign in and use the app again.',
      confirmText: ban ? 'Ban user' : 'Unban user',
      danger: ban,
    });
    if (!ok) return;

    this.busy.set(true);
    this.admin.setUserActive(u.id, !ban).subscribe({
      next: () => {
        this.detail.set({ ...d, user: { ...u, isActive: !ban } });
        this.busy.set(false);
        this.ui.toast(ban ? `${who} banned` : `${who} unbanned`);
      },
      error: (err) => {
        this.busy.set(false);
        this.ui.error(errorMessage(err, 'Could not update this user.'));
      },
    });
  }
}
