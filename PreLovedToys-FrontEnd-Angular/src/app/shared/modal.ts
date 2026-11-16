import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { IconComponent } from './icon';

/**
 * Dialog shell. Body content is projected; put buttons in an element with the
 * `modal-footer` attribute to place them in the footer.
 */
@Component({
  selector: 'app-modal',
  imports: [IconComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { '(document:keydown.escape)': 'closed.emit()' },
  template: `
    <div class="overlay" (click)="closed.emit()"></div>
    <div class="dialog" [class.dialog-wide]="wide()" role="dialog" aria-modal="true" [attr.aria-label]="title()">
      <header class="dialog-header">
        <h2>{{ title() }}</h2>
        <button type="button" class="icon-btn" (click)="closed.emit()" aria-label="Close">
          <app-icon name="close" />
        </button>
      </header>
      <div class="dialog-body"><ng-content /></div>
      <footer class="dialog-footer"><ng-content select="[modal-footer]" /></footer>
    </div>
  `,
})
export class ModalComponent {
  readonly title = input.required<string>();
  readonly wide = input(false);
  readonly closed = output<void>();
}
