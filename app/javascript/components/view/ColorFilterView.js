import { observer } from "mobx-react";
import React from "react"

/**
 * This view is the color selector
 * @type {{new(*=): ColorFilterView, colorSelectRef: React.RefObject<unknown>, new<P, S>(props: Readonly<P>): ColorFilterView, new<P, S>(props: P, context?: any): ColorFilterView, prototype: ColorFilterView}}
 */
const ColorFilterView = observer(
  class ColorFilterView extends React.Component {
    constructor(props) {
      super(props)
      this.colorSelectRef = React.createRef();
    }
    render() {
      let displayStyle = this.props.section!='open'? {display: "block", marginLeft: "10px"} : {display: "none"}
      let selectedColor = this.props.viewModel.selectedColor ?? "any"
      return (
        <div style={displayStyle}>
          Filter: <select ref={this.colorSelectRef} defaultValue={selectedColor} className="single-select" onChange={() => {this.props.viewModel.filterByColor(this.colorSelectRef.current.value)}}>
            <option value="any">Any Color</option>
            <option value="red">Red</option>
            <option value="yellow">Yellow</option>
            <option value="blue">Blue</option>
            <option value="green">Green</option>
            <option value="gray">Gray</option>
            <option value="">No Color</option>
          </select>
        </div>
      );
    }
  }
)
export default ColorFilterView