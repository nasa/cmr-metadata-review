import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { Router, ActivatedRoute, Params } from '@angular/router';

import { Daac } from '../models/daac';
import { Collection } from '../models/collection';
import { DaacService } from '../services/daac.service';
import { CollectionService } from '../services/collection.service';

import { TableOptions, TableColumn, ColumnMode } from 'angular2-data-table';

@Component({
  selector: 'daac-detail-container',
  templateUrl: '../views/collections.component.html',
  styles: [String(require('../styles/collections.component.css'))],
  providers: [DaacService]
})

export class CollectionsComponent {
  daac: Daac;
  collections = [];
  temp = [];
  editing = {};
  resource = '';
  selected_granule: any;

  @ViewChild('template') template: TemplateRef<any>;
  @ViewChild('collectionTemplate') collection_template: TemplateRef<any>;
  @ViewChild('selected_granule_template') selected_granule_template: TemplateRef<any>;

  options: TableOptions;

  constructor(private route: ActivatedRoute,
    private daacService: DaacService,
    private collectionService: CollectionService) {
  }

  ngOnInit(): void {
    this.route.params.forEach((params: Params) => {
      let id = params['id'];
      this.resource = window.location.pathname.split('/')[3] || 'collections';
      this.daacService.daac(id, this.resource).then((daac) => {
        this.daac = daac;
        this.collections.push(...this.daac.collections);
        this.temp.push(...this.collections);
      });
    });
    this.options = new TableOptions({
      columnMode: ColumnMode.force,
      headerHeight: 50,
      footerHeight: 50,
      limit: 25,
      rowHeight: 'auto',
      loadingIndicator: true,
      selectionType: false,
      columns: this.appropriateColumns()
    });
  }

  appropriateColumns(): TableOptions[] {
    let columns = [];
    if (this.resource == 'collections') {
      columns = [
        new TableColumn({
          template: this.template,
          name: 'Concept Id',
          prop: 'concept_id',
          sortable: false
        }),
        new TableColumn({
          name: 'Entry Title',
          prop: 'entry_title',
          sortable: false
        }),
        new TableColumn({
          name: 'Granule Count',
          prop: 'granule_count',
          sortable: false
        }),
        new TableColumn({
          template: this.selected_granule_template,
          name: 'Selected Granule',
          prop: 'granule_id',
          sortable: false
        })
      ]
    }
    else if (this.resource == 'granules') {
      columns = [
        new TableColumn({
          template: this.template,
          name: 'Granule Id',
          prop: 'granule_id',
          sortable: false
        }),
        new TableColumn({
          name: 'Location',
          prop: 'location',
          sortable: false
        }),
        new TableColumn({
          template: this.collection_template,
          name: 'Collection',
          prop: 'collection_id'
        })
      ]
    }
    return columns;
  }

  updateFilter(val) {
    this.collections.splice(0, this.collections.length);
    let temp = this.temp.filter(function(coll) {
      let id = coll.concept_id || coll.granule_id;
      return id.toLowerCase().indexOf(val) !== -1 || !val;
    });

    this.collections.push(...temp);
  }

  randomGranule(row): void {
    this.collectionService.randomGranule(row.concept_id).then((granule) => {
      this.collections[row.$$index].granule_id = granule.granule_id;
    });
  }
}
