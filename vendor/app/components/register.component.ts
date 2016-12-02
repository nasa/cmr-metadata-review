import { Component } from '@angular/core'
import { Angular2TokenService } from 'angular2-token';

import { AuthData } from '../models/auth_data';
import { AuthResponse } from '../models/auth_response';

@Component({
  selector: 'sign-up',
  templateUrl: '../views/register.component.html',
  styles: [String(require('../styles/register.component.css'))]
})

export class RegisterComponent {
  public details: {};
  auth_data: AuthData = <AuthData>{};
  auth_response: AuthResponse;

  constructor(private ng2TokenService: Angular2TokenService) {}

  signUp(): void {
    this.ng2TokenService.registerAccount(
      this.auth_data.email,
      this.auth_data.password,
      this.auth_data.passwordConfirmation
    ).subscribe((resp) => {
      window.location.href = '/';
    });
  }
}
