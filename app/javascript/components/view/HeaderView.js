import { observer } from 'mobx-react'
import React from "react"

/**
 * The view takes a TableViewModel implementation which responds wit the data necessary to render the view and
 * respond to intents.
 */

 const HeaderView = observer(
    class HeaderView extends React.Component {
      constructor(props) {
        super(props);
      }

      triangle(header) {
        if (header.order) {
          return (
            <span>{header.order === "asc" ? "▲" : "▼"}</span>
          )
        } else {
          return (<span style={{fontSize:"20px", opacity: 0.5, paddingTop:"20px"}}>{"↕"}</span>)
        }
      }

      toggleTriangle(header) {
        header.order = header.order === "asc" ? "desc" : "asc"
      }

      render() {
        return (
          <thead>
          <tr>
            {this.props.headers.map(header => (
              <th style={{width: header.width}} key={header.field}
                  onClick={() => {
                    if (header.sortable) {
                      this.toggleTriangle(header)
                      this.props.viewModel.sortBy(header.field, header.order)
                    }
                  }}>
                <div style={{display:"flex", flex:1, flexDirection: "row", justifyContent: "space-between", alignItems: "center"}}>
                  <div>{header.name}</div>
                  <div>{header.sortable ? this.triangle(header) : null}</div>
                </div>
              </th>
            ))}
          </tr>
          </thead>
        );
      }
    }
 )
 export default HeaderView
