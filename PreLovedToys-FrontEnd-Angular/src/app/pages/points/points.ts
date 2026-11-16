import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AdminService } from '../../core/services/admin';
import { WalletHolder, WalletSummary } from '../../core/models';
import { PagedList } from '../../core/paged-list';
import { formatAmount, initials } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { PagerComponent } from '../../shared/pager';

/** Every buyer's and seller's points balance, highest first. */
@Component({
  selector: 'app-points',
  imports: [DatePipe, FormsModule, RouterLink, IconComponent, BadgeComponent, PagerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './points.html',
})
export class PointsPage {
  private readonly admin = inject(AdminService);

  protected readonly list = new PagedList<WalletHolder, WalletSummary>((p) => this.admin.getWallets(p), {
    limit: 20,
    errorText: 'Could not load points balances.',
  });
  protected readonly formatAmount = formatAmount;
  protected readonly initials = initials;
}
