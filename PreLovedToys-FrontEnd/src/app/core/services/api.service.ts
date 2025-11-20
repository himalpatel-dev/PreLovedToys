import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {

  // Use the URL from environment.ts
  private baseUrl = environment.apiUrl;

  constructor(private http: HttpClient) { }

  // Helper to get headers with Token
  private getHeaders() {
    const token = localStorage.getItem('token'); // We will save token here later
    let headers = new HttpHeaders();
    if (token) {
      headers = headers.set('x-access-token', token);
    }
    return headers;
  }

  // Generic GET request
  get(endpoint: string) {
    return this.http.get(`${this.baseUrl}/${endpoint}`, { headers: this.getHeaders() });
  }

  // Generic POST request
  post(endpoint: string, data: any) {
    // If data is FormData, don't set Content-Type (Browser does it automatically)
    if (data instanceof FormData) {
      // Clone headers but remove Content-Type so browser sets boundary
      let headers = this.getHeaders();
      return this.http.post(`${this.baseUrl}/${endpoint}`, data, { headers });
    }

    return this.http.post(`${this.baseUrl}/${endpoint}`, data, { headers: this.getHeaders() });
  }

  // Generic DELETE request
  delete(endpoint: string) {
    return this.http.delete(`${this.baseUrl}/${endpoint}`, { headers: this.getHeaders() });
  }
}