import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ApiService } from './api';

@Injectable({
    providedIn: 'root'
})
export class SubCategoryService {

    constructor(private api: ApiService) { }

    getAllSubCategories(): Observable<any> {
        return this.api.get('master/subcategories');
    }

    getSubCategoryById(id: number): Observable<any> {
        return this.api.get(`master/subcategories/${id}`);
    }

    // Get subcategories by filtering from all subcategories
    // Since there's no direct endpoint, we'll filter on the frontend
    getSubCategoriesByCategoryId(categoryId: number): Observable<any> {
        return this.getAllSubCategories();
    }
}
