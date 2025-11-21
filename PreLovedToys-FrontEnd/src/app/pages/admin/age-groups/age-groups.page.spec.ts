import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AgeGroupsPage } from './age-groups.page';

describe('AgeGroupsPage', () => {
  let component: AgeGroupsPage;
  let fixture: ComponentFixture<AgeGroupsPage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(AgeGroupsPage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
