import {
  afterNextRender,
  ChangeDetectionStrategy,
  Component,
  computed,
  DestroyRef,
  ElementRef,
  inject,
  input,
  signal,
} from '@angular/core';
import { compactNumber } from '../core/utils';

export interface BarDatum {
  key: string;
  value: number;
  /** Long label for the tooltip, e.g. "Mon, 16 Nov 2026". */
  label: string;
  /** Short axis label, e.g. "16 Nov". */
  tick: string;
}

const H = 240;
const PAD = { top: 12, right: 8, bottom: 26, left: 48 };
const MAX_BAR = 24;
const GAP = 2;
const RADIUS = 4;

/** Whole-number "nice" ticks from 0 to at least max (0, 5, 10, 15 / 0, 250, 500 ...). */
export function niceTicks(max: number, count = 4): number[] {
  const top = Math.max(max, 1);
  const raw = top / count;
  const mag = 10 ** Math.floor(Math.log10(raw));
  // Values are whole numbers, so only whole steps (1, 2, 5, 10, 25, 50 ...) are allowed.
  const steps = [1, 2, 2.5, 5, 10].map((m) => m * mag).filter((s) => s >= 1 && Number.isInteger(s));
  const wholeStep = steps.find((s) => s >= raw) ?? Math.ceil(raw);
  const ticks: number[] = [];
  for (let v = 0; v < top + wholeStep; v += wholeStep) {
    ticks.push(v);
    if (v >= top) break;
  }
  return ticks;
}

/** Column with 4px rounded top corners and a square baseline. */
function barPath(x: number, y: number, w: number, h: number): string {
  const r = Math.min(RADIUS, w / 2, h);
  return `M${x},${y + h}V${y + r}Q${x},${y} ${x + r},${y}H${x + w - r}Q${x + w},${y} ${x + w},${y + r}V${y + h}Z`;
}

/**
 * Single-series column chart (one hue, no legend: the card title names the series).
 * Hover or arrow keys show a tooltip; values are also available in the caller's table view.
 */
@Component({
  selector: 'app-bar-chart',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="chart" tabindex="0" role="group" [attr.aria-label]="name() + '. Use the left and right arrow keys to read each bar.'"
      (keydown)="onKey($event)" (pointerleave)="active.set(null)" (blur)="active.set(null)">
      @if (width() > 0) {
        <svg [attr.width]="width()" [attr.height]="height" aria-hidden="true">
          @for (t of ticks(); track t) {
            <line class="chart-grid" [attr.x1]="pad.left" [attr.x2]="width() - pad.right" [attr.y1]="y(t)" [attr.y2]="y(t)" />
            <text class="chart-tick" [attr.x]="pad.left - 8" [attr.y]="y(t)" dy="0.32em" text-anchor="end">{{ compact(t) }}</text>
          }
          @for (b of bars(); track b.key; let i = $index) {
            @if (b.h > 0) {
              <path class="chart-bar" [class.is-active]="active() === i" [attr.d]="b.d" />
            }
            <rect class="chart-hit" [attr.x]="b.slotX" [attr.y]="pad.top" [attr.width]="b.slotW" [attr.height]="plotH"
              (pointerenter)="active.set(i)" />
          }
          @for (l of xLabels(); track l.i) {
            <text class="chart-tick" [attr.x]="l.x" [attr.y]="height - 8" text-anchor="middle">{{ l.text }}</text>
          }
        </svg>
      }
      @if (tip(); as t) {
        <div class="chart-tip" [style.left.px]="t.x" [style.top.px]="t.y">
          <strong>{{ t.value }}</strong>
          <span>{{ t.label }}</span>
        </div>
      }
      <span class="sr-only" aria-live="polite">{{ tip() ? tip()!.label + ': ' + tip()!.value : '' }}</span>
    </div>
  `,
  // Block-level so its width can be measured (custom elements are inline by default).
  styles: `:host { display: block; }`,
})
export class BarChartComponent {
  readonly data = input.required<BarDatum[]>();
  /** Accessible name, e.g. "Orders per day". */
  readonly name = input.required<string>();
  /** Formats a value for the tooltip. */
  readonly format = input<(n: number) => string>((n) => n.toLocaleString('en-IN'));

  protected readonly height = H;
  protected readonly pad = PAD;
  protected readonly plotH = H - PAD.top - PAD.bottom;
  protected readonly compact = compactNumber;
  protected readonly width = signal(0);
  protected readonly active = signal<number | null>(null);

  protected readonly ticks = computed(() => niceTicks(Math.max(0, ...this.data().map((d) => d.value))));
  private readonly top = computed(() => this.ticks().at(-1) || 1);

  protected y(value: number): number {
    return PAD.top + this.plotH - (value / this.top()) * this.plotH;
  }

  protected readonly bars = computed(() => {
    const data = this.data();
    const plotW = Math.max(this.width() - PAD.left - PAD.right, 1);
    const slot = plotW / Math.max(data.length, 1);
    const w = Math.max(1, Math.min(MAX_BAR, slot - GAP));
    const base = PAD.top + this.plotH;
    return data.map((d, i) => {
      const slotX = PAD.left + i * slot;
      const x = slotX + (slot - w) / 2;
      const yTop = this.y(Math.max(d.value, 0));
      const h = base - yTop;
      return { key: d.key, slotX, slotW: slot, cx: x + w / 2, top: yTop, h, d: barPath(x, yTop, w, h) };
    });
  });

  /** About six evenly spaced axis labels, always including the latest bar. */
  protected readonly xLabels = computed(() => {
    const data = this.data();
    const bars = this.bars();
    const every = Math.max(1, Math.ceil(data.length / 6));
    const last = data.length - 1;
    return data
      .map((d, i) => ({ i, x: bars[i]?.cx ?? 0, text: d.tick }))
      .filter((l) => (last - l.i) % every === 0);
  });

  protected readonly tip = computed(() => {
    const i = this.active();
    if (i === null) return null;
    const d = this.data()[i];
    const b = this.bars()[i];
    if (!d || !b) return null;
    const x = Math.min(Math.max(b.cx, 70), this.width() - 70);
    // Sits above the bar, but never above the chart itself (it would cover the card header).
    const y = Math.min(Math.max(b.top, 60), PAD.top + this.plotH - 4);
    return { x, y, value: this.format()(d.value), label: d.label };
  });

  constructor() {
    const host = inject(ElementRef<HTMLElement>).nativeElement as HTMLElement;
    let observer: ResizeObserver | undefined;
    afterNextRender(() => {
      this.width.set(Math.floor(host.getBoundingClientRect().width));
      observer = new ResizeObserver(([entry]) => this.width.set(Math.floor(entry.contentRect.width)));
      observer.observe(host);
    });
    inject(DestroyRef).onDestroy(() => observer?.disconnect());
  }

  protected onKey(event: KeyboardEvent): void {
    const n = this.data().length;
    if (!n) return;
    const cur = this.active();
    let next: number | null = null;
    if (event.key === 'ArrowRight') next = cur === null ? n - 1 : Math.min(cur + 1, n - 1);
    else if (event.key === 'ArrowLeft') next = cur === null ? n - 1 : Math.max(cur - 1, 0);
    else if (event.key === 'Home') next = 0;
    else if (event.key === 'End') next = n - 1;
    else if (event.key === 'Escape') next = null;
    else return;
    event.preventDefault();
    this.active.set(next);
  }
}
