import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';

import { Collection } from '../models/collection';
import { CollectionService } from '../services/collection.service'

import { TableOptions, TableColumn, ColumnMode } from 'angular2-data-table';

import { Angular2TokenService } from 'angular2-token';

@Component({
  selector: 'collection-detail',
  templateUrl: '../views/collection-detail.component.html',
  styles: [String(require('../styles/collection-detail.component.css'))],
  providers: [CollectionService]
})

export class CollectionDetailComponent implements OnInit {
  public collection: Collection;
  options: TableOptions;
  elements = [];
  user_id = '';
  editing = {};
  review = {};
  history = {};

  @ViewChild('recommended') recommendation_template: TemplateRef<any>;
  @ViewChild('reason') reason_template: TemplateRef<any>;

  constructor(private collectionService: CollectionService,
              private ng2TokenService: Angular2TokenService,
              private route: ActivatedRoute) { }

  ngOnInit(): void {
    this.route.params.forEach((params: Params) => {
      let concept_id = params['id'];
      if(this.ng2TokenService.currentUserData) {
        this.user_id = this.ng2TokenService.currentUserData['_id'].$oid;
        this.collectionService.collection(concept_id, this.user_id).then(coll => this.store(coll));
      }
      else {
        this.ng2TokenService.validateToken().subscribe((data) => {
          console.log(data);
          this.user_id = this.ng2TokenService.currentUserData['_id'].$oid;
          this.collectionService.collection(concept_id, this.user_id).then(coll => this.store(coll));
        }, (err) => {
          this.collectionService.collection(concept_id, '').then(coll => this.store(coll));
        });
      }

    });

    this.options = new TableOptions({
      columnMode: ColumnMode.force,
      columnWidth: 'auto',
      headerHeight: 50,
      footerHeight: 50,
      rowHeight: 'auto',
      loadingIndicator: true,
      columns: [
        new TableColumn({
          name: 'Element',
          prop: 'name',
          sortable: false
        }),
        new TableColumn({
          name: 'Previous version value',
          prop: 'previous_value',
          sortable: false
        }),
        new TableColumn({
          template: this.recommendation_template,
          name: 'Recommended changes',
          prop: 'recommended',
          sortable: false
        }),
        new TableColumn({
          template: this.reason_template,
          name: 'Reason',
          prop: 'reason',
          sortable: false
        }),
        new TableColumn({
          name: 'Latest version value',
          prop: 'latest_value',
          sortable: false
        })
      ]
    });
  }

  store(coll: Collection): void {
    this.collection = coll;
    this.review = this.collection.review;
    this.history = this.collection.history;
    this.elements = [];
    this.elements.push(...this.collection.elements);
    this.preetify_elements();
  }

  collReviewed(): void {
    let id = this.collection.concept_id || this.collection.granule_id;
    this.collectionService.reviewed(id, this.user_id).then((data) => {
      window.location.reload();
      this.review = data;
    })

  }

  startReviewing(): void {
    let id = this.collection.concept_id || this.collection.granule_id;
    this.collectionService.startReviewing(id, this.user_id).then((data) => {
      window.location.reload();
      this.review = data;
    });
  }

  preetify_elements(): void {
    this.elements.forEach((element, index) => {
      element['latest_value'] = this.preety_print(index, element.latest_value, 'latest_value');
      element['previous_value'] = this.preety_print(index, element.previous_value, 'previous_value');
      element['reason'] = this.preety_print(index, element.reason, 'reason');
      element['recommended'] = this.preety_print(index, element.recommended, 'recommended');
    })
  }

  preety_print(index: number, element: any, field: string): string {
    let type = typeof(element);
    let preety_string = element;
    this.editing[index] = this.editing[index] || { field : false };
    if((type === 'object') && (element != null))
      preety_string = JSON.stringify(element, null, 2);
    else if (element === '' || element === null || element === undefined) {
      this.editing[index][field] = true;
    }
    return preety_string;
  }

  updateValue(event, cell, cellValue, row): void {
    let index = row.$$index;
    let update_value = event.target.value;
    let changes = this.elements[index];

    if (update_value && update_value !== '' && update_value !== changes[cell]) {
      this.editing[index][cell] = false;
      changes = { 'name': changes['name'] };
      changes[cell] = update_value;
      this.elements[index][cell] = update_value;
      this.collectionService.recommend(
        this.collection.concept_id || this.collection.granule_id,
        changes,
        this.user_id
      ).then(coll => this.store(coll));
    }
  }
}
