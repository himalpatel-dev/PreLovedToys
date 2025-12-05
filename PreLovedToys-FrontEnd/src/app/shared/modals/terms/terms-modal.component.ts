import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule, ModalController } from '@ionic/angular';
import { addIcons } from 'ionicons';
import { close } from 'ionicons/icons';

@Component({
    selector: 'app-terms-modal',
    templateUrl: './terms-modal.component.html',
    styleUrls: ['./terms-modal.component.scss'],
    standalone: true,
    imports: [IonicModule, CommonModule]
})
export class TermsModalComponent {
    constructor(private modalCtrl: ModalController) {
        addIcons({
            close
        });
    }

    dismiss() {
        this.modalCtrl.dismiss();
    }
}
