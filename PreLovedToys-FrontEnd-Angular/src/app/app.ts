import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { UiService } from './core/services/ui';
import { IconComponent } from './shared/icon';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, IconComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './app.html',
  host: { '(document:keydown.escape)': 'ui.closeConfirm(false)' },
})
export class App {
  protected readonly ui = inject(UiService);
}
