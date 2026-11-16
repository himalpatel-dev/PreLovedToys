import { HttpErrorResponse } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { Amount, OrderStatus, ProductStatus } from './models';

/** Server root without the trailing `/api`, e.g. http://localhost:4000 */
export const SERVER_URL = environment.apiUrl.replace(/\/api\/?$/, '');

/** Images bundled inside the Flutter app (e.g. "/assets/Board Games.png"); the server does not serve them. */
export function isAppAsset(path: string | null | undefined): boolean {
  return !!path && /^\/?assets\//.test(path);
}

/** Value to store after an upload. Flutter resolves images as `serverUrl + image`, so keep the leading slash. */
export function uploadedPath(filename: string): string {
  return `/uploads/${filename}`;
}

/**
 * Resolves a stored image value to a URL the browser can load:
 * full URLs as-is, "/uploads/x.jpg" against the server, bare "x.jpg" (older
 * uploads) under /uploads, and app-bundled assets to null (shown as a placeholder).
 */
export function imageUrl(path: string | null | undefined): string | null {
  if (!path || isAppAsset(path)) return null;
  if (path.startsWith('http') || path.startsWith('data:')) return path;
  if (path.startsWith('/')) return `${SERVER_URL}${path}`;
  return `${SERVER_URL}/uploads/${path}`;
}

/** Products and orders can be priced in points or rupees. */
export function formatAmount(amount: Amount | null | undefined, isPoints?: boolean): string {
  const value = Number(amount ?? 0);
  const formatted = value.toLocaleString('en-IN');
  return isPoints ? `${formatted} pts` : `₹${formatted}`;
}

/**
 * An order's total, with points and rupees shown separately ("₹250 + 60 pts").
 * Orders from before the split was recorded fall back to totalAmount + isPoints.
 */
export function orderTotal(order: {
  totalAmount: Amount;
  isPoints?: boolean;
  pointsTotal?: Amount;
  cashTotal?: Amount;
}): string {
  const points = Number(order.pointsTotal ?? 0);
  const cash = Number(order.cashTotal ?? 0);
  if (!points && !cash) return formatAmount(order.totalAmount, order.isPoints);
  if (points && cash) return `${formatAmount(cash)} + ${formatAmount(points, true)}`;
  return points ? formatAmount(points, true) : formatAmount(cash);
}

/** 1,284 / 12.9K / 4.2M (Indian grouping below 10,000). */
export function compactNumber(value: number): string {
  const abs = Math.abs(value);
  if (abs < 10000) return value.toLocaleString('en-IN');
  if (abs < 1_000_000) return `${+(value / 1000).toFixed(abs < 100000 ? 1 : 0)}K`;
  return `${+(value / 1_000_000).toFixed(1)}M`;
}

export function errorMessage(err: unknown, fallback: string): string {
  if (err instanceof HttpErrorResponse) {
    if (err.status === 0) return 'Cannot reach the server. Is the backend running?';
    const msg = (err.error as { message?: string } | null)?.message;
    if (msg) return msg;
  }
  return fallback;
}

export type Tone = 'neutral' | 'info' | 'warning' | 'success' | 'danger' | 'accent';

export function orderTone(status: OrderStatus): Tone {
  switch (status) {
    case 'placed': return 'info';
    case 'packed': return 'warning';
    case 'shipped': return 'accent';
    case 'delivered': return 'success';
    case 'cancelled': return 'danger';
    default: return 'neutral';
  }
}

export function productTone(status: ProductStatus): Tone {
  switch (status) {
    case 'active': return 'success';
    case 'pending': return 'warning';
    case 'sold': return 'info';
    case 'rejected': return 'danger';
    default: return 'neutral';
  }
}

export function initials(name: string | null | undefined): string {
  const clean = (name ?? '').trim();
  if (!clean) return '?';
  const parts = clean.split(/\s+/);
  return (parts[0][0] + (parts[1]?.[0] ?? '')).toUpperCase();
}
