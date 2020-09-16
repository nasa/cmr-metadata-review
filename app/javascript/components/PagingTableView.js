import React from "react"
import PagingTableViewModel from "./viewmodel/PagingTableViewModel";
import PropTypes from "prop-types";
import { observer } from "mobx-react"

const PagingTableView = observer(
  class PagingTableView extends React.Component {
    viewModel = new PagingTableViewModel()

    render() {
      return (
        <div onClick={() => { this.viewModel.setSection("IN DAAC REVIEW") }}
             style={{border:"1px solid black", margin:"25px", padding:"10px", backgroundColor: "yellow"}}>
          Paging Table {this.viewModel.section}
        </div>
      )
    }
  }
)

PagingTableView.propTypes = {
  section: PropTypes.string,
  filter: PropTypes.string,
  sortColumn: PropTypes.string,
  sortOrder: PropTypes.string,
  colorCode: PropTypes.string
};

export default PagingTableView
