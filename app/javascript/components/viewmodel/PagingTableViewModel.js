import PagingTableModel from "../model/PagingTableModel";

export default class PagingTableViewModel {
  model = new PagingTableModel()
  // Access the Model
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

  // User Intent(s)
  setSection(value) {
    this.model.section = value
  }

  filterByText(value) {
    this.model.filter = value
  }

  filterByColor(value) {
    this.model.colorFilter = value
  }

  sortBy(value) {
    this.model.sortOrder = value
  }
}