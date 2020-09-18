import React from "react"
import PaginationTableViewModel from "../viewmodel/PaginationTableViewModel";
import PaginationView from "./PaginationView"
import SearchView from "./SearchView"
import HeaderView from "./HeaderView"
import PropTypes from "prop-types";
import {observer} from "mobx-react"
import "../eui.css"
import "../pagination.css"

const PaginationTableView = observer(
  class PaginationTableView extends React.Component {
    viewModel = new PaginationTableViewModel()

    constructor(props) {
      super(props)
      this.viewModel.setSection(this.props.section)
      this.createRow = this.createRow.bind(this)
    }

    getDaac() {
      var element = document.getElementById("daac")
      var value = element.options[element.selectedIndex].value
      return value
    }

    getCampaign() {
      var element = document.getElementById("campaign")
      var value = element.options[element.selectedIndex].value
      return value
    }

    componentDidMount() {
      this.viewModel.daac = this.getDaac()
      this.viewModel.campaign = this.getCampaign()
      this.viewModel.selectPage(this.viewModel.currentPage)
    }

    checkAll(table_name)
    {
      var table = document.getElementById (table_name);
      var form_id = table.getAttribute("form_id")
      var checkboxes = table.querySelectorAll ('input[type=checkbox]');
      for (var i = 0; i < checkboxes.length; i++) checkboxes[i].checked = !checkboxes[i].checked
      toggleAllButtons(form_id)
    }

    render() {
      let viewModel = this.viewModel
      let headers = viewModel.headers;
      let records = viewModel.records
      let rows = records.map(row => {
        return this.createRow(row)
      })
      let loadingStyle = {
        height: "100px",
        fontWeight: "bold"
      }
      let loadingTr =
        <tr>
          <td colSpan="9" style={loadingStyle}>
            <div style={{display: "flex", justifyContent: "center", alignItems: "center"}}>
              Loading...
            </div>
          </td>
        </tr>

      let selectAll = null
      if (this.props.admin || this.props.role == 'mdq_curator') {
        selectAll =
          <div align="right">
            <a href="javascript:void(0);" onClick={() => {
              this.checkAll(this.props.formId+"_table")
            }}>Select All</a>
          </div>
      }

      return (
        <>
          <div style={{display:"flex", flexDirection: "row", justifyContent:"space-between", alignItems: "center"}}>
            <SearchView viewModel={this.viewModel}/>
            {selectAll}
          </div>
          <div className="results-area">
            <table id={this.props.formId + "_table"} form_id={this.props.formId} className="results-table">
              <HeaderView viewModel={this.viewModel} headers={headers}/>
              <tbody>
              {!this.viewModel.loading ? rows : loadingTr}
              </tbody>
            </table>
            <PaginationView viewModel={viewModel} formId={this.props.formId}/>
          </div>
        </>
      )
    }

    toggleButtons(formId) {
      toggleAllButtons(formId)
    }

    createRow(row) {
      let columns = this.viewModel.headers.map(header => {
        let column = <td key={header.field}>{row[header.field]}</td>
        if (header.field == 'date_ingested') {
          let value = row[header.field]
          let pos = value.indexOf("T")
          if (pos > -1) {
            value = value.substring(0, pos)
          }
          column = <td key={header.field}>{value}</td>
        }
        if (header.field == 'selection') {
          column = <td key={header.field} className="center_text"><input onClick={() => {
            this.toggleButtons(this.props.formId)
          }} type="checkbox" name="record_id[]" id="record_id_" value={row.id}/></td>
        }
        return column
      })

      return (
        <tr key={row.id}>
          {columns}
        </tr>
      )
    }
  }
)

PaginationTableView.propTypes = {
  formId: PropTypes.string,
  currentUser: PropTypes.string,
  admin: PropTypes.bool,
  role: PropTypes.string,
  section: PropTypes.string,
  filter: PropTypes.string,
  sortColumn: PropTypes.string,
  sortOrder: PropTypes.string,
  colorCode: PropTypes.string
};

export default PaginationTableView
