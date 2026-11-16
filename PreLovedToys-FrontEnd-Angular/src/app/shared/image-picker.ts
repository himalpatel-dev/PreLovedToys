import { ChangeDetectionStrategy, Component, computed, input, output, signal } from '@angular/core';
import { IconComponent } from './icon';
import { imageUrl, isAppAsset } from '../core/utils';

const MAX_BYTES = 5 * 1024 * 1024; // matches the multer limit in file-upload.js

/** Picks one image and previews it. Uploading is left to the parent on save. */
@Component({
  selector: 'app-image-picker',
  imports: [IconComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="image-picker">
      <button type="button" class="image-drop" (click)="input.click()">
        @if (preview(); as src) {
          <img [src]="src" alt="Selected image" />
        } @else {
          <span class="image-drop-empty">
            <app-icon name="upload" [size]="22" />
            <span>Choose an image</span>
            <small>JPG or PNG, up to 5 MB</small>
          </span>
        }
      </button>
      @if (preview()) {
        <div class="image-picker-actions">
          <button type="button" class="btn btn-ghost btn-sm" (click)="input.click()">Replace</button>
          <button type="button" class="btn btn-ghost btn-sm" (click)="clear()">Remove</button>
        </div>
      }
      @if (appAssetName(); as name) {
        <p class="field-hint">Uses “{{ name }}”, an image built into the mobile app. Upload one here to replace it.</p>
      }
      @if (error()) {
        <p class="field-error">{{ error() }}</p>
      }
      <input #input type="file" accept="image/*" hidden (change)="onSelect($event)" />
    </div>
  `,
})
export class ImagePickerComponent {
  /** Existing image (filename or URL) shown until a new file is chosen. */
  readonly current = input<string | null | undefined>(null);
  /** Emits the chosen file, or null when the image is removed. */
  readonly fileChange = output<File | null>();

  private readonly localPreview = signal<string | null>(null);
  private readonly removed = signal(false);
  protected readonly error = signal('');

  protected readonly preview = computed(() => {
    if (this.localPreview()) return this.localPreview();
    return this.removed() ? null : imageUrl(this.current());
  });

  protected readonly appAssetName = computed(() => {
    const current = this.current();
    if (this.localPreview() || this.removed() || !isAppAsset(current)) return null;
    return current!.split('/').pop() ?? current;
  });

  protected onSelect(event: Event): void {
    const el = event.target as HTMLInputElement;
    const file = el.files?.[0];
    el.value = '';
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      this.error.set('Please choose an image file.');
      return;
    }
    if (file.size > MAX_BYTES) {
      this.error.set('Image is larger than 5 MB.');
      return;
    }
    this.error.set('');
    const reader = new FileReader();
    reader.onload = () => this.localPreview.set(reader.result as string);
    reader.readAsDataURL(file);
    this.fileChange.emit(file);
  }

  protected clear(): void {
    this.localPreview.set(null);
    this.removed.set(true);
    this.fileChange.emit(null);
  }
}
