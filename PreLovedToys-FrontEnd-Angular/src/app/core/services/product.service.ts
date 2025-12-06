import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from './api';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

@Injectable({
    providedIn: 'root'
})
export class ProductService {

    constructor(
        private api: ApiService,
        private http: HttpClient
    ) { }

    getAllProducts(): Observable<any> {
        return this.api.get('products');
    }

    getProductById(id: number): Observable<any> {
        return this.api.get(`products/${id}`);
    }

    getProductsByCategory(categoryId: number): Observable<any> {
        return this.api.get(`products/category/${categoryId}`);
    }

    uploadImage(file: File): Observable<any> {
        const formData = new FormData();
        formData.append('image', file);

        const token = localStorage.getItem('token');
        const headers: any = {};
        if (token) {
            headers['x-access-token'] = token;
        }

        return this.http.post(`${environment.apiUrl}/products/upload`, formData, { headers });
    }

    createProduct(productData: any): Observable<any> {
        return this.api.post('products', productData);
    }

    getPointsSalesCount(): Observable<any> {
        return this.api.get('products/sales-count/points');
    }
}
