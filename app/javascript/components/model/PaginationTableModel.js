import { computed, observable, decorate} from "mobx"
import Result from "./Result"

export default class PagingTableModel {

  constructor() {
    this.section = null // String
    this.filter = null // String
    this.daac = null // String
    this.campaign = null // String
    this.colorCode = null // String
    this.colorCodeCollection = null // Bool
    this.colorCodeGranule = null // Bool
    this.sortColumn = null // String
    this.sortOrder = "asc" // String
    this.currentPage = 1 // Int
    this.result = null // Result
    this.loading = false // Bool
    this.pageSize = 10 // Int
  }


  setData(json) {
    this.result = new Result(json)
  }

  get headers() {
    if (this.section == 'open') {
      return [
        observable({name: "No", field: "no", sortable: false}),
        observable({name: "Format", field: "format", width: "50px", sortable: true, order: null}),
        observable({name: "Concept ID", field: "concept_id" , sortable: true, order: null}),
        observable({name: "Revision ID", field: "revision_id", width: "50px", sortable: false, order: null }),
        observable({name: "Short Name", field: "short_name" , sortable: true, order: null}),
        observable({name: "Version", field: "version", sortable: false, order: null}),
        observable({name: "Date Ingested", field: "date_ingested", sortable: true, order: null, width: "50px"}),
        observable({name: "Selection", field: "selection", width: "50px", sortable: false})
      ]
    } else {
      return [
        observable({name: "No", field: "no", sortable: false}),
        observable({name: "Format", field: "format", width: "50px", sortable: true, order: null}),
        observable({name: "Concept ID", field: "concept_id", sortable: true, order: null}),
        observable({name: "Revision ID", field: "revision_id", width: "50px", sortable: false, order: null}),
        observable({name: "Short Name", field: "short_name", sortable: true, order: null}),
        observable({name: "Version", field: "version", sortable: false, order: null}),
        observable({name: "# Completed Reviews", field: "no_completed_reviews", width: "50px", sortable: false}),
        observable({name: "# Second Reviews Requested", field: "no_second_reviews_requested", width: "50px", sortable: false}),
        observable({ name: "Date Ingested", field: "date_ingested", sortable: true, order: null, width: "50px"}),
        observable({name: "Selection", field: "selection", width: "50px", sortable: false})
      ]
    }
  }

  setSortBy(column, order) {
    this.sortColumn = column
    this.sortOrder = order

    for (let key in this.headers){
      let header = this.headers[key]
      if (header.field == column) {
        header.order = order
      } else {
        header.order = null
      }
    }
  }

}

decorate(PagingTableModel, {
  section: observable,
  filter: observable,
  daac: observable,
  campaign: observable,
  colorCode: observable,
  sortColumn: observable,
  sortOrder: observable,
  currentPage: observable,
  result: observable,
  loading: observable,
  headers: computed
})
