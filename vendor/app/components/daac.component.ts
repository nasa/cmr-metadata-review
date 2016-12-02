import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

import { Daac } from '../models/daac';
import { DaacService } from '../services/daac.service';

@Component({
  selector: 'daac-container',
  templateUrl: '../views/daac.component.html',
  styles: [String(require('../styles/daac.component.css'))],
  providers: [DaacService]
})

export class DaacComponent implements OnInit {
  daacs: Daac[];
  selectedDaac: Daac;

  constructor(
    private router: Router,
    private daacService: DaacService
  ) { }

  getDaacs(): void {
    this.daacService.daacs().then(daacs => this.daacs = daacs);
  }

  ngOnInit(): void {
    this.getDaacs();
  }

  onSelect(daac: Daac): void {
    this.selectedDaac = daac;
  }

  gotoDetail(daac: Daac): void {
    this.onSelect(daac);
    // this.router.navigate(['detail', this.selectedDaac.name]);
  }
}
