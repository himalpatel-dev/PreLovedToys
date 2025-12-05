import { Directive, HostListener, ElementRef } from '@angular/core';

@Directive({
  selector: '[onlyNumbers]' // used as attribute: onlyNumbers or only-numbers
})
export class OnlyNumbersDirective {
  private el: HTMLInputElement;
  constructor(private elementRef: ElementRef) {
    // ion-input's native input is inside shadow DOM; selector will be used on ion-input host.
    // We'll try to get native input if possible:
    const native = this.elementRef.nativeElement;
    // If directive applied on ion-input, native.querySelector('input') will find actual input.
    this.el = native.tagName === 'ION-INPUT'
      ? native.shadowRoot?.querySelector('input') ?? native
      : native;
  }

  @HostListener('ionInput', ['$event'])
  @HostListener('input', ['$event'])
  onInput(event: any) {
    const value = (event?.detail?.value ?? this.el.value ?? '') as string;
    const filtered = value.replace(/\D+/g, '');
    if (event?.detail) {
      // if ion-input fired the event, update via property binding
      (event.target as any).value = filtered;
    } else {
      this.el.value = filtered;
    }
    // If you are using ngModel, update it by dispatching input event so ngModel picks up change
    const ev = new Event('input', { bubbles: true });
    this.el.dispatchEvent(ev);
  }

  @HostListener('paste', ['$event'])
  onPaste(e: ClipboardEvent) {
    e.preventDefault();
    const text = e.clipboardData?.getData('text') ?? '';
    const digits = text.replace(/\D+/g, '');
    if (this.el) {
      this.el.value = digits;
      this.el.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }
}
