import { ChangeDetectionStrategy, Component, computed, effect, inject, input, signal, untracked } from '@angular/core';
import { DatePipe, TitleCasePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { map } from 'rxjs/operators';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { Amount, UserRecord, WalletTransaction, WalletTxType } from '../../core/models';
import { PagedList } from '../../core/paged-list';
import { Tone, errorMessage, formatAmount } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { PagerComponent } from '../../shared/pager';

const MAX_ADJUSTMENT = 1000000; // matches the backend limit

interface WalletHeader {
  user: UserRecord;
  balance: Amount;
}

/** One user's points: balance, manual adjustment, and transaction history. */
@Component({
  selector: 'app-points-detail',
  imports: [DatePipe, TitleCasePipe, FormsModule, RouterLink, IconComponent, BadgeComponent, PagerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './points-detail.html',
})
export class PointsDetailPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  /** Bound from the :userId route param. */
  readonly userId = input.required<string>();

  protected readonly list = new PagedList<WalletTransaction, WalletHeader>(
    (p) =>
      this.admin
        .getWallet(Number(this.userId()), p)
        .pipe(map((r) => ({ ...r, summary: { user: r.user, balance: r.balance } }))),
    { limit: 15, autoLoad: false, errorText: 'Could not load this user’s points.' }
  );

  protected readonly mode = signal<'add' | 'remove'>('add');
  protected readonly amount = signal('');
  protected readonly reason = signal('');
  protected readonly saving = signal(false);
  protected readonly formatAmount = formatAmount;

  protected readonly user = computed(() => this.list.summary()?.user ?? null);
  protected readonly balance = computed(() => Number(this.list.summary()?.balance ?? 0));

  /** The amount typed, if it is a valid whole number within limits. */
  protected readonly parsedAmount = computed(() => {
    const text = this.amount().trim();
    if (!/^\d+$/.test(text)) return null;
    const n = Number(text);
    return n >= 1 && n <= MAX_ADJUSTMENT ? n : null;
  });

  protected readonly amountError = computed(() => {
    if (!this.amount().trim()) return '';
    const n = this.parsedAmount();
    if (n === null) return `Enter a whole number from 1 to ${MAX_ADJUSTMENT.toLocaleString('en-IN')}.`;
    if (this.mode() === 'remove' && n > this.balance()) {
      return `They only have ${formatAmount(this.balance(), true)}.`;
    }
    return '';
  });

  protected readonly canSubmit = computed(
    () => !this.saving() && this.parsedAmount() !== null && !this.amountError() && this.reason().trim().length >= 3
  );

  constructor() {
    // Load (or reload) whenever the route param changes.
    effect(() => {
      this.userId();
      untracked(() => this.list.goTo(1));
    });
  }

  protected setMode(mode: 'add' | 'remove'): void {
    this.mode.set(mode);
  }

  protected async submit(): Promise<void> {
    const n = this.parsedAmount();
    const user = this.user();
    if (!this.canSubmit() || n === null || !user) return;

    const adding = this.mode() === 'add';
    const who = user.name || `+91 ${user.mobile}`;
    const newBalance = this.balance() + (adding ? n : -n);
    const ok = await this.ui.confirm({
      title: `${adding ? 'Add' : 'Remove'} ${formatAmount(n, true)} ${adding ? 'to' : 'from'} ${who}?`,
      message: `New balance: ${formatAmount(newBalance, true)}. Reason: “${this.reason().trim()}”. This is recorded in their history.`,
      confirmText: adding ? 'Add points' : 'Remove points',
      danger: !adding,
    });
    if (!ok) return;

    this.saving.set(true);
    this.admin.adjustPoints(user.id, adding ? n : -n, this.reason().trim()).subscribe({
      next: (res) => {
        this.saving.set(false);
        this.amount.set('');
        this.reason.set('');
        this.ui.toast(`${adding ? 'Added' : 'Removed'} ${formatAmount(n, true)}. New balance: ${formatAmount(res.balance, true)}`);
        this.list.goTo(1);
      },
      error: (err) => {
        this.saving.set(false);
        this.ui.error(errorMessage(err, 'Could not adjust points.'));
      },
    });
  }

  protected txTone(type: WalletTxType): Tone {
    return type === 'credit' ? 'success' : type === 'debit' ? 'danger' : 'info';
  }

  protected signedAmount(tx: WalletTransaction): string {
    const value = Number(tx.amount).toLocaleString('en-IN');
    if (tx.type === 'credit') return `+${value}`;
    if (tx.type === 'debit') return `−${value}`;
    return value;
  }
}
