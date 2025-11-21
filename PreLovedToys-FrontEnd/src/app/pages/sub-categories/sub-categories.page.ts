import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, NavController } from '@ionic/angular';
import { ActivatedRoute } from '@angular/router';
import { MasterService } from 'src/app/core/services/master.service';
import { addIcons } from 'ionicons';
import { chevronForwardOutline } from 'ionicons/icons';


@Component({
  selector: 'app-sub-categories',
  templateUrl: './sub-categories.page.html',
  styleUrls: ['./sub-categories.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule]
})
export class SubCategoriesPage implements OnInit {

  category: any = null;
  subCategories: any[] = [];

  constructor(
    private route: ActivatedRoute,
    private masterService: MasterService,
    private navCtrl: NavController
  ) {
    addIcons({ chevronForwardOutline });
  }

  ngOnInit() {
    const catId = this.route.snapshot.paramMap.get('categoryId');
    if (catId) {
      this.loadCategory(Number(catId));
    }
  }

  loadCategory(id: number) {
    // We fetch all categories and find the one we need 
    // (Or you can create a specific getCategoryById API for better performance)
    this.masterService.getAllCategories().subscribe((res: any) => {
      this.category = res.find((c: any) => c.id === id);
      if (this.category) {
        this.subCategories = this.category.subcategories;
      }
    });
  }

  goToProducts(subCatId: number, title: string) {
    // Navigate to Product List with Query Params
    this.navCtrl.navigateForward(['/product-list'], {
      queryParams: {
        subCategoryId: subCatId,
        title: title
      }
    });
  }
}