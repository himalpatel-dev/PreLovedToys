import { ComponentFixture, TestBed } from '@angular/core/testing';
import { GendersPage } from './genders.page';

describe('GendersPage', () => {
  let component: GendersPage;
  let fixture: ComponentFixture<GendersPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(GendersPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
