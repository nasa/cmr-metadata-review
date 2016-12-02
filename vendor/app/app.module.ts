import '../src/rjx-extensions.ts';
import { NgModule } from '@angular/core';
import { APP_BASE_HREF } from '@angular/common';

import { BrowserModule } from '@angular/platform-browser';
import { ChartsModule } from 'ng2-charts/ng2-charts';
import { Angular2TokenService } from 'angular2-token';

import { Angular2DataTableModule } from 'angular2-data-table';

import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';

import { AppComponent } from './components/app.component';
import { DaacComponent } from './components/daac.component';
import { CollectionsComponent } from './components/collections.component';
import { CollectionDetailComponent } from './components/collection-detail.component'
import { ChartComponent } from './components/chart.component';
import { LoginComponent } from './components/login.component';
import { RegisterComponent } from './components/register.component';

import { DaacService } from './services/daac.service';
import { CollectionService } from './services/collection.service';


// import { HeroSearchService } from './hero-search.service';

import { routing } from '../config/app.routing';

@NgModule({
  imports: [
    FormsModule,
    BrowserModule,
    HttpModule,
    ChartsModule,
    Angular2DataTableModule,
    routing
  ],
  declarations: [
    AppComponent,
    DaacComponent,
    CollectionsComponent,
    ChartComponent,
    CollectionDetailComponent,
    LoginComponent,
    RegisterComponent
  ],
  providers: [
    DaacService,
    CollectionService,
    Angular2TokenService,
    { provide: APP_BASE_HREF, useValue: '' }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }