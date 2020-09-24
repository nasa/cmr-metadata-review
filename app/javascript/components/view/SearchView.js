import { observer } from "mobx-react";
import React from "react"

/**
 * The view takes a TableViewModel implementation which responds wit the data necessary to render the view and
 * respond to intents.
 */
const SearchView = observer(
    class SearchView extends React.Component {
      constructor(props) {
        super(props)
        this.inputRef = React.createRef();
      }

        render() {
            let styles = { margin: "5px" }
            return (
                <React.Fragment>
                    <div style={styles}>
                        <input onChange={() => {this.props.viewModel.filterByText(this.inputRef.current.value)}} ref={this.inputRef} type="text" className="eui-search-home" style={{ width: "240px", border: "solid 1px", borderColor: "lightgrey", marginRight: "4px", height: "30px" }} value={this.props.viewModel.filter} placeholder="Search" />
                        <button onClick={() => {this.props.viewModel.filterByText(this.inputRef.current.value)}} style={{ marginTop: "2px" }} type="button" className="eui-btn--sm eui-btn--green eui-search-home"><i className="eui-icon eui-fa-search"></i></button>
                    </div>
                </React.Fragment>
            );
        }
    })
export default SearchView
