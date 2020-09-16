import { observable, decorate} from "mobx"
import Result from "./Result"

export default class PagingTableModel {
  section = null // String
  filter = null // String
  colorCode = null // String
  sortColumn = null // String
  sortOrder = null // String
  currentPage = 1 // Int
  result = null // Result

  setData(json) {
    this.result = new Result(json)
  }

  get headers() {
    if (this.section == 'open') {
      return [
        { name: "No", field: "no"},
        { name: "Concept_ID", field: "concept_id" },
        { name: "Revision ID", field: "revision_id", width: "50px" },
        { name: "Short_Name", field: "short_name" },
        { name: "Version", field: "version" },
        { name: "Selection", field: "selection", width: "50px"}
      ]
    } else {
      return [
        { name: "No", field: "no"},
        { name: "Concept_ID", field: "concept_id" },
        { name: "Revision ID", field: "revision_id", width: "50px" },
        { name: "Short_Name", field: "short_name" },
        { name: "Version", field: "version" },
        { name: "# Completed Reviews", field: "no_completed_reviews", width: "50px"},
        { name: "# Second Reviews Requested", field: "no_second_reviews_requested", width: "50px" },
        { name: "Selection", field: "selection", width: "50px"}
      ]
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
  result: observable
})