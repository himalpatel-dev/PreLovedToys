import { Injector, runInInjectionContext } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { vi } from 'vitest';
import { ListParams, Page } from './models';
import { PagedList } from './paged-list';

describe('PagedList', () => {
  let calls: ListParams[];
  const fetch = (p: ListParams) => {
    calls.push(p);
    const page: Page<number> = { items: [p.page], total: 95, page: p.page, limit: p.limit, counts: { all: 95 } };
    return of(page);
  };
  const make = () =>
    runInInjectionContext(TestBed.inject(Injector), () => new PagedList<number>(fetch, { limit: 20 }));

  beforeEach(() => {
    calls = [];
    TestBed.configureTestingModule({});
  });

  it('loads page 1 on creation', () => {
    const list = make();
    expect(calls).toEqual([{ page: 1, limit: 20, search: '', status: 'all' }]);
    expect(list.total()).toBe(95);
    expect(list.loading()).toBe(false);
  });

  it('changing the filter goes back to page 1', () => {
    const list = make();
    list.goTo(3);
    list.setStatus('sold');
    expect(calls.at(-1)).toEqual({ page: 1, limit: 20, search: '', status: 'sold' });
    expect(list.unfiltered).toBe(false);
  });

  it('waits for typing to pause before searching, then resets to page 1', () => {
    vi.useFakeTimers();
    try {
      const list = make();
      list.goTo(2);
      list.setSearch('b');
      list.setSearch('bu');
      list.setSearch('bus');
      expect(calls.length).toBe(2); // initial + page 2, no search yet
      vi.advanceTimersByTime(300);
      expect(calls.length).toBe(3);
      expect(calls.at(-1)).toEqual({ page: 1, limit: 20, search: 'bus', status: 'all' });
      expect(list.query()).toBe('bus');
    } finally {
      vi.useRealTimers();
    }
  });
});
