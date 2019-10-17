import React, { Component } from "react"
import 'bootstrap/dist/css/bootstrap.min.css';
import Badge from 'react-bootstrap/Badge';

class HelloWorld extends Component {
  constructor(props) {
    super(props);
    this.state = {
      text: "Chris"
    }

    this.onClick = this.onClick.bind(this);
  }

  // Little bit of a hack to pass in a javascript function as property.
  onClick() {
    if(typeof this.props.onClick === 'string'){
      window[this.props.onClick]();
    }else{
      this.props.onClick();
    }
  }

  render() {
    return (
      <div>
        <button onClick={this.onClick}>Hello {this.state.text}! <Badge variant="light">9</Badge></button>
        <Badge variant="primary">New</Badge>
      </div>
    )
  }
}

export default HelloWorld;