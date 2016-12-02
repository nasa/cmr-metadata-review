import { Collection } from './collection'

export class Daac {
  name: string;
  collections_count: number;
  granules_count: number;
  reviewed_count: number;
  total_count: number;
  percentage: number;
  collections: Collection[];
}