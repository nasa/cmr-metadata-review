import React from "react"
import PaginationTableViewModel from "../viewmodel/PaginationTableViewModel";
import PaginationView from "./PaginationView"
import SearchView from "./SearchView"
import HeaderView from "./HeaderView"
import PropTypes from "prop-types";
import { observer } from "mobx-react"
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
    componentDidMount() {
      this.viewModel.selectPage(this.viewModel.currentPage);
    }

    render() {
      let viewModel = this.viewModel
      let headers = viewModel.headers;
      let records = viewModel.records

      return (
        <>
          <SearchView />
          {/*<div className="results-area">*/}
            <table id={this.props.formId+"_table"} form_id={this.props.formId} className="results-table">
            {/*<table className="results-table" width="500px" height="100px">*/}
              <HeaderView headers={headers} />
              {/*<tbody>*/}
                {records.map(row => { return this.createRow(row) })}
              {/*</tbody>*/}
            </table>
            <PaginationView viewModel={viewModel} />
          {/*</div>*/}
        </>
      )
    }

    toggleButtons(formId) {
      toggleAllButtons(formId)
    }

    createRow(row) {
      let columns = this.viewModel.headers.map( header => {
          let column = <td key={header.field}>{row[header.field]}</td>
          if (header.field == 'selection') {
            column = <td className="center_text"><input onClick={() => {this.toggleButtons(this.props.formId)}} type="checkbox" name="record_id[]" id="record_id_" value={row.id}/></td>
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
  section: PropTypes.string,
  filter: PropTypes.string,
  sortColumn: PropTypes.string,
  sortOrder: PropTypes.string,
  colorCode: PropTypes.string
};

export default PaginationTableView
