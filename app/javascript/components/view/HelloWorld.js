import React from "react"
import {Input} from "antd";
import 'antd/dist/antd.css'

export default class HelloWorld extends React.Component {
  componentDidMount() {
    let url = `/records/all_json`
    const requestOptions = {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    };
    fetch(url, requestOptions)
      .then(response => response.json()).then(data => {
        console.log("data is ",data)
    })
      .catch(error => {
        console.error('There was an error!', error);
      });
  }

  render() {
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