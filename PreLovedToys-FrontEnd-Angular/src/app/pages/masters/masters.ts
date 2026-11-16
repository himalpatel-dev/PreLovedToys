import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { AdminService, MasterPayload } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { MasterItem } from '../../core/models';
import { errorMessage } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { ModalComponent } from '../../shared/modal';
import { MasterConfig } from './master-configs';

interface MasterForm {
  id: number | null;
  name: string;
  hexCode: string;
}

const HEX = /^#[0-9a-f]{6}$/i;

/** One page for age groups, genders, materials and colors; the route's data picks which. */
@Component({
  selector: 'app-masters',
  imports: [FormsModule, IconComponent, ModalComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './masters.html',
})
export class MastersPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);
  protected readonly config = inject(ActivatedRoute).snapshot.data['master'] as MasterConfig;

  protected readonly items = signal<MasterItem[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal('');
  protected readonly query = signal('');
  protected readonly form = signal<MasterForm | null>(null);
  protected readonly saving = signal(false);

  protected readonly filtered = computed(() => {
    const q = this.query().trim().toLowerCase();
    return q ? this.items().filter((i) => i.name.toLowerCase().includes(q)) : this.items();
  });

  constructor() {
    this.load();
  }

  protected load(): void {
    this.loading.set(true);
    this.error.set('');
    this.admin.getMasters(this.config.key).subscribe({
      next: (res) => {
        this.items.set(res);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, `Could not load ${this.config.title.toLowerCase()}.`));
        this.loading.set(false);
      },
    });
  }

  protected open(item?: MasterItem): void {
    this.form.set({ id: item?.id ?? null, name: item?.name ?? '', hexCode: item?.hexCode ?? '#2F4B4E' });
  }

  protected close(): void {
    if (!this.saving()) this.form.set(null);
  }

  protected patch(changes: Partial<MasterForm>): void {
    this.form.update((f) => (f ? { ...f, ...changes } : f));
  }

  protected validHex(value: string): boolean {
    return HEX.test(value);
  }

  protected save(): void {
    const f = this.form();
    if (!f) return;
    const name = f.name.trim();
    if (!name) {
      this.ui.error('Name is required.');
      return;
    }
    const payload: MasterPayload = { name };
    if (this.config.hasHex) {
      const hex = f.hexCode.trim();
      if (!HEX.test(hex)) {
        this.ui.error('Enter the color as a hex code, e.g. #FF0000.');
        return;
      }
      payload.hexCode = hex.toUpperCase();
    }

    this.saving.set(true);
    const request = f.id
      ? this.admin.updateMaster(this.config.key, f.id, payload)
      : this.admin.createMaster(this.config.key, payload);

    request.subscribe({
      next: () => {
        this.saving.set(false);
        this.form.set(null);
        this.ui.toast(f.id ? `“${name}” updated` : `“${name}” created`);
        this.load();
      },
      error: (err) => {
        this.saving.set(false);
        this.ui.error(errorMessage(err, `Could not save this ${this.config.singular}.`));
      },
    });
  }

  protected async remove(item: MasterItem): Promise<void> {
    const ok = await this.ui.confirm({
      title: `Delete “${item.name}”?`,
      message: `Products using this ${this.config.singular} may lose it.`,
      confirmText: 'Delete',
      danger: true,
    });
    if (!ok) return;

    this.admin.deleteMaster(this.config.key, item.id).subscribe({
      next: () => {
        this.ui.toast(`“${item.name}” deleted`);
        this.load();
      },
      error: (err) => this.ui.error(errorMessage(err, `Could not delete this ${this.config.singular}.`)),
    });
  }
}
