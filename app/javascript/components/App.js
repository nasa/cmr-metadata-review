import React from "react"
import PropTypes from "prop-types"
import HelloWorld from "./view/HelloWorld"

class App extends React.Component {
  render () {
    return (
        <HelloWorld greeting={this.props.greeting}/>
      )
  }
}

App.propTypes = {
  greeting: PropTypes.string
};
export default App
