import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { DatePipe, TitleCasePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { UserRecord } from '../../core/models';
import { PagedList } from '../../core/paged-list';
import { errorMessage, formatAmount, initials } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { BadgeComponent } from '../../shared/badge';
import { PagerComponent } from '../../shared/pager';

@Component({
  selector: 'app-users',
  imports: [DatePipe, TitleCasePipe, FormsModule, RouterLink, IconComponent, BadgeComponent, PagerComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './users.html',
})
export class UsersPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  protected readonly list = new PagedList<UserRecord>((p) => this.admin.getUsers(p), {
    limit: 20,
    errorText: 'Could not load users.',
  });
  protected readonly busy = signal<number | null>(null);
  protected readonly initials = initials;
  protected readonly formatAmount = formatAmount;

  protected async toggle(user: UserRecord): Promise<void> {
    const ban = user.isActive;
    const who = user.name || `+91 ${user.mobile}`;
    const ok = await this.ui.confirm({
      title: ban ? `Ban ${who}?` : `Unban ${who}?`,
      message: ban
        ? 'Their account will be marked as banned.'
        : 'Their account will be marked as active again.',
      confirmText: ban ? 'Ban user' : 'Unban user',
      danger: ban,
    });
    if (!ok) return;

    this.busy.set(user.id);
    this.admin.setUserActive(user.id, !ban).subscribe({
      next: () => {
        this.list.updateItem((u) => u.id === user.id, (u) => ({ ...u, isActive: !ban }));
        this.list.moveCount(ban ? 'active' : 'banned', ban ? 'banned' : 'active');
        this.busy.set(null);
        this.ui.toast(ban ? `${who} banned` : `${who} unbanned`);
      },
      error: (err) => {
        this.busy.set(null);
        this.ui.error(errorMessage(err, 'Could not update this user.'));
      },
    });
  }
}
