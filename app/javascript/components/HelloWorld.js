import React from "react"
import PropTypes from "prop-types"
import { Input, AutoComplete } from 'antd';
import 'antd/dist/antd.css'

class HelloWorld extends React.Component {
  render () {
    return (
      <React.Fragment>
        <div>
          Greeting: {this.props.greeting}
        </div>
        <Input.Search style={{padding:"10px", width:"400px"}} size="medium" placeholder="Search for..." enterButton/>
      </React.Fragment>
    );
  }
}

HelloWorld.propTypes = {
  greeting: PropTypes.string
};
export default HelloWorld
