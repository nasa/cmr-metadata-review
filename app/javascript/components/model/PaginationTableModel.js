import { computed, observable, decorate} from "mobx"
import Result from "./Result"

export default class PagingTableModel {
  section = null // String
  filter = null // String
  colorCode = null // String
  sortColumn = null // String
  sortOrder = "asc" // String
  currentPage = 1 // Int
  result = null // Result

  setData(json) {
    this.result = new Result(json)
  }

  get headers() {
    if (this.section == 'open') {
      return [
        observable({ name: "No", field: "no", sortable: false}),
        observable({ name: "Concept_ID", field: "concept_id" , sortable: true, order: null}),
        observable({ name: "Revision ID", field: "revision_id", width: "50px", sortable: true, order: null }),
        observable({ name: "Short_Name", field: "short_name" , sortable: true, order: null}),
        observable({ name: "Version", field: "version", sortable: true, order: null}),
        observable({ name: "Selection", field: "selection", width: "50px", sortable: false})
      ]
    } else {
      return [
        observable({name: "No", field: "no", sortable: false}),
        observable({name: "Concept_ID", field: "concept_id", sortable: true, order: null}),
        observable({name: "Revision ID", field: "revision_id", width: "50px", sortable: true, order: null}),
        observable({name: "Short_Name", field: "short_name", sortable: true, order: null}),
        observable({name: "Version", field: "version", sortable: true, order: null}),
        observable({name: "# Completed Reviews", field: "no_completed_reviews", width: "50px", sortable: false}),
        observable({name: "# Second Reviews Requested", field: "no_second_reviews_requested", width: "50px", sortable: false}),
        observable({name: "Selection", field: "selection", width: "50px", sortable: false})
      ]
    }
  }

  sortBy(column, order) {
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
  colorCode: observable,
  sortColumn: observable,
  sortOrder: observable,
  currentPage: observable,
  result: observable,
  headers: computed
})