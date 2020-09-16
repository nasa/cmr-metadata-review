import React from "react"

import { observer } from 'mobx-react'

/**
 * The view takes a TableViewModel implementation which responds wit the data necessary to render the view and
 * respond to intents.
 */

const PaginationItemView = observer(
    class PaginationItemView extends React.Component {
        render() {
            let viewModel = this.props.viewModel;
            let name = this.props.name;
            let value = this.props.children || this.props.name;

          let style = {
            marginRight: "3px",
            color:"white",
            textShadow:"1px 1px rgba(50, 50, 50, 0.1)",
            backgroundColor: "#95a5a6",
            padding: "5px 10px",
            borderRadius: "2px",
            transition: "background-color 0.2s ease-in-out"}

          if (name === 'First' || name === 'Last') {
                var pageToSelect = 1;
                if (name === 'Last') {
                    pageToSelect = viewModel.totalPages;
                }
                return (
                    <li className="paginationItem" style={style}><a onClick={() => { viewModel.selectPage(pageToSelect) }}>{name}</a></li>
                );
            }
            if (name === 'Prev' || name === 'Next') {
                let pageToSelect = Math.max(1, viewModel.currentPage - 1);;
                let icon = "eui-icon eui-fa-chevron-circle-left";
                if (name === 'Next') {
                    icon = "eui-icon eui-fa-chevron-circle-right";
                    pageToSelect = Math.min(viewModel.totalPages, viewModel.currentPage + 1);
                }                
                return (
                    <li className="paginationItem" style={style}><a onClick={() => { viewModel.selectPage(pageToSelect) }}><i className={icon}></i></a></li>
                )
            }
          let lineItem = <li key={value} className="paginationItem" style={style}><a onClick={() => { viewModel.selectPage(value) }}> {this.props.children}</a></li>
            if (this.props.active) {
              style.backgroundColor = "#2c3e50"
                lineItem = <li key={value} className="paginationItem" style={style}><a onClick={() => { viewModel.selectPage(value) }} className="active-page">{this.props.children}</a></li>
            }
            return (
                <React.Fragment>
                    {lineItem}
                </React.Fragment>
            );
        }
    })
export default PaginationItemView


