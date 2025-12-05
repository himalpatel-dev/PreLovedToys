import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ModalController } from '@ionic/angular';
import { addIcons } from 'ionicons';
import { close } from 'ionicons/icons';

@Component({
    selector: 'app-privacy-modal',
    templateUrl: './privacy-modal.component.html',
    styleUrls: ['./privacy-modal.component.scss'],
    standalone: true,
    imports: [IonicModule, CommonModule]
})
export class PrivacyModalComponent {
    constructor(private modalCtrl: ModalController) {
        addIcons({
            close
        });
    }

    dismiss() {
        this.modalCtrl.dismiss();
    }
}
