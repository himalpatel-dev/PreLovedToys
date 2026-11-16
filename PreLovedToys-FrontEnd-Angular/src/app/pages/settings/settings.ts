import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AdminService } from '../../core/services/admin';
import { UiService } from '../../core/services/ui';
import { PointsSettings } from '../../core/models';
import { errorMessage, formatAmount } from '../../core/utils';

/** Profile fields that earn points, in the order the app's profile screen shows them. */
const PROFILE_FIELDS: { key: string; label: string }[] = [
  { key: 'name', label: 'Name' },
  { key: 'email', label: 'Email' },
  { key: 'gender', label: 'Gender' },
  { key: 'occupation', label: 'Occupation' },
  { key: 'collegeOrUniversity', label: 'College / university' },
  { key: 'purpose', label: 'Why they are here' },
  { key: 'aboutMe', label: 'About me' },
  { key: 'interestedIn', label: 'Interests' },
];

interface FormState {
  welcomeBonus: string;
  cashUnlockSales: string;
  profilePoints: Record<string, string>;
}

const toForm = (s: PointsSettings): FormState => ({
  welcomeBonus: String(s.welcomeBonus),
  cashUnlockSales: String(s.cashUnlockSales),
  profilePoints: Object.fromEntries(PROFILE_FIELDS.map((f) => [f.key, String(s.profilePoints[f.key] ?? 0)])),
});

const whole = (v: string, max: number) => /^\d+$/.test(v.trim()) && Number(v) <= max;

/** Points rules that used to be hard-coded in the backend. */
@Component({
  selector: 'app-settings',
  imports: [FormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './settings.html',
})
export class SettingsPage {
  private readonly admin = inject(AdminService);
  private readonly ui = inject(UiService);

  protected readonly fields = PROFILE_FIELDS;
  protected readonly saved = signal<PointsSettings | null>(null);
  protected readonly form = signal<FormState | null>(null);
  protected readonly loading = signal(true);
  protected readonly saving = signal(false);
  protected readonly error = signal('');
  protected readonly formatAmount = formatAmount;

  protected readonly valid = computed(() => {
    const f = this.form();
    return !!f && whole(f.welcomeBonus, 100000) && whole(f.cashUnlockSales, 100)
      && PROFILE_FIELDS.every((p) => whole(f.profilePoints[p.key], 10000));
  });

  protected readonly profileTotal = computed(() => {
    const f = this.form();
    return f ? PROFILE_FIELDS.reduce((sum, p) => sum + (Number(f.profilePoints[p.key]) || 0), 0) : 0;
  });

  protected readonly dirty = computed(() => {
    const f = this.form();
    const s = this.saved();
    return !!f && !!s && JSON.stringify(f) !== JSON.stringify(toForm(s));
  });

  constructor() {
    this.load();
  }

  protected load(): void {
    this.loading.set(true);
    this.error.set('');
    this.admin.getSettings().subscribe({
      next: (s) => {
        this.saved.set(s);
        this.form.set(toForm(s));
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(errorMessage(err, 'Could not load settings.'));
        this.loading.set(false);
      },
    });
  }

  protected setTop(key: 'welcomeBonus' | 'cashUnlockSales', value: string): void {
    this.form.update((f) => (f ? { ...f, [key]: value } : f));
  }

  protected setField(key: string, value: string): void {
    this.form.update((f) => (f ? { ...f, profilePoints: { ...f.profilePoints, [key]: value } } : f));
  }

  protected isValid(value: string, max: number): boolean {
    return whole(value, max);
  }

  protected reset(): void {
    const s = this.saved();
    if (s) this.form.set(toForm(s));
  }

  protected save(): void {
    const f = this.form();
    if (!f || !this.valid() || this.saving()) return;
    this.saving.set(true);
    this.admin
      .updateSettings({
        welcomeBonus: Number(f.welcomeBonus),
        cashUnlockSales: Number(f.cashUnlockSales),
        profilePoints: Object.fromEntries(PROFILE_FIELDS.map((p) => [p.key, Number(f.profilePoints[p.key])])),
      })
      .subscribe({
        next: (s) => {
          this.saved.set(s);
          this.form.set(toForm(s));
          this.saving.set(false);
          this.ui.toast('Points rules saved. They apply from now on.');
        },
        error: (err) => {
          this.saving.set(false);
          this.ui.error(errorMessage(err, 'Could not save the settings.'));
        },
      });
  }
}
