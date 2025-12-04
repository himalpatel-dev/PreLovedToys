import { Injectable } from '@angular/core';
import { ApiService } from './api.service';

@Injectable({
  providedIn: 'root'
})
export class MasterService {

  constructor(private api: ApiService) { }

  getAllCategories() {
    return this.api.get('master/categories');
  }

  getAllSubCategories() {
    return this.api.get('master/subcategories');
  }

  getAgeGroups() {
    return this.api.get('master/age-groups');
  }

  getColors() {
    return this.api.get('master/colors');
  }

  getGenders() {
    return this.api.get('master/genders');
  }

  getMaterials() {
    return this.api.get('master/materials');
  }
}