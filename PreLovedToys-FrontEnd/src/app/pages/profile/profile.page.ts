import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, AlertController, NavController, ToastController } from '@ionic/angular';
import { ProductService } from 'src/app/core/services/product.service';
import { AuthService } from 'src/app/core/services/auth.service';
import { ApiService } from 'src/app/core/services/api.service';
import { MasterService } from 'src/app/core/services/master.service';
import { addIcons } from 'ionicons';
import { trashOutline, logOutOutline, checkmarkOutline, checkmarkCircle, starOutline, addCircleOutline, fileTrayOutline, heartOutline, informationCircleOutline, cubeOutline, listOutline, callOutline, pencil, walletOutline, gridOutline, swapHorizontalOutline, pricetagOutline, personOutline, pricetagsOutline, closeOutline } from 'ionicons/icons';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-profile',
  templateUrl: './profile.page.html',
  styleUrls: ['./profile.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class ProfilePage {

  user: any = null;
  myProducts: any[] = [];
  wallet: any = { balance: 0 };
  transactions: any[] = [];
  editMode: boolean = false;
  // UI helpers
  genderOptions = ['Male', 'Female', 'Other'];
  occupationSamples = ['Student', 'Teacher', 'Parent', 'Collector', 'Hobbyist'];
  purposeSamples = ['Buy', 'Sell', 'Swap', 'Donate', 'Learn'];
  categories: any[] = [];
  selectedInterests: number[] = []; // store category ids selected

  constructor(
    private productService: ProductService,
    private authService: AuthService,
    private api: ApiService,
    private navCtrl: NavController,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController,
    private masterService: MasterService
  ) {
    addIcons({ trashOutline, logOutOutline,checkmarkOutline ,checkmarkCircle,starOutline,closeOutline,addCircleOutline,fileTrayOutline,heartOutline,informationCircleOutline,cubeOutline ,listOutline,callOutline,pencil,walletOutline,gridOutline,swapHorizontalOutline,pricetagOutline,personOutline,pricetagsOutline });
  }

  ionViewWillEnter() {
    // 1. Get User info from Local Storage
    const userStr = localStorage.getItem('user');
    if (userStr) this.applyUserToState(JSON.parse(userStr));

    // Always try to load fresh profile from server (if token present)
    this.loadProfile();

    // 2. Get My Listings
    this.loadMyListings();
    // 3. Load Wallet
    if (this.user && this.user.id) this.loadWallet();
    // 4. Load master data (categories for interests)
    this.loadMasterData();
  }

  loadMyListings() {
    this.productService.getMyListings().subscribe({
      next: (res: any) => this.myProducts = res,
      error: (err: any) => console.error(err)
    });
  }

  loadWallet() {
    this.api.get(`wallet/${this.user.id}`).subscribe({
      next: (res: any) => {
        this.wallet = { balance: res.balance };
        this.transactions = res.transactions || [];
      },
      error: (err: any) => console.error('Wallet load error', err)
    });
  }

  loadProfile() {
    // Call backend to get latest profile (requires x-access-token header)
    this.api.get('users/profile').subscribe({
      next: (res: any) => {
        if (res && res.user) {
          this.applyUserToState(res.user);
          localStorage.setItem('user', JSON.stringify(res.user));
          // refresh wallet and master data now that we have user id
          if (res.user.id) {
            this.loadWallet();
            this.loadMasterData();
          }
        }
      },
      error: (err: any) => {
        // Not logged in or token invalid — leave local state as-is
        // console.debug('No profile from server', err?.message || err);
      }
    });
  }

  loadMasterData() {
    // Load all categories with their subcategories
    this.masterService.getAllCategories().subscribe({
      next: (categories: any) => {
        this.categories = Array.isArray(categories) ? categories : [];
        
        // If user has existing interestedIn set as CSV or array, populate selectedInterests
        // NOTE: store categories (not subcategories) in selectedInterests
        if (this.user && this.user.interestedIn) {
          if (Array.isArray(this.user.interestedIn)) {
            // assume array of category ids
            this.selectedInterests = this.user.interestedIn.map((v: any) => Number(v)).filter(Boolean);
          } else if (typeof this.user.interestedIn === 'string') {
            const parts = this.user.interestedIn.split(',').map((s: string) => s.trim()).filter(Boolean);
            const ids: number[] = [];
            for (const p of parts) {
              if (!isNaN(Number(p))) {
                ids.push(Number(p));
                continue;
              }
              // try to match by category name
              const found = this.categories.find((c: any) => c.name === p || c.id === Number(p));
              if (found) ids.push(found.id);
            }
            this.selectedInterests = ids;
          }
        }
      },
      error: (err: any) => console.error('Failed to load categories', err)
    });
  }

  // Helper to apply a user object to local state and selected interests
  applyUserToState(userObj: any) {
    this.user = userObj || null;
    // populate selectedInterests if available
    if (this.user && this.user.interestedIn) {
      if (Array.isArray(this.user.interestedIn)) {
        this.selectedInterests = this.user.interestedIn.map((v: any) => Number(v)).filter(Boolean);
      } else if (typeof this.user.interestedIn === 'string') {
        const parts = this.user.interestedIn.split(',').map((s: string) => s.trim()).filter(Boolean);
        const ids: number[] = [];
        for (const p of parts) {
          if (!isNaN(Number(p))) {
            ids.push(Number(p));
            continue;
          }
          const found = this.categories.find((c: any) => c.name === p || c.id === Number(p));
          if (found) ids.push(found.id);
        }
        this.selectedInterests = ids;
      }
    } else {
      this.selectedInterests = [];
    }
  }

  toggleEdit() {
    this.editMode = !this.editMode;
  }

  saveProfile() {
    const payload: any = {
      name: this.user.name,
      email: this.user.email,
      gender: this.user.gender,
      occupation: this.user.occupation,
      collegeOrUniversity: this.user.collegeOrUniversity,
      aboutMe: this.user.aboutMe,
      purpose: this.user.purpose,
      // Send interestedIn as an array of subcategory IDs
      // Send interestedIn as an array of CATEGORY IDs
      interestedIn: this.selectedInterests
    };
    this.api.put('users/profile', payload).subscribe({
      next: (res: any) => {
        this.showToast(res.message || 'Profile saved');
        if (res && res.pointsCredited) {
          this.showToast(`You earned ${res.pointsCredited} points!`);
        }
        if (res.user) {
          // update local state and storage
          this.applyUserToState(res.user);
          localStorage.setItem('user', JSON.stringify(this.user));
          // refresh related data
          if (this.user.id) {
            this.loadWallet();
          }
          // reload master data to ensure chips/states are in sync
          this.loadMasterData();
        }
        this.editMode = false;
      },
      error: (err: any) => {
        console.error(err);
        this.showToast('Could not save profile');
      }
    });
  }

  // Chips and selections
  toggleInterest(id: number) {
    const idx = this.selectedInterests.indexOf(id);
    if (idx === -1) this.selectedInterests.push(id);
    else this.selectedInterests.splice(idx, 1);
  }

  isInterestSelected(id: number) {
    return this.selectedInterests.indexOf(id) !== -1;
  }

  pickOccupation(sample: string) {
    this.user.occupation = sample;
  }

  pickPurpose(sample: string) {
    this.user.purpose = sample;
  }

  async confirmDelete(id: number) {
    const alert = await this.alertCtrl.create({
      header: 'Delete Listing?',
      message: 'This cannot be undone.',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete',
          role: 'destructive',
          handler: () => this.deleteProduct(id)
        }
      ]
    });
    await alert.present();
  }

  deleteProduct(id: number) {
    this.productService.deleteProduct(id).subscribe({
      next: () => {
        this.showToast('Listing removed');
        this.loadMyListings(); // Refresh list
      },
      error: () => this.showToast('Could not delete')
    });
  }

  logout() {
    this.authService.logout();
    this.navCtrl.navigateRoot('/login');
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({ message: msg, duration: 2000 });
    toast.present();
  }
}