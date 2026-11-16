import {
  afterNextRender,
  ChangeDetectionStrategy,
  Component,
  ElementRef,
  inject,
  signal,
  viewChild,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../../core/services/auth';
import { errorMessage } from '../../../core/utils';

@Component({
  selector: 'app-login',
  imports: [FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './login.html',
  styleUrls: ['./login.scss'],
})
export class LoginComponent {
  private readonly auth = inject(AuthService);
  private readonly router = inject(Router);

  protected readonly mobile = signal('');
  protected readonly loading = signal(false);
  protected readonly error = signal(
    inject(ActivatedRoute).snapshot.queryParamMap.has('expired')
      ? 'Your session has ended. Please sign in again.'
      : ''
  );
  private readonly input = viewChild<ElementRef<HTMLInputElement>>('mobileInput');

  constructor() {
    afterNextRender(() => this.input()?.nativeElement.focus());
  }

  protected onMobileInput(value: string): void {
    this.mobile.set(value.replace(/\D/g, '').slice(0, 10));
    this.error.set('');
  }

  protected sendOtp(): void {
    const mobile = this.mobile();
    if (mobile.length !== 10) {
      this.error.set('Enter a 10-digit mobile number.');
      return;
    }
    this.loading.set(true);
    this.error.set('');
    this.auth.sendOtp(mobile).subscribe({
      next: () => {
        this.loading.set(false);
        this.router.navigate(['/otp'], { queryParams: { mobile } });
      },
      error: (err) => {
        this.loading.set(false);
        this.error.set(errorMessage(err, 'Could not send the OTP.'));
      },
    });
  }
}
