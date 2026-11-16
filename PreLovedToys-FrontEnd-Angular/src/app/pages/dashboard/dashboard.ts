import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { DatePipe, TitleCasePipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AdminService } from '../../core/services/admin';
import { DashboardData, ORDER_STATUSES, StatsBucket, StatsRange } from '../../core/models';
import { errorMessage, formatAmount, orderTone, orderTotal } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { BarChartComponent, BarDatum } from '../../shared/bar-chart';

type MetricKey = 'orders' | 'cash' | 'points' | 'newUsers' | 'newListings';

interface Metric {
  key: MetricKey;
  label: string;
  format: (n: number) => string;
  current: (d: DashboardData) => number;
  previous: (d: DashboardData) => number;
  field: keyof Omit<StatsBucket, 'bucket'>;
}

const count = (n: number) => n.toLocaleString('en-IN');

const METRICS: Metric[] = [
  { key: 'orders', label: 'Orders', format: count, field: 'orders',
    current: (d) => d.period.orders, previous: (d) => d.previous.orders },
  { key: 'cash', label: 'Rupee revenue', format: (n) => formatAmount(n), field: 'cash',
    current: (d) => Number(d.period.cashRevenue), previous: (d) => Number(d.previous.cashRevenue) },
  { key: 'points', label: 'Points spent', format: (n) => formatAmount(n, true), field: 'points',
    current: (d) => Number(d.period.pointsSpent), previous: (d) => Number(d.previous.pointsSpent) },
  { key: 'newUsers', label: 'New users', format: count, field: 'newUsers',
    current: (d) => d.period.newUsers, previous: (d) => d.previous.newUsers },
  { key: 'newListings', label: 'New listings', format: count, field: 'newListings',
    current: (d) => d.period.newListings, previous: (d) => d.previous.newListings },
];

const RANGES: { key: StatsRange; label: string; previous: string }[] = [
  { key: '7d', label: '7 days', previous: 'previous 7 days' },
  { key: '30d', label: '30 days', previous: 'previous 30 days' },
  { key: '90d', label: '90 days', previous: 'previous 90 days' },
  { key: '12m', label: '12 months', previous: 'previous 12 months' },
];

/** "2026-11-16" / "2026-11" bucket keys, read as calendar dates (no timezone shift). */
function bucketDate(key: string): Date {
  const [y, m, d] = key.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d || 1));
}

@Component({
  selector: 'app-dashboard',
  imports: [RouterLink, DatePipe, TitleCasePipe, IconComponent, BadgeComponent, BarChartComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './dashboard.html',
})
export class DashboardPage {
  private readonly admin = inject(AdminService);

  protected readonly ranges = RANGES;
  protected readonly metrics = METRICS;
  protected readonly statuses = ORDER_STATUSES;
  protected readonly range = signal<StatsRange>('30d');
  protected readonly metricKey = signal<MetricKey>('orders');
  protected readonly showTable = signal(false);
  protected readonly data = signal<DashboardData | null>(null);
  protected readonly loading = signal(true);
  protected readonly error = signal('');

  protected readonly orderTone = orderTone;
  protected readonly orderTotal = orderTotal;

  protected readonly metric = computed(() => METRICS.find((m) => m.key === this.metricKey())!);
  protected readonly rangeInfo = computed(() => RANGES.find((r) => r.key === this.range())!);

  protected readonly chartData = computed<BarDatum[]>(() => {
    const d = this.data();
    if (!d) return [];
    const field = this.metric().field;
    const monthly = d.unit === 'month';
    return d.series.map((b) => {
      const date = bucketDate(b.bucket);
      return {
        key: b.bucket,
        value: b[field],
        label: monthly
          ? date.toLocaleDateString('en-IN', { month: 'long', year: 'numeric', timeZone: 'UTC' })
          : date.toLocaleDateString('en-IN', { weekday: 'short', day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' }),
        tick: monthly
          ? date.toLocaleDateString('en-IN', { month: 'short', year: '2-digit', timeZone: 'UTC' })
          : date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', timeZone: 'UTC' }),
      };
    });
  });

  protected readonly chartEmpty = computed(() => this.chartData().every((d) => d.value === 0));
  protected readonly chartTitle = computed(() => `${this.metric().label} per ${this.data()?.unit === 'month' ? 'month' : 'day'}`);
  protected readonly statusTotal = computed(() => {
    const s = this.data()?.statusBreakdown ?? {};
    return Object.values(s).reduce((a, b) => a + (b ?? 0), 0);
  });

  constructor() {
    this.load();
  }

  protected setRange(range: StatsRange): void {
    if (range === this.range()) return;
    this.range.set(range);
    this.load();
  }

  protected load(): void {
    this.loading.set(true);
    this.error.set('');
    this.admin.getDashboard(this.range()).subscribe({
      next: (res) => {
        this.data.set(res);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, 'Could not load dashboard figures.'));
        this.loading.set(false);
      },
    });
  }

  protected value(m: Metric): string {
    const d = this.data();
    return d ? m.format(m.current(d)) : '—';
  }

  /** "+25%" / "−10%" / "New" / "No change" against the previous period of the same length. */
  protected delta(m: Metric): { text: string; tone: 'up' | 'down' | 'flat' } {
    const d = this.data();
    if (!d) return { text: '', tone: 'flat' };
    const cur = m.current(d);
    const prev = m.previous(d);
    if (cur === prev) return { text: 'No change', tone: 'flat' };
    if (prev === 0) return { text: 'New', tone: 'up' };
    const pct = Math.round(((cur - prev) / prev) * 100);
    return pct >= 0 ? { text: `▲ ${pct}%`, tone: 'up' } : { text: `▼ ${Math.abs(pct)}%`, tone: 'down' };
  }

  protected note(m: Metric): string {
    const d = this.data();
    if (!d) return '';
    switch (m.key) {
      case 'orders': return d.period.cancelledOrders ? `${count(d.period.cancelledOrders)} cancelled (not counted)` : 'Cancelled orders not counted';
      case 'cash': return 'From rupee items in orders';
      case 'points': return 'Paid for points items';
      case 'newUsers': return `${count(d.totals.users)} buyers and sellers in total`;
      case 'newListings': return `${count(d.totals.activeListings)} active right now`;
    }
  }
}
