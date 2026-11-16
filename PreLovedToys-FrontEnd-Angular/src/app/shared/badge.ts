import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { Tone } from '../core/utils';

@Component({
  selector: 'app-badge',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'badge', '[attr.data-tone]': 'tone()' },
  template: `<ng-content />`,
})
export class BadgeComponent {
  readonly tone = input<Tone>('neutral');
}
