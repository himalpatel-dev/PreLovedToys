import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router';
import { ApiService } from 'src/app/core/services/api.service';

@Component({
  selector: 'app-product-list',
  templateUrl: './product-list.page.html',
  styleUrls: ['./product-list.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class ProductListPage implements OnInit {

  products: any[] = [];
  pageTitle: string = 'Products';
  isLoading = true;

  constructor(
    private route: ActivatedRoute,
    private api: ApiService,
    private navCtrl: NavController
  ) { }

  ngOnInit() {
    this.route.queryParams.subscribe(params => {
      if (params['subCategoryId']) {
        this.pageTitle = params['title'] || 'Products';
        this.loadProducts(params['subCategoryId']);
      }
    });
  }

  loadProducts(subId: number) {
    this.isLoading = true;
    // Call API with filter
    this.api.get(`products?subCategoryId=${subId}`).subscribe({
      next: (res: any) => {
        this.products = res;
        this.isLoading = false;
      },
      error: () => this.isLoading = false
    });
  }

  goToDetail(product: any) {
    // Navigate to details page passing the ID
    this.navCtrl.navigateForward(['/productdetails', product.id]);
  }
}