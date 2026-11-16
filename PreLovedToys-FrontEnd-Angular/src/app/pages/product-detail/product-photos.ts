import { ChangeDetectionStrategy, Component, computed, inject, input, output, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { Product, ProductImage } from '../../core/models';
import { errorMessage, imageUrl } from '../../core/utils';
import { IconComponent } from '../../shared/icon';

const MAX_PHOTOS = 10; // matches the backend limit
const MAX_BYTES = 5 * 1024 * 1024; // matches the upload limit

/** Add, remove and reorder a listing's photos. The first photo is the cover buyers see. */
@Component({
  selector: 'app-product-photos',
  imports: [IconComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <section class="card card-pad">
      <header class="photos-header">
        <div>
          <h2 class="card-title">Photos</h2>
          <p class="muted small">The first photo is the cover buyers see. {{ photos().length }} of {{ max }}.</p>
        </div>
        <button type="button" class="btn btn-ghost btn-sm" (click)="file.click()" [disabled]="busy() || photos().length >= max">
          <app-icon name="upload" [size]="14" /> Add photo
        </button>
        <input #file type="file" accept="image/*" hidden (change)="onFile($event)" />
      </header>

      @if (photos().length) {
        <ol class="photo-grid" [class.is-busy]="busy()">
          @for (p of photos(); track p.id; let i = $index; let first = $first; let last = $last) {
            <li class="photo">
              @if (broken().has(p.id)) {
                <span class="photo-missing"><app-icon name="image" [size]="20" /> Can't be loaded</span>
              } @else {
                <img [src]="src(p)" [alt]="'Photo ' + (i + 1)" loading="lazy" (error)="markBroken(p.id)" />
              }
              @if (first) {
                <span class="photo-cover">Cover</span>
              }
              <div class="photo-actions">
                <button type="button" class="icon-btn" (click)="move(i, -1)" [disabled]="busy() || first"
                  [attr.aria-label]="'Move photo ' + (i + 1) + ' earlier'" title="Move earlier">
                  <app-icon name="back" [size]="14" />
                </button>
                @if (!first) {
                  <button type="button" class="btn btn-ghost btn-xs" (click)="makeCover(i)" [disabled]="busy()">Make cover</button>
                }
                <button type="button" class="icon-btn icon-btn-danger" (click)="remove(p, i)" [disabled]="busy()"
                  [attr.aria-label]="'Remove photo ' + (i + 1)" title="Remove">
                  <app-icon name="trash" [size]="14" />
                </button>
                <button type="button" class="icon-btn" (click)="move(i, 1)" [disabled]="busy() || last"
                  [attr.aria-label]="'Move photo ' + (i + 1) + ' later'" title="Move later">
                  <app-icon name="chevron" [size]="14" />
                </button>
              </div>
            </li>
          }
        </ol>
      } @else {
        <p class="muted">No photos yet.</p>
      }
    </section>
  `,
})
export class ProductPhotosComponent {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  readonly product = input.required<Product>();
  /** Emits the listing as saved by the server after every change. */
  readonly changed = output<Product>();

  protected readonly max = MAX_PHOTOS;
  protected readonly busy = signal(false);
  /** Photos whose file failed to load, so admins can spot and remove them. */
  protected readonly broken = signal<Set<number>>(new Set());

  protected markBroken(id: number): void {
    this.broken.update((s) => new Set(s).add(id));
  }
  protected readonly photos = computed(() => (this.product().images ?? []).filter((p): p is ProductImage & { id: number } => !!p.id));

  protected src(p: ProductImage): string {
    return imageUrl(p.imageUrl) ?? '';
  }

  protected async onFile(event: Event): Promise<void> {
    const el = event.target as HTMLInputElement;
    const file = el.files?.[0];
    el.value = '';
    if (!file) return;
    if (!file.type.startsWith('image/')) return this.ui.error('Please choose an image file.');
    if (file.size > MAX_BYTES) return this.ui.error('Image is larger than 5 MB.');

    await this.run('Photo added', async () => {
      const { filename } = await firstValueFrom(this.admin.uploadImage(file));
      return firstValueFrom(this.admin.addProductImage(this.product().id, filename));
    });
  }

  protected move(index: number, step: -1 | 1): Promise<void> {
    const ids = this.photos().map((p) => p.id);
    const target = index + step;
    if (target < 0 || target >= ids.length) return Promise.resolve();
    [ids[index], ids[target]] = [ids[target], ids[index]];
    return this.reorder(ids, target === 0 ? 'Cover photo changed' : 'Photo order saved');
  }

  protected makeCover(index: number): Promise<void> {
    const ids = this.photos().map((p) => p.id);
    const [picked] = ids.splice(index, 1);
    return this.reorder([picked, ...ids], 'Cover photo changed');
  }

  protected async remove(photo: ProductImage & { id: number }, index: number): Promise<void> {
    if (this.photos().length <= 1) {
      this.ui.error('A listing needs at least one photo. Add another photo before removing this one.');
      return;
    }
    const ok = await this.ui.confirm({
      title: `Remove photo ${index + 1}?`,
      message: index === 0 ? 'The next photo becomes the cover.' : undefined,
      confirmText: 'Remove photo',
      danger: true,
    });
    if (!ok) return;
    await this.run('Photo removed', () => firstValueFrom(this.admin.removeProductImage(this.product().id, photo.id)));
  }

  private reorder(ids: number[], message: string): Promise<void> {
    return this.run(message, () => firstValueFrom(this.admin.reorderProductImages(this.product().id, ids)));
  }

  private async run(message: string, action: () => Promise<Product>): Promise<void> {
    if (this.busy()) return;
    this.busy.set(true);
    try {
      const updated = await action();
      this.changed.emit(updated);
      this.ui.toast(message);
    } catch (err) {
      this.ui.error(errorMessage(err, 'Could not update the photos.'));
    } finally {
      this.busy.set(false);
    }
  }
}
