import { ChangeDetectionStrategy, Component, computed, inject, input, OnInit, output, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { forkJoin } from 'rxjs';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { CONDITIONS, Category, MasterItem, Product, ProductUpdate } from '../../core/models';
import { errorMessage } from '../../core/utils';
import { ModalComponent } from '../../shared/modal';

interface EditForm {
  title: string;
  description: string;
  price: string;
  isPoints: boolean;
  condition: string;
  categoryId: number | null;
  subCategoryId: number | null;
  ageGroupId: number | null;
  genderId: number | null;
  colorId: number | null;
  materialId: number | null;
}

interface Masters {
  categories: Category[];
  ageGroups: MasterItem[];
  genders: MasterItem[];
  colors: MasterItem[];
  materials: MasterItem[];
}

/** Dialog for editing a listing's details (everything except photos and status). */
@Component({
  selector: 'app-product-edit',
  imports: [FormsModule, ModalComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './product-edit.html',
})
export class ProductEditComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  readonly product = input.required<Product>();
  readonly saved = output<Product>();
  readonly closed = output<void>();

  protected readonly conditions = CONDITIONS;
  protected readonly masters = signal<Masters | null>(null);
  protected readonly loadError = signal('');
  protected readonly saving = signal(false);
  protected readonly form = signal<EditForm>({
    title: '', description: '', price: '', isPoints: true, condition: 'Good',
    categoryId: null, subCategoryId: null, ageGroupId: null, genderId: null, colorId: null, materialId: null,
  });

  protected readonly subcategories = computed(() => {
    const catId = this.form().categoryId;
    return this.masters()?.categories.find((c) => c.id === catId)?.subcategories ?? [];
  });

  protected readonly priceValid = computed(() => /^\d{1,9}$/.test(this.form().price.trim()));
  protected readonly canSave = computed(() => {
    const f = this.form();
    return !this.saving() && !!this.masters() && !!f.title.trim() && !!f.description.trim() && this.priceValid() && !!f.categoryId;
  });

  ngOnInit(): void {
    const p = this.product();
    this.form.set({
      title: p.title,
      description: p.description ?? '',
      price: String(p.price ?? ''),
      isPoints: p.isPoints ?? true,
      condition: p.condition ?? 'Good',
      categoryId: p.categoryId ?? null,
      subCategoryId: p.subCategoryId ?? null,
      ageGroupId: p.ageGroupId ?? null,
      genderId: p.genderId ?? null,
      colorId: p.colorId ?? null,
      materialId: p.materialId ?? null,
    });

    forkJoin({
      categories: this.admin.getCatalogue(), // includes hidden categories, marked in the list
      ageGroups: this.admin.getMasters('age-groups'),
      genders: this.admin.getMasters('genders'),
      colors: this.admin.getMasters('colors'),
      materials: this.admin.getMasters('materials'),
    }).subscribe({
      next: (m) => this.masters.set({ ...m, categories: [...m.categories].sort((a, b) => a.name.localeCompare(b.name)) }),
      error: (err) => this.loadError.set(errorMessage(err, 'Could not load the category and option lists.')),
    });
  }

  protected patch(changes: Partial<EditForm>): void {
    this.form.update((f) => ({ ...f, ...changes }));
  }

  /** Changing the category clears a sub-category that no longer fits. */
  protected setCategory(categoryId: number | null): void {
    const subs = this.masters()?.categories.find((c) => c.id === categoryId)?.subcategories ?? [];
    this.form.update((f) => ({
      ...f,
      categoryId,
      subCategoryId: subs.some((s) => s.id === f.subCategoryId) ? f.subCategoryId : null,
    }));
  }

  protected save(): void {
    if (!this.canSave()) return;
    const f = this.form();
    const payload: ProductUpdate = {
      title: f.title.trim(),
      description: f.description.trim(),
      price: Number(f.price.trim()),
      isPoints: f.isPoints,
      condition: f.condition,
      categoryId: f.categoryId!,
      subCategoryId: f.subCategoryId,
      ageGroupId: f.ageGroupId,
      genderId: f.genderId,
      colorId: f.colorId,
      materialId: f.materialId,
    };

    this.saving.set(true);
    this.admin.updateProduct(this.product().id, payload).subscribe({
      next: (updated) => {
        this.saving.set(false);
        this.ui.toast('Listing updated');
        this.saved.emit(updated);
      },
      error: (err) => {
        this.saving.set(false);
        this.ui.error(errorMessage(err, 'Could not save the listing.'));
      },
    });
  }

  protected close(): void {
    if (!this.saving()) this.closed.emit();
  }
}
