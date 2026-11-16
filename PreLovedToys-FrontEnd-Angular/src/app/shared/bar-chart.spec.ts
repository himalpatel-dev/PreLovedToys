import { niceTicks } from './bar-chart';
import { compactNumber, orderTotal } from '../core/utils';

describe('niceTicks', () => {
  it('uses whole, evenly spaced steps that cover the max', () => {
    expect(niceTicks(0)).toEqual([0, 1]);
    expect(niceTicks(3)).toEqual([0, 1, 2, 3]);
    expect(niceTicks(9)).toEqual([0, 5, 10]);
    expect(niceTicks(1050)).toEqual([0, 500, 1000, 1500]);
    const t = niceTicks(37);
    expect(t[0]).toBe(0);
    expect(t.at(-1)!).toBeGreaterThanOrEqual(37);
    expect(t.every((v) => Number.isInteger(v))).toBe(true);
  });
});

describe('orderTotal', () => {
  it('shows points and rupees separately', () => {
    expect(orderTotal({ totalAmount: '250', pointsTotal: '60', cashTotal: '250' })).toBe('₹250 + 60 pts');
    expect(orderTotal({ totalAmount: '60', pointsTotal: '60', cashTotal: '0', isPoints: true })).toBe('60 pts');
    expect(orderTotal({ totalAmount: '250', pointsTotal: '0', cashTotal: '250' })).toBe('₹250');
  });

  it('falls back to totalAmount for older orders', () => {
    expect(orderTotal({ totalAmount: '120', pointsTotal: '0', cashTotal: '0', isPoints: true })).toBe('120 pts');
  });
});

describe('compactNumber', () => {
  it('keeps small numbers whole and shortens large ones', () => {
    expect(compactNumber(1284)).toBe('1,284');
    expect(compactNumber(12900)).toBe('12.9K');
    expect(compactNumber(4200000)).toBe('4.2M');
  });
});
