import { ChangeDetectionStrategy, Component, computed, effect, input, signal } from '@angular/core';
import { IconComponent } from './icon';
import { imageUrl } from '../core/utils';

/** Square thumbnail for a stored image value; shows an icon when missing or broken. */
@Component({
  selector: 'app-thumb',
  imports: [IconComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (src() && !failed()) {
      <img class="thumb" [src]="src()" alt="" loading="lazy" (error)="failed.set(true)" />
    } @else {
      <span class="thumb thumb-empty"><app-icon name="image" [size]="16" /></span>
    }
  `,
  styles: `:host { display: inline-flex; flex-shrink: 0; }`,
})
export class ThumbComponent {
  /** A stored image value (URL, "/uploads/x.jpg", or bare filename). */
  readonly path = input<string | null | undefined>(null);
  protected readonly src = computed(() => imageUrl(this.path()));
  protected readonly failed = signal(false);

  constructor() {
    effect(() => {
      this.src();
      this.failed.set(false);
    });
  }
}
