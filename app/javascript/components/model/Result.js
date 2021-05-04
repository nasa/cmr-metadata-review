import { observable, decorate} from "mobx"

export default class Result {

  constructor(json) {

    this.totalItems = null // Int
    this.currentPage = 1 // Int
    this.itemsPerPage = null // Int
    this.records = [] // [String:Any]

    if(json) {
      this.totalItems = json["total_count"]
      this.currentPage = json["page_num"];
      this.itemsPerPage = json["page_size"]
      this.records.length = 0;

      let records = json["records"]
      for (let i=0; i<records.length; i++) {
        records[i].no = (this.itemsPerPage*(this.currentPage-1))+(i+1)
      }
      this.records.push(...records)
    }
  }

  get totalPages() {
    if (this.totalItems != null && this.itemsPerPage != null && this.itemsPerPage !== 0) {
      return Math.ceil(this.totalItems / this.itemsPerPage);
    }
    return 0;
  }
}
decorate(Result, {
  totalItems: observable,
  currentPage: observable,
  itemsPerPage: observable,
  records: observable
})