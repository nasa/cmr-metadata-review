import { ModuleWithProviders } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

// import { HeroesComponent } from './heroes.component';
// import { HeroDetailComponent } from './hero-detail.component';
import { DaacComponent } from '../app/components/daac.component';
import { CollectionDetailComponent } from '../app/components/collection-detail.component';
import { CollectionsComponent } from '../app/components/collections.component';
import { ChartComponent } from '../app/components/chart.component';
import { LoginComponent } from '../app/components/login.component';
import { RegisterComponent } from '../app/components/register.component';


const appRoutes: Routes = [
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },
  {
    path: 'dashboard',
    component: DaacComponent
  },
  {
    path: 'daac/:id',
    component: CollectionsComponent,
    // children: [
    //   { path: 'granules', component: CollectionsComponent },// url: daac/:id/collections
    //   { path: '', component: CollectionsComponent }, // url: daac/:id/
    //   { path: 'collections', component: CollectionsComponent }, // url: daac/:id/collections
    // ]
  },
  {
    path: 'daac/:id/collections',
    component: CollectionsComponent
  },
  {
    path: 'daac/:id/granules',
    component: CollectionsComponent
  },
  {
    path: 'collections/:id',
    component: CollectionDetailComponent
  },
  {
    path: 'granules/:id',
    component: CollectionDetailComponent
  },
  {
    path: 'signin',
    component: LoginComponent
  },
  {
    path: 'signup',
    component: RegisterComponent
  }
];

export const routing: ModuleWithProviders = RouterModule.forRoot(appRoutes);
