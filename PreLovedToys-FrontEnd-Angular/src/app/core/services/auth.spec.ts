import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { AuthService, NotAdminError, decodeToken } from './auth';
import { environment } from '../../../environments/environment';

/** Builds an unsigned JWT-shaped string; only the payload matters client-side. */
function fakeToken(payload: object): string {
  const encode = (o: object) => btoa(JSON.stringify(o)).replace(/=+$/, '');
  return `${encode({ alg: 'HS256' })}.${encode(payload)}.sig`;
}

describe('AuthService', () => {
  let auth: AuthService;
  let http: HttpTestingController;

  beforeEach(() => {
    localStorage.clear();
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    auth = TestBed.inject(AuthService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('decodes the role from a token', () => {
    expect(decodeToken(fakeToken({ id: 1, role: 'admin' }))?.role).toBe('admin');
    expect(decodeToken('not-a-token')).toBeNull();
  });

  it('starts a session for an admin', () => {
    const token = fakeToken({ id: 1, role: 'admin', exp: Date.now() / 1000 + 60 });
    let signedIn = false;
    auth.verifyOtp('9999999999', '1111').subscribe(() => (signedIn = true));
    http
      .expectOne(`${environment.apiUrl}/auth/verify-otp`)
      .flush({ token, user: { id: 1, mobile: '9999999999', role: 'admin' } });

    expect(signedIn).toBe(true);
    expect(auth.isAdmin()).toBe(true);
    expect(auth.user()?.mobile).toBe('9999999999');
  });

  it('refuses a non-admin account and stores nothing', () => {
    const token = fakeToken({ id: 2, role: 'user' });
    let error: unknown;
    auth.verifyOtp('8888888888', '1111').subscribe({ error: (e) => (error = e) });
    http
      .expectOne(`${environment.apiUrl}/auth/verify-otp`)
      .flush({ token, user: { id: 2, mobile: '8888888888', role: 'user' } });

    expect(error).toBeInstanceOf(NotAdminError);
    expect(auth.token()).toBeNull();
    expect(auth.isAdmin()).toBe(false);
  });

  it('treats an expired admin token as signed out', () => {
    localStorage.setItem('plt_admin_token', fakeToken({ role: 'admin', exp: Date.now() / 1000 - 10 }));
    expect(auth.isAdmin()).toBe(false);
  });
});
