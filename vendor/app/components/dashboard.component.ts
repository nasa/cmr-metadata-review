import { Component, OnInit } from '@angular/core'
import { Router } from '@angular/router'

@Component({
  selector: 'app',
  templateUrl: '../views/dashboard.component.html',
  styles: [String(require('../styles/dashboard.component.css'))]
})

export class DashboardComponent {
  public details: {};
  constructor(private router: Router) {}

  onInit(): void {
    // this.details = this.detailService.details( details => this.details = details)  ;
  }
}
