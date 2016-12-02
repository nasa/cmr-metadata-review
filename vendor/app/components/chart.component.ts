import { Component, Input } from '@angular/core';
import { ActivatedRoute, Params } from '@angular/router';

import { Daac } from '../models/daac';
import { DaacService } from '../services/daac.service';

@Component({
  selector: 'chart-holder',
  templateUrl: '../views/chart.component.html'
})

export class ChartComponent {
  @Input() daac: Daac;
  @Input() pieChartData:number[] = [];

  constructor(private daacService: DaacService,
              private route: ActivatedRoute) { }

  // ngOnInit(): void {
  //   this.route.params.forEach((params: Params) => {
  //     let id = params['id'];
  //     this.daacService.daac(id)
  //       .then(daac => this.daac = daac);
  //   });
  // }

  public pieChartType:string = 'pie';

  // Pie
  public pieChartLabels:string[] = ['Reviewed', 'Remaining'];


  public randomizeType():void {
    this.pieChartType = this.pieChartType === 'doughnut' ? 'pie' : 'doughnut';
  }

  public chartClicked(e:any):void {
    console.log(e);
  }

  public chartHovered(e:any):void {
    console.log(e);
  }
}