import PaginationTableModel from "../model/PaginationTableModel";
import tableResponse from "../data/query_response";

export default class PagingTableViewModel {
  model = new PaginationTableModel()
  // Access the Model

  set loading(value) {
    this.model.loading = value
  }

  get loading() {
    return this.model.loading
  }

  get totalItems() {
    let result = this.model.result
    let totalItems = 0
    if (result != null) {
      totalItems = result.totalItems
    }
   
    return totalItems
  }

  get totalPages() {
    let result = this.model.result
    let totalPages = 0
    if (result != null) {
      totalPages = result.totalPages
    }
    return totalPages
  }

  get itemsPerPage() {
    let result = this.model.result
    let itemsPerPage = 0
    if (result != null) {
      itemsPerPage = result.itemsPerPage
    }
    return itemsPerPage
  }

  get currentPage() {
    return this.model.currentPage
  }

  get records() {
    let result = this.model.result
    let records = []
    if (result != null) {
      records = result.records
    }
    return records
  }

  
  get headers() {
    return this.model.headers
  }


  get section() {
    return this.model.section
  }

  get filter() {
    return this.model.filter
  }

  get colorCode() {
    return this.model.colorCode
  }

  get sortColumn() {
    return this.model.sortColumn
  }

  get sortOrder() {
    return this.model.sortOrder
  }

  fetchData() {
    let url = `/records/find_records_json?state=${this.section}&page_num=${this.currentPage}&page_size=10`
    if (this.sortColumn != null && this.sortOrder != null) {
      url = url + '&sort_column='+this.sortColumn+'&sort_order='+this.sortOrder
    }
    console.log(url);
    const requestOptions = {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    };
    this.loading = true
    fetch(url, requestOptions)
      .then(response => response.json()).then(data => {
      this.loading = false
      this.model.setData(data);
    })
      .catch(error => {
        this.loading = false
        console.error('There was an error!', error);
      });
  }

  // User Intent(s)

  selectPage(pageNo) {
    this.model.currentPage = pageNo
    this.fetchData()
  }

  setSection(value) {
    this.model.section = value
  }

  filterByText(value) {
    this.model.filter = value
  }

  filterByColor(value) {
    this.model.colorFilter = value
  }

  sortBy(column, order) {
    this.model.setSortBy(column, order)
    this.fetchData()

  }
}