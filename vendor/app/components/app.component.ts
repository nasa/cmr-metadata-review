import { Component } from '@angular/core';
import { Angular2TokenService } from 'angular2-token';

import { Router } from '@angular/router';

@Component({
  selector: 'app',
  templateUrl: '../views/app.component.html',
  styles: [String(require('../styles/app.component.css'))]
})

export class AppComponent {
  title = 'CMR Review Dashboard';
  constructor(
    private ng2TokenService: Angular2TokenService,
    private router: Router
  ) {
    ng2TokenService.init();
  }

  signOut(): void {
    this.ng2TokenService.signOut().subscribe((resp) => {
      this.router.navigateByUrl('/');
      console.log(resp);
    });
  }
}