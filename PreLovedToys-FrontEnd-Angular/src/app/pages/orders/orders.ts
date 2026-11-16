import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { DatePipe, TitleCasePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { ORDER_STATUSES, Order, OrderStatus } from '../../core/models';
import { PagedList } from '../../core/paged-list';
import { errorMessage, formatAmount, orderTone, orderTotal } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { ThumbComponent } from '../../shared/thumb';
import { PagerComponent } from '../../shared/pager';

@Component({
  selector: 'app-orders',
  imports: [DatePipe, TitleCasePipe, FormsModule, IconComponent, BadgeComponent, ThumbComponent, PagerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './orders.html',
})
export class OrdersPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  protected readonly statuses = ORDER_STATUSES;
  protected readonly list = new PagedList<Order>((p) => this.admin.getOrders(p), {
    limit: 20,
    errorText: 'Could not load orders.',
  });
  protected readonly expanded = signal<number | null>(null);
  protected readonly updating = signal<number | null>(null);

  protected readonly formatAmount = formatAmount;
  protected readonly orderTone = orderTone;
  protected readonly orderTotal = orderTotal;

  /** How the order was paid, from its separate totals. */
  protected payment(o: Order): string {
    const points = Number(o.pointsTotal ?? 0);
    const cash = Number(o.cashTotal ?? 0);
    if (points && cash) return 'Points + rupees';
    if (points || (!cash && o.isPoints)) return 'Points';
    return 'Rupees';
  }

  protected toggle(id: number): void {
    this.expanded.update((cur) => (cur === id ? null : id));
  }

  protected async changeStatus(order: Order, select: HTMLSelectElement): Promise<void> {
    const next = select.value as OrderStatus;
    if (next === order.status) return;

    if (next === 'cancelled') {
      const split = Number(order.pointsTotal ?? 0) || Number(order.cashTotal ?? 0);
      const points = split ? Number(order.pointsTotal ?? 0) : order.isPoints ? Number(order.totalAmount) : 0;
      const ok = await this.ui.confirm({
        title: `Cancel order #${order.id}?`,
        message:
          (points ? `${formatAmount(points, true)} go back to the buyer and are taken back from the seller. ` : '') +
          'The items go back on sale. This can’t be undone.',
        confirmText: 'Cancel order',
        danger: true,
      });
      if (!ok) {
        select.value = order.status;
        return;
      }
    }

    this.updating.set(order.id);
    this.admin.setOrderStatus(order.id, next).subscribe({
      next: (res) => {
        this.list.updateItem((o) => o.id === order.id, (o) => ({ ...o, ...res.order, user: o.user, items: o.items }));
        this.list.moveCount(order.status, next);
        this.updating.set(null);
        const r = res.reversal;
        this.ui.toast(
          r
            ? `Order #${order.id} cancelled. ${r.pointsRefunded ? formatAmount(r.pointsRefunded, true) + ' refunded, ' : ''}` +
                `${r.listingsRestored} item${r.listingsRestored === 1 ? '' : 's'} back on sale.`
            : `Order #${order.id} marked as ${next}`
        );
      },
      error: (err) => {
        select.value = order.status;
        this.updating.set(null);
        this.ui.error(errorMessage(err, 'Could not update the order status.'));
      },
    });
  }
}
