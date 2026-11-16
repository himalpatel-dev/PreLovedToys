import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { DatePipe, TitleCasePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AdminService } from '../../core/services/admin';
import { PRODUCT_STATUSES, Product } from '../../core/models';
import { PagedList } from '../../core/paged-list';
import { formatAmount, productTone } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { ThumbComponent } from '../../shared/thumb';
import { PagerComponent } from '../../shared/pager';

@Component({
  selector: 'app-products',
  imports: [DatePipe, TitleCasePipe, FormsModule, RouterLink, IconComponent, BadgeComponent, ThumbComponent, PagerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './products.html',
})
export class ProductsPage {
  private readonly admin = inject(AdminService);

  protected readonly statuses = PRODUCT_STATUSES;
  protected readonly list = new PagedList<Product>((p) => this.admin.getProducts(p), {
    limit: 20,
    errorText: 'Could not load products.',
  });

  protected readonly formatAmount = formatAmount;
  protected readonly productTone = productTone;

  protected cover(p: Product): string | undefined {
    const primary = p.images?.find((i) => i.isPrimary) ?? p.images?.[0];
    return primary?.imageUrl;
  }
}
