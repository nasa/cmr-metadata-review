import { observable, decorate} from "mobx"
export default class PagingTableModel {
  section = null // String
  filter = null // String
  colorCode = null // String
  sortColumn = null // String
  sortOrder = null // String
  records = [] // array of Record
}
decorate(PagingTableModel, {
  section: observable,
  filter: observable,
  colorCode: observable,
  sortColumn: observable,
  sortOrder: observable,
  records: observable
})