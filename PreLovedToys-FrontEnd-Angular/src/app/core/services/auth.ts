import { Injectable, inject, signal } from '@angular/core';
import { map } from 'rxjs/operators';
import { ApiService } from './api';
import { Role, SessionUser } from '../models';

const TOKEN_KEY = 'plt_admin_token';
const USER_KEY = 'plt_admin_user';

interface TokenPayload {
  id?: number;
  role?: Role;
  exp?: number;
}

/** Thrown when someone signs in with an account that is not an admin. */
export class NotAdminError extends Error {
  constructor() {
    super('This account does not have admin access.');
  }
}

export function decodeToken(token: string | null): TokenPayload | null {
  if (!token) return null;
  const part = token.split('.')[1];
  if (!part) return null;
  try {
    const base64 = part.replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64 + '='.repeat((4 - (base64.length % 4)) % 4);
    return JSON.parse(atob(padded)) as TokenPayload;
  } catch {
    return null;
  }
}

function readStoredUser(): SessionUser | null {
  try {
    const raw = localStorage.getItem(USER_KEY);
    return raw ? (JSON.parse(raw) as SessionUser) : null;
  } catch {
    return null;
  }
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly api = inject(ApiService);
  private readonly currentUser = signal<SessionUser | null>(readStoredUser());

  readonly user = this.currentUser.asReadonly();

  token(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  sendOtp(mobile: string) {
    return this.api.post<{ message: string }>('auth/send-otp', { mobile });
  }

  /** Verifies the OTP and starts a session, but only for admin accounts. */
  verifyOtp(mobile: string, otp: string) {
    return this.api
      .post<{ user: SessionUser; token: string }>('auth/verify-otp', { mobile, otp })
      .pipe(
        map((res) => {
          const role = decodeToken(res.token)?.role ?? res.user?.role;
          if (role !== 'admin') throw new NotAdminError();
          localStorage.setItem(TOKEN_KEY, res.token);
          localStorage.setItem(USER_KEY, JSON.stringify(res.user));
          this.currentUser.set(res.user);
          return res.user;
        })
      );
  }

  /**
   * Client-side check used for routing only. The role comes from the JWT the
   * backend signed, but the browser cannot verify that signature, so the real
   * protection has to be a role check on the backend admin endpoints.
   */
  isAdmin(): boolean {
    const payload = decodeToken(this.token());
    if (!payload || payload.role !== 'admin') return false;
    if (payload.exp && payload.exp * 1000 < Date.now()) return false;
    return true;
  }

  logout(): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this.currentUser.set(null);
  }
}
