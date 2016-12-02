import { Injectable } from '@angular/core';

import { Headers, Http } from '@angular/http';

import 'rxjs/add/operator/toPromise';

import { Daac } from '../models/daac';
// import { HEROES } from './mock-heroes';

@Injectable()
export class DaacService {
  private headers = new Headers({ 'Content-Type': 'application/json' });
  private url = "api/v1/daac";

  constructor(private http: Http) { }

  daacs(): Promise<Daac[]> {
    return this.http.get(this.url)
             .toPromise()
             .then(response => response.json() as Daac[]);
  };

  daac(name: string, resource: string): Promise<Daac> {
    let temp_url = this.url + `/${name}?resource=${resource}`;
    return this.http.get(temp_url)
             .toPromise()
             .then(response => response.json() as Daac);
  }

  // handleError(): voild {

  // }
}