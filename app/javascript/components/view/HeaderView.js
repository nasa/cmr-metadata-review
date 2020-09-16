import { observer } from 'mobx-react'
import React from "react"

/**
 * The view takes a TableViewModel implementation which responds wit the data necessary to render the view and
 * respond to intents.
 */

 const HeaderView = observer(
    class HeaderView extends React.Component {
        render() {
            return (
                <thead>
                    <tr>
                        {this.props.headers.map( header => (
                            <th style={{width: header.width}} key={header.field}>{header.name}</th>
                        ))}
                    </tr>
                </thead>
            );
        }
    }    
 )
 export default HeaderView
