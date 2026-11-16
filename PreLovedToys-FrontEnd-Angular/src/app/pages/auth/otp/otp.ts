import {
  afterNextRender,
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  ElementRef,
  inject,
  signal,
  viewChildren,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService, NotAdminError } from '../../../core/services/auth';
import { UiService } from '../../../core/services/ui';
import { errorMessage } from '../../../core/utils';

const LENGTH = 4;

@Component({
  selector: 'app-otp',
  imports: [FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './otp.html',
  styleUrls: ['./otp.scss'],
})
export class OtpComponent {
  private readonly auth = inject(AuthService);
  private readonly ui = inject(UiService);
  private readonly router = inject(Router);

  private readonly inputs = viewChildren<ElementRef<HTMLInputElement>>('box');
  private timer?: ReturnType<typeof setInterval>;

  protected readonly mobile: string = inject(ActivatedRoute).snapshot.queryParamMap.get('mobile') ?? '';
  protected readonly digits = signal<string[]>(Array(LENGTH).fill(''));
  protected readonly loading = signal(false);
  protected readonly error = signal('');
  protected readonly seconds = signal(60);

  constructor() {
    if (!/^\d{10}$/.test(this.mobile)) {
      this.router.navigate(['/login']);
      return;
    }
    this.startTimer();
    inject(DestroyRef).onDestroy(() => clearInterval(this.timer));
    afterNextRender(() => this.focus(0));
  }

  protected get otp(): string {
    return this.digits().join('');
  }

  protected onInput(event: Event, index: number): void {
    const el = event.target as HTMLInputElement;
    const typed = el.value.replace(/\D/g, '');

    if (typed.length >= LENGTH) {
      // A pasted code fills every box at once.
      const chars = typed.slice(0, LENGTH).split('');
      this.digits.set(chars);
      this.focus(LENGTH - 1);
    } else {
      // Typing into a filled box replaces its digit with the new one.
      const digit = typed.slice(-1);
      this.digits.update((d) => d.map((v, i) => (i === index ? digit : v)));
      el.value = digit;
      if (digit && index < LENGTH - 1) this.focus(index + 1);
    }

    this.error.set('');
    if (this.otp.length === LENGTH) this.verify();
  }

  protected onKeydown(event: KeyboardEvent, index: number): void {
    if (event.key === 'Backspace' && !this.digits()[index] && index > 0) this.focus(index - 1);
    else if (event.key === 'ArrowLeft' && index > 0) this.focus(index - 1);
    else if (event.key === 'ArrowRight' && index < LENGTH - 1) this.focus(index + 1);
  }

  protected verify(): void {
    if (this.loading()) return;
    if (this.otp.length < LENGTH) {
      this.error.set('Enter the 4-digit code.');
      return;
    }
    this.loading.set(true);
    this.auth.verifyOtp(this.mobile, this.otp).subscribe({
      next: (user) => {
        this.loading.set(false);
        this.ui.toast(`Welcome back${user.name ? ', ' + user.name : ''}`);
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        this.loading.set(false);
        if (err instanceof NotAdminError) {
          this.ui.error(err.message);
          this.router.navigate(['/login']);
          return;
        }
        this.error.set(errorMessage(err, 'Invalid OTP.'));
        this.digits.set(Array(LENGTH).fill(''));
        this.focus(0);
      },
    });
  }

  protected resend(): void {
    this.loading.set(true);
    this.auth.sendOtp(this.mobile).subscribe({
      next: () => {
        this.loading.set(false);
        this.error.set('');
        this.digits.set(Array(LENGTH).fill(''));
        this.ui.toast('A new OTP has been sent');
        this.startTimer();
        this.focus(0);
      },
      error: (err) => {
        this.loading.set(false);
        this.error.set(errorMessage(err, 'Could not resend the OTP.'));
      },
    });
  }

  protected changeMobile(): void {
    this.router.navigate(['/login']);
  }

  private focus(index: number): void {
    setTimeout(() => this.inputs()[index]?.nativeElement.focus());
  }

  private startTimer(): void {
    clearInterval(this.timer);
    this.seconds.set(60);
    this.timer = setInterval(() => {
      this.seconds.update((s) => Math.max(s - 1, 0));
      if (this.seconds() === 0) clearInterval(this.timer);
    }, 1000);
  }
}
