import { Injectable } from '@angular/core'

import { Headers, Http } from '@angular/http';

import 'rxjs/add/operator/toPromise';

import { Collection } from '../models/collection';

@Injectable()
export class CollectionService {
  private headers = new Headers({ 'Content-Type': 'application/json' });
  private url = 'api/v1/collections';

  constructor(private http: Http) { }

  collections(): Promise<Collection[]> {
    return this.http.get(this.url)
             .toPromise()
             .then(response => response.json() as Collection[]);
  };

  collection(concept_id: string, user_id: string): Promise<Collection> {
    let temp_url = this.url + `/${concept_id}?user_id=${user_id}`;
    return this.http.get(temp_url)
             .toPromise()
             .then(response => response.json() as Collection);
  }

  recommend(concept_id: string, params: Object, user_id: string): Promise<Collection> {
    let temp_url = this.url + `/${concept_id}/recommend?user_id=${user_id}`;
    return this.http.put(temp_url, params)
             .toPromise()
             .then(response => response.json() as Collection)
  }

  randomGranule(concept_id: string): Promise<any> {
    let temp_url = this.url + `/${concept_id}/random_granule`;
    return this.http.put(temp_url, {})
             .toPromise()
             .then(response => response.json() as Collection)
  }

  startReviewing(concept_id: string, userid: string): Promise<any> {
    let temp_url = this.url + `/${concept_id}/take_for_review?user_id=${userid}`;
    return this.http.put(temp_url, {})
             .toPromise()
             .then(response => response.json());
  }

  reviewed(concept_id: string, userid: string): Promise<any> {
    let temp_url = this.url + `/${concept_id}/review?user_id=${userid}`;
    return this.http.put(temp_url, {})
             .toPromise()
             .then(response => response.json());
  }

  // handleError(): voild {

  // }
}