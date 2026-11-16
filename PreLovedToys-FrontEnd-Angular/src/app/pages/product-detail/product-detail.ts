import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal } from '@angular/core';
import { DatePipe, TitleCasePipe } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { PRODUCT_STATUSES, Product, ProductStatus } from '../../core/models';
import { errorMessage, formatAmount, imageUrl, productTone } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { ProductEditComponent } from './product-edit';
import { ProductPhotosComponent } from './product-photos';

const STATUS_HELP: Record<ProductStatus, string> = {
  active: 'Visible to buyers in the app.',
  pending: 'Hidden from buyers until approved.',
  sold: 'Marked as sold; hidden from buyers.',
  rejected: 'Taken down; hidden from buyers.',
};

@Component({
  selector: 'app-product-detail',
  imports: [DatePipe, TitleCasePipe, RouterLink, IconComponent, BadgeComponent, ProductEditComponent, ProductPhotosComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './product-detail.html',
})
export class ProductDetailPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);
  private readonly router = inject(Router);

  /** Bound from the :id route param. */
  readonly id = input.required<string>();

  protected readonly statuses = PRODUCT_STATUSES;
  protected readonly statusHelp = STATUS_HELP;
  protected readonly product = signal<Product | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal('');
  protected readonly saving = signal(false);
  protected readonly selected = signal(0);
  protected readonly editing = signal(false);
  /** URL of the main photo if it failed to load. */
  protected readonly mainBroken = signal<string | null>(null);

  protected readonly formatAmount = formatAmount;
  protected readonly productTone = productTone;

  protected readonly images = computed(() =>
    (this.product()?.images ?? []).map((i) => imageUrl(i.imageUrl)).filter((u): u is string => !!u)
  );

  constructor() {
    effect(() => this.load(Number(this.id())));
  }

  private load(id: number): void {
    this.loading.set(true);
    this.error.set('');
    this.selected.set(0);
    this.admin.getProduct(id).subscribe({
      next: (res) => {
        this.product.set(res);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, 'Could not load this product.'));
        this.loading.set(false);
      },
    });
  }

  protected onEdited(updated: Product): void {
    this.product.set(updated);
    this.selected.set(0);
    this.editing.set(false);
  }

  protected onPhotosChanged(updated: Product): void {
    this.product.set(updated);
    this.selected.set(0);
  }

  /** Listings that appear in orders can't be deleted; the server says so and we show it. */
  protected async remove(): Promise<void> {
    const p = this.product();
    if (!p) return;
    const ok = await this.ui.confirm({
      title: `Delete “${p.title}”?`,
      message: 'The listing, its photos, and any cart or favourite entries are removed for good.',
      confirmText: 'Delete listing',
      danger: true,
    });
    if (!ok) return;

    this.saving.set(true);
    this.admin.deleteProduct(p.id).subscribe({
      next: () => {
        this.saving.set(false);
        this.ui.toast(`“${p.title}” deleted`);
        this.router.navigate(['/products']);
      },
      error: (err) => {
        this.saving.set(false);
        this.ui.error(errorMessage(err, 'Could not delete the listing.'));
      },
    });
  }

  protected async setStatus(status: ProductStatus): Promise<void> {
    const p = this.product();
    if (!p || p.status === status) return;

    if (status === 'rejected') {
      const ok = await this.ui.confirm({
        title: 'Reject this listing?',
        message: `"${p.title}" will be hidden from buyers. You can make it active again later.`,
        confirmText: 'Reject listing',
        danger: true,
      });
      if (!ok) return;
    }

    this.saving.set(true);
    this.admin.setProductStatus(p.id, status).subscribe({
      next: () => {
        this.product.set({ ...p, status });
        this.saving.set(false);
        this.ui.toast(`Listing marked as ${status}`);
      },
      error: (err) => {
        this.saving.set(false);
        this.ui.error(errorMessage(err, 'Could not update the listing.'));
      },
    });
  }
}
