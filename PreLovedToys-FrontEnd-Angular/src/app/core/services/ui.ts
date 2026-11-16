import { Injectable, signal } from '@angular/core';

export type ToastKind = 'success' | 'error' | 'info';

export interface Toast {
  id: number;
  message: string;
  kind: ToastKind;
}

export interface ConfirmOptions {
  title: string;
  message?: string;
  confirmText?: string;
  danger?: boolean;
}

interface ConfirmState extends ConfirmOptions {
  resolve: (ok: boolean) => void;
}

/** Toasts and confirm dialogs, rendered once in the app shell. */
@Injectable({ providedIn: 'root' })
export class UiService {
  private nextId = 1;
  readonly toasts = signal<Toast[]>([]);
  readonly confirmState = signal<ConfirmState | null>(null);

  toast(message: string, kind: ToastKind = 'success'): void {
    const id = this.nextId++;
    this.toasts.update((list) => [...list, { id, message, kind }]);
    setTimeout(() => this.dismiss(id), kind === 'error' ? 5000 : 3000);
  }

  error(message: string): void {
    this.toast(message, 'error');
  }

  dismiss(id: number): void {
    this.toasts.update((list) => list.filter((t) => t.id !== id));
  }

  confirm(options: ConfirmOptions): Promise<boolean> {
    this.confirmState()?.resolve(false);
    return new Promise((resolve) => this.confirmState.set({ ...options, resolve }));
  }

  closeConfirm(ok: boolean): void {
    const state = this.confirmState();
    if (!state) return;
    this.confirmState.set(null);
    state.resolve(ok);
  }
}
