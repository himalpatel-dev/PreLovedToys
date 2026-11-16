import { TestBed } from '@angular/core/testing';
import { PagerComponent } from './pager';

function render(page: number, total: number, limit = 20): HTMLElement {
  const fixture = TestBed.createComponent(PagerComponent);
  fixture.componentRef.setInput('page', page);
  fixture.componentRef.setInput('limit', limit);
  fixture.componentRef.setInput('total', total);
  fixture.detectChanges();
  return fixture.nativeElement as HTMLElement;
}

const pageLabels = (el: HTMLElement) =>
  Array.from(el.querySelectorAll('.pager-num, .pager-gap')).map((n) => n.textContent!.trim());

describe('PagerComponent', () => {
  it('shows the range and hides buttons when one page is enough', () => {
    const el = render(1, 7);
    expect(el.textContent).toContain('1–7 of 7');
    expect(el.querySelector('.pager-buttons')).toBeNull();
  });

  it('shows first, last and neighbours with gaps', () => {
    const el = render(5, 201);
    expect(el.textContent).toContain('81–100 of 201');
    expect(pageLabels(el)).toEqual(['1', '…', '4', '5', '6', '…', '11']);
  });

  it('disables Previous on the first page and Next on the last', () => {
    const first = render(1, 50);
    const [prevA] = Array.from(first.querySelectorAll<HTMLButtonElement>('.btn'));
    expect(prevA.disabled).toBe(true);
    const last = render(3, 50);
    const buttons = Array.from(last.querySelectorAll<HTMLButtonElement>('.btn'));
    expect(buttons.at(-1)!.disabled).toBe(true);
    expect(last.textContent).toContain('41–50 of 50');
  });

  it('renders nothing for an empty list', () => {
    expect(render(1, 0).querySelector('.pager')).toBeNull();
  });
});
