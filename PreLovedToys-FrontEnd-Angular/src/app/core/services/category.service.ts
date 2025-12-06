import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from './api';

@Injectable({
    providedIn: 'root'
})
export class CategoryService {

    constructor(private api: ApiService) { }

    getAllCategories(): Observable<any> {
        return this.api.get('master/categories');
    }

    getCategoryById(id: number): Observable<any> {
        return this.api.get(`master/categories/${id}`);
    }
}
