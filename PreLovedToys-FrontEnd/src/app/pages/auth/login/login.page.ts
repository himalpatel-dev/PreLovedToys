import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, ToastController, NavController, ModalController } from '@ionic/angular';
import { AuthService } from 'src/app/core/services/auth.service';
import { addIcons } from 'ionicons';
import { arrowForward } from 'ionicons/icons';
import { TermsModalComponent } from 'src/app/shared/modals/terms/terms-modal.component';
import { PrivacyModalComponent } from 'src/app/shared/modals/privacy/privacy-modal.component';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule]
})
export class LoginPage implements OnInit {

  mobile: string = '9727376727';
  isLoading: boolean = false;

  constructor(
    private authService: AuthService,
    private toastCtrl: ToastController,
    private navCtrl: NavController,
    private modalCtrl: ModalController
  ) {
    addIcons({
      arrowForward
    });
  }

  ngOnInit() {
    // Initialize component
  }

  async onSendOtp() {
    if (!this.mobile || this.mobile.length < 10) {
      this.showToast('Please enter a valid mobile number');
      return;
    }

    this.isLoading = true;

    this.authService.sendOtp(this.mobile).subscribe({
      next: async (res: any) => {
        console.log('Response:', res);
        await this.showToast(`${res.message}`);
        this.isLoading = false;

        // Navigate to OTP page with mobile number
        this.navCtrl.navigateForward('/otp', {
          queryParams: { mobile: this.mobile }
        });
      },
      error: async (err) => {
        console.error(err);
        this.isLoading = false;
        await this.showToast(err.error?.message || 'Something went wrong');
      }
    });
  }

  async showTerms() {
    const modal = await this.modalCtrl.create({
      component: TermsModalComponent,
      cssClass: 'terms-modal'
    });
    return await modal.present();
  }

  async showPrivacy() {
    const modal = await this.modalCtrl.create({
      component: PrivacyModalComponent,
      cssClass: 'terms-modal'
    });
    return await modal.present();
  }

  async showToast(msg: string) {
    const toast = await this.toastCtrl.create({
      message: msg,
      duration: 2000,
      position: 'bottom'
    });
    toast.present();
  }
}
