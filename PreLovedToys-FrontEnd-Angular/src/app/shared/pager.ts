import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';

/** "21–40 of 201" plus Previous / page numbers / Next. Hidden when everything fits on one page. */
@Component({
  selector: 'app-pager',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (total() > 0) {
      <nav class="pager" aria-label="Pages">
        <span class="muted">{{ from() }}–{{ to() }} of {{ total().toLocaleString('en-IN') }}</span>
        @if (lastPage() > 1) {
          <div class="pager-buttons">
            <button type="button" class="btn btn-ghost btn-sm" [disabled]="page() <= 1" (click)="go(page() - 1)">
              Previous
            </button>
            @for (p of pages(); track $index) {
              @if (p === 0) {
                <span class="pager-gap" aria-hidden="true">…</span>
              } @else {
                <button type="button" class="pager-num" [class.active]="p === page()"
                  [attr.aria-current]="p === page() ? 'page' : null" (click)="go(p)">{{ p }}</button>
              }
            }
            <button type="button" class="btn btn-ghost btn-sm" [disabled]="page() >= lastPage()" (click)="go(page() + 1)">
              Next
            </button>
          </div>
        }
      </nav>
    }
  `,
})
export class PagerComponent {
  readonly page = input.required<number>();
  readonly limit = input.required<number>();
  readonly total = input.required<number>();
  readonly pageChange = output<number>();

  protected readonly lastPage = computed(() => Math.max(1, Math.ceil(this.total() / this.limit())));
  protected readonly from = computed(() => (this.page() - 1) * this.limit() + 1);
  protected readonly to = computed(() => Math.min(this.page() * this.limit(), this.total()));

  /** First, last, and the pages around the current one; 0 marks a gap. */
  protected readonly pages = computed(() => {
    const last = this.lastPage();
    const cur = this.page();
    const wanted = new Set([1, last, cur - 1, cur, cur + 1].filter((p) => p >= 1 && p <= last));
    const sorted = [...wanted].sort((a, b) => a - b);
    const out: number[] = [];
    sorted.forEach((p, i) => {
      if (i > 0 && p - sorted[i - 1] > 1) out.push(0);
      out.push(p);
    });
    return out;
  });

  protected go(page: number): void {
    if (page < 1 || page > this.lastPage() || page === this.page()) return;
    this.pageChange.emit(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }
}
