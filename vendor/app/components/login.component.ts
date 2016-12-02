import { Component, OnInit } from '@angular/core'
import { Angular2TokenService } from 'angular2-token';

import { AuthData } from '../models/auth_data';
import { AuthResponse } from '../models/auth_response';

import { Router } from '@angular/router';

@Component({
  selector: 'sign-in',
  templateUrl: '../views/login.component.html',
  styles: [String(require('../styles/login.component.css'))]
})

export class LoginComponent {
  public details: {};
  auth_data: AuthData = <AuthData>{};
  auth_response: AuthResponse;

  constructor(private ng2TokenService: Angular2TokenService, private router: Router) {}

  onInit(): void {
    // this.details = this.detailService.details( details => this.details = details)  ;
  }

  signIn(): void {
    this.ng2TokenService.signIn(this.auth_data.email, this.auth_data.password)
      .subscribe(
        (resp) => this.router.navigateByUrl('/'),
        (error) => console.log(error)
      );
  }
}
