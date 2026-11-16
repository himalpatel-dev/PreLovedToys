import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { Category, SubCategory } from '../../core/models';
import { errorMessage, uploadedPath } from '../../core/utils';
import { IconComponent } from '../../shared/icon';
import { ModalComponent } from '../../shared/modal';
import { ImagePickerComponent } from '../../shared/image-picker';
import { ThumbComponent } from '../../shared/thumb';
import { BadgeComponent } from '../../shared/badge';

interface SubCategoryForm {
  id: number | null;
  name: string;
  categoryId: number | null;
  image: string | null;
}

@Component({
  selector: 'app-subcategories',
  imports: [FormsModule, IconComponent, ModalComponent, ImagePickerComponent, ThumbComponent, BadgeComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './subcategories.html',
})
export class SubCategoriesPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  protected readonly subCategories = signal<SubCategory[]>([]);
  protected readonly categories = signal<Category[]>([]);
  protected readonly loading = signal(true);
  protected readonly error = signal('');
  protected readonly query = signal('');
  protected readonly parentFilter = signal<number | null>(null);
  protected readonly form = signal<SubCategoryForm | null>(null);
  protected readonly saving = signal(false);
  private file: File | null | undefined;

  protected readonly filtered = computed(() => {
    const q = this.query().trim().toLowerCase();
    const parent = this.parentFilter();
    return this.subCategories().filter(
      (s) => (parent === null || s.categoryId === parent) && (!q || s.name.toLowerCase().includes(q))
    );
  });

  constructor() {
    this.load();
  }

  protected load(): void {
    this.loading.set(true);
    this.error.set('');
    // One call: every category (hidden ones too) with its sub-categories and listing counts.
    this.admin.getCatalogue().subscribe({
      next: (cats) => {
        this.categories.set(cats);
        this.subCategories.set(
          cats
            .flatMap((c) =>
              (c.subcategories ?? []).map((s) => ({ ...s, category: { id: c.id, name: c.name, isActive: c.isActive } }))
            )
            .sort((a, b) => a.name.localeCompare(b.name))
        );
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, 'Could not load sub-categories.'));
        this.loading.set(false);
      },
    });
  }

  protected setParentFilter(value: string): void {
    this.parentFilter.set(value ? Number(value) : null);
  }

  protected open(s?: SubCategory): void {
    this.file = undefined;
    this.form.set(
      s
        ? { id: s.id, name: s.name, categoryId: s.categoryId, image: s.image ?? null }
        : { id: null, name: '', categoryId: this.parentFilter(), image: null }
    );
  }

  protected close(): void {
    if (!this.saving()) this.form.set(null);
  }

  protected onFile(file: File | null): void {
    this.file = file;
  }

  protected patch(changes: Partial<SubCategoryForm>): void {
    this.form.update((f) => (f ? { ...f, ...changes } : f));
  }

  protected async save(): Promise<void> {
    const f = this.form();
    if (!f) return;
    const name = f.name.trim();
    if (!name || !f.categoryId) {
      this.ui.error('Name and parent category are required.');
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
      const payload = { name, categoryId: f.categoryId, image };
      if (f.id) {
        await firstValueFrom(this.admin.updateSubCategory(f.id, payload));
      } else {
        await firstValueFrom(this.admin.createSubCategory(payload));
      }
      this.ui.toast(f.id ? `“${name}” updated` : `“${name}” created`);
      this.saving.set(false);
      this.form.set(null);
      this.load();
    } catch (err) {
      this.saving.set(false);
      this.ui.error(errorMessage(err, 'Could not save the sub-category.'));
    }
  }

  /** Hidden sub-categories (and their listings) disappear from the app but keep their data. */
  protected async setVisible(s: SubCategory, visible: boolean, skipConfirm = false): Promise<void> {
    if (!visible && !skipConfirm) {
      const n = s.productCount ?? 0;
      const ok = await this.ui.confirm({
        title: `Hide “${s.name}” from the app?`,
        message: `Buyers won't see it or its ${n} listing${n === 1 ? '' : 's'}. Nothing is deleted; you can show it again any time.`,
        confirmText: 'Hide sub-category',
      });
      if (!ok) return;
    }
    this.admin.setSubCategoryVisible(s.id, visible).subscribe({
      next: () => {
        this.subCategories.update((list) => list.map((x) => (x.id === s.id ? { ...x, isActive: visible } : x)));
        this.ui.toast(visible ? `“${s.name}” is visible in the app again` : `“${s.name}” is hidden from the app`);
      },
      error: (err) => this.ui.error(errorMessage(err, 'Could not change visibility.')),
    });
  }

  protected async remove(s: SubCategory): Promise<void> {
    const listings = s.productCount ?? 0;
    if (listings) {
      const uses = `${listings} listing${listings === 1 ? '' : 's'}`;
      if (s.isActive === false) {
        this.ui.error(`“${s.name}” can't be deleted while ${uses} use it. It is already hidden from the app.`);
        return;
      }
      const hide = await this.ui.confirm({
        title: `“${s.name}” can't be deleted`,
        message: `It is still used by ${uses}. You can hide it from the app instead; nothing is lost.`,
        confirmText: 'Hide instead',
      });
      if (hide) await this.setVisible(s, false, true);
      return;
    }

    const ok = await this.ui.confirm({
      title: `Delete “${s.name}”?`,
      message: 'It has no listings. This can’t be undone.',
      confirmText: 'Delete',
      danger: true,
    });
    if (!ok) return;

    this.admin.deleteSubCategory(s.id).subscribe({
      next: () => {
        this.ui.toast(`“${s.name}” deleted`);
        this.load();
      },
      error: (err) => this.ui.error(errorMessage(err, 'Could not delete the sub-category.')),
    });
  }
}
