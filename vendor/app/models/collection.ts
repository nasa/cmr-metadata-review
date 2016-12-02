import { Element } from './element'

export class Collection {
  concept_id: string;
  granule_id: string;
  latest_version: string;
  previous_version: string;
  review: any;
  elements: Element[];
  history: any[];
}