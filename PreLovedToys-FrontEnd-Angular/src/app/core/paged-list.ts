import { DestroyRef, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { EMPTY, Observable, Subject, merge } from 'rxjs';
import { catchError, debounceTime, distinctUntilChanged, switchMap, tap } from 'rxjs/operators';
import { ListParams, Page } from './models';
import { errorMessage } from './utils';

export interface PagedListOptions {
  limit?: number;
  errorText?: string;
  /** Load the first page immediately (default true). */
  autoLoad?: boolean;
}

/**
 * State for a server-side paged list: page, debounced search, status filter, results.
 * Stale responses are dropped (switchMap), so fast typing or clicking never shows old data.
 * Must be created in an injection context (e.g. a component field initializer).
 */
export class PagedList<T, S = undefined> {
  readonly items = signal<T[]>([]);
  readonly total = signal(0);
  readonly counts = signal<Record<string, number>>({});
  readonly summary = signal<S | null>(null);
  readonly loading = signal(true);
  readonly error = signal('');
  readonly page = signal(1);
  /** What is typed in the search box (applied after a short pause). */
  readonly query = signal('');
  readonly status = signal('all');
  readonly limit: number;

  private appliedSearch = '';
  private readonly typed$ = new Subject<string>();
  private readonly reload$ = new Subject<void>();

  constructor(fetch: (params: ListParams) => Observable<Page<T, S>>, options: PagedListOptions = {}) {
    this.limit = options.limit ?? 20;
    const errorText = options.errorText ?? 'Could not load this list.';

    const searched$ = this.typed$.pipe(
      debounceTime(300),
      distinctUntilChanged(),
      tap((text) => {
        this.appliedSearch = text.trim();
        this.page.set(1);
      })
    );

    merge(searched$, this.reload$)
      .pipe(
        tap(() => {
          this.loading.set(true);
          this.error.set('');
        }),
        switchMap(() =>
          fetch(this.params()).pipe(
            catchError((err) => {
              this.error.set(errorMessage(err, errorText));
              this.loading.set(false);
              return EMPTY;
            })
          )
        ),
        takeUntilDestroyed(inject(DestroyRef))
      )
      .subscribe((res) => {
        this.items.set(res.items);
        this.total.set(res.total);
        this.counts.set(res.counts ?? {});
        this.summary.set(res.summary ?? null);
        this.loading.set(false);
      });

    if (options.autoLoad !== false) this.reload();
  }

  /** True when no search or filter is narrowing the list. */
  get unfiltered(): boolean {
    return !this.appliedSearch && this.status() === 'all';
  }

  setSearch(text: string): void {
    this.query.set(text);
    this.typed$.next(text);
  }

  setStatus(status: string): void {
    this.status.set(status);
    this.page.set(1);
    this.reload();
  }

  goTo(page: number): void {
    this.page.set(page);
    this.reload();
  }

  reload(): void {
    this.reload$.next();
  }

  /** Updates one loaded row in place (e.g. after changing its status). */
  updateItem(match: (item: T) => boolean, change: (item: T) => T): void {
    this.items.update((list) => list.map((item) => (match(item) ? change(item) : item)));
  }

  /** Moves one row between filter counts after a local status change. */
  moveCount(from: string, to: string): void {
    this.counts.update((c) => ({ ...c, [from]: Math.max((c[from] ?? 1) - 1, 0), [to]: (c[to] ?? 0) + 1 }));
  }

  private params(): ListParams {
    return { page: this.page(), limit: this.limit, search: this.appliedSearch, status: this.status() };
  }
}
