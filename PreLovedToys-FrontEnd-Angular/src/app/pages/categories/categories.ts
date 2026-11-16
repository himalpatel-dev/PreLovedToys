import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { Category } from '../../core/models';
import { errorMessage, uploadedPath } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { ModalComponent } from '../../shared/modal';
import { ImagePickerComponent } from '../../shared/image-picker';
import { ThumbComponent } from '../../shared/thumb';
import { BadgeComponent } from '../../shared/badge';

interface CategoryForm {
  id: number | null;
  name: string;
  image: string | null;
}

@Component({
  selector: 'app-categories',
  imports: [FormsModule, IconComponent, ModalComponent, ImagePickerComponent, ThumbComponent, BadgeComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './categories.html',
})
export class CategoriesPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  protected readonly categories = signal<Category[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal('');
  protected readonly query = signal('');
  protected readonly form = signal<CategoryForm | null>(null);
  protected readonly saving = signal(false);
  private file: File | null | undefined;

  protected readonly filtered = computed(() => {
    const q = this.query().trim().toLowerCase();
    return q ? this.categories().filter((c) => c.name.toLowerCase().includes(q)) : this.categories();
  });

  constructor() {
    this.load();
  }

  protected load(): void {
    this.loading.set(true);
    this.error.set('');
    this.admin.getCatalogue().subscribe({
      next: (res) => {
        this.categories.set(res);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, 'Could not load categories.'));
        this.loading.set(false);
      },
    });
  }

  protected open(c?: Category): void {
    this.file = undefined;
    this.form.set(c ? { id: c.id, name: c.name, image: c.image ?? null } : { id: null, name: '', image: null });
  }

  protected close(): void {
    if (!this.saving()) this.form.set(null);
  }

  /** undefined = keep current image, null = remove it, File = upload a new one */
  protected onFile(file: File | null): void {
    this.file = file;
  }

  protected updateName(name: string): void {
    this.form.update((f) => (f ? { ...f, name } : f));
  }

  protected async save(): Promise<void> {
    const f = this.form();
    if (!f) return;
    const name = f.name.trim();
    if (!name) {
      this.ui.error('Category name is required.');
      return;
    }

    this.saving.set(true);
    try {
      let image = f.image;
      if (this.file) {
        image = uploadedPath((await firstValueFrom(this.admin.uploadImage(this.file))).filename);
      } else if (this.file === null) {
        image = null;
      }
      const payload = { name, image };
      if (f.id) {
        await firstValueFrom(this.admin.updateCategory(f.id, payload));
      } else {
        await firstValueFrom(this.admin.createCategory(payload));
      }
      this.ui.toast(f.id ? `“${name}” updated` : `“${name}” created`);
      this.saving.set(false);
      this.form.set(null);
      this.load();
    } catch (err) {
      this.saving.set(false);
      this.ui.error(errorMessage(err, 'Could not save the category.'));
    }
  }

  /** Hidden categories (and their listings) disappear from the app but keep all their data. */
  protected async setVisible(c: Category, visible: boolean, skipConfirm = false): Promise<void> {
    if (!visible && !skipConfirm) {
      const ok = await this.ui.confirm({
        title: `Hide “${c.name}” from the app?`,
        message: `Buyers won't see it, its sub-categories or its ${c.productCount ?? 0} listing${c.productCount === 1 ? '' : 's'}. Nothing is deleted; you can show it again any time.`,
        confirmText: 'Hide category',
      });
      if (!ok) return;
    }
    this.admin.setCategoryVisible(c.id, visible).subscribe({
      next: () => {
        this.categories.update((list) => list.map((x) => (x.id === c.id ? { ...x, isActive: visible } : x)));
        this.ui.toast(visible ? `“${c.name}” is visible in the app again` : `“${c.name}” is hidden from the app`);
      },
      error: (err) => this.ui.error(errorMessage(err, 'Could not change visibility.')),
    });
  }

  protected async remove(c: Category): Promise<void> {
    const subs = c.subcategories?.length ?? 0;
    const listings = c.productCount ?? 0;
    if (subs || listings) {
      const uses = [
        subs ? `${subs} sub-categor${subs === 1 ? 'y' : 'ies'}` : '',
        listings ? `${listings} listing${listings === 1 ? '' : 's'}` : '',
      ].filter(Boolean).join(' and ');
      if (c.isActive === false) {
        this.ui.error(`“${c.name}” can't be deleted while ${uses} use it. It is already hidden from the app.`);
        return;
      }
      const hide = await this.ui.confirm({
        title: `“${c.name}” can't be deleted`,
        message: `It is still used by ${uses}. You can hide it from the app instead; nothing is lost.`,
        confirmText: 'Hide instead',
      });
      if (hide) await this.setVisible(c, false, true);
      return;
    }

    const ok = await this.ui.confirm({
      title: `Delete “${c.name}”?`,
      message: 'It has no sub-categories or listings. This can’t be undone.',
      confirmText: 'Delete',
      danger: true,
    });
    if (!ok) return;

    this.admin.deleteCategory(c.id).subscribe({
      next: () => {
        this.ui.toast(`“${c.name}” deleted`);
        this.load();
      },
      error: (err) => this.ui.error(errorMessage(err, 'Could not delete the category.')),
    });
  }
}
