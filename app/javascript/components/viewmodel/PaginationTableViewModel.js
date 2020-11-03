import PaginationTableModel from "../model/PaginationTableModel";

export default class PagingTableViewModel {
  model = new PaginationTableModel()
  abortController = null; // used to cancel fetch requests

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

  get pageSize() {
    return this.model.pageSize
  }

  get records() {
    let result = this.model.result
    let records = []
    if (result != null) {
      records = result.records
    }
    return records
  }

  get daac() {
    return this.model.daac
  }

  set daac(value) {
    this.model.daac = value
  }

  get campaign() {
    return this.model.campaign
  }

  set campaign(value) {
    this.model.campaign = value
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

  set filter(value) {
    this.model.filter = value
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

    let url = `/records/find_records_json?state=${this.section}&page_num=${this.currentPage}&page_size=${this.pageSize}`
    if (this.sortColumn != null && this.sortOrder != null) {
      url = url + '&sort_column='+this.sortColumn+'&sort_order='+this.sortOrder
    }
    if (this.filter != null) {
      url = url + '&filter='+this.filter
    }
    if (this.colorCode != null && this.colorCode != "any") {
      url = url + '&color_code='+this.colorCode
    }
    let daac = this.model.daac
    let campaign = this.model.campaign
    if (daac != null && daac != "DAAC: ANY") {
      url = url + '&daac='+encodeURI(daac)
    }
    if (campaign != null && campaign != "CAMPAIGN: ANY") {
      url = url + '&campaign='+encodeURI(campaign)
    }

    console.log(url);
    const requestOptions = {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    };
    this.loading = true
    if (this.abortController != null) {
      this.abortController.abort()
    }
    this.abortController = new window.AbortController();;
    fetch(url, { signal: this.abortController.signal })
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
    this.fetchData()
  }

  filterByColor(value) {
    this.model.colorCode = value
    this.fetchData()
  }

  selectPageSize(value) {
    if (value == 'all') {
      value = 100000
    }
    this.model.pageSize = value
    this.fetchData()
  }

  sortBy(column, order) {
    this.model.setSortBy(column, order)
    this.fetchData()

  }
}