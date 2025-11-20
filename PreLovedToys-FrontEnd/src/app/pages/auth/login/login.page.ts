import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { IonicModule, ToastController, NavController } from '@ionic/angular';
import { AuthService } from 'src/app/core/services/auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.page.html',
  styleUrls: ['./login.page.scss'],
  standalone: true,
  imports: [IonicModule, CommonModule, FormsModule] // <--- Import Modules here
})
export class LoginPage {

  mobile: string = '9727376727';

  constructor(
    private authService: AuthService,
    private toastCtrl: ToastController,
    private navCtrl: NavController // To navigate to next page
  ) { }

  async onSendOtp() {
    if (!this.mobile || this.mobile.length < 10) {
      this.showToast('Please enter a valid mobile number');
      return;
    }

    this.authService.sendOtp(this.mobile).subscribe({
      next: async (res: any) => {
        console.log('Response:', res);
        // Show Success Message
        await this.showToast(`${res.message} , OTP : ${res.otp}`);

        // Navigate to OTP Page (We will create this next)
        // We pass the mobile number to the next page so the user doesn't have to type it again
        this.navCtrl.navigateForward(['/otp'], {
          queryParams: { mobile: this.mobile }
        });
      },
      error: async (err) => {
        console.error(err);
        await this.showToast(err.error?.message || 'Something went wrong');
      }
    });
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