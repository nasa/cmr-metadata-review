import React from "react"
import PropTypes from "prop-types";
import {observer} from "mobx-react"
import { TreeTable, TreeState } from 'cp-react-tree-table';
import "./metadata.css"
import metadata from "./metadata.js"
import color_codes from "./color_code.png"

const MetadataView = observer(

  class MetadataView extends React.Component {

    constructor(props) {
      super(props)

      this.state = {
        treeValue: TreeState.expandAll(TreeState.create(genData()))
        // treeValue: TreeState.create(genData())
      };
    }

    renderFieldCell = (row) => {
      return (
        <div style={{  width: "500px", display: "flex", flexDirection: "row", paddingLeft: (row.metadata.depth * 15) + 'px'}}
             >

          {(row.metadata.hasChildren)
            ? (
              <button className="toggle-button" onClick={row.toggleChildren}></button>
            )
            : ''
          }

          <span>{row.data.field}</span>
        </div>
      );
    }

    renderRequiredBySchemaCell = (row) => {
      return (
        <span className="required-by-schema-cell">{row.data.requiredBySchema}</span>
      );
    }

    renderFlaggedByScriptCell = (row) => {
      return (
        <span className="flagged-by-script-cell">{row.data.flaggedByScript}</span>
      );
    }

    renderScriptResultCell = (row) => {
      return (
        <span className="script-result-cell">{row.data.scriptResult}</span>
      );
    }

    renderCurrentValueCell = (row) => {
      return (
        <span className="current-value-cell" title={row.data.currentValue}>{row.data.currentValue}</span>
      );
    }

    renderRecommendationCell = (row) => {
      return (
        <span className="recommendation-cell">{row.data.recommendation}</span>
      );
    }

    renderSecondOpinionCell = (row) => {
      return (
        <span className="second-opinion-cell">{row.data.secondOpinion}</span>
      );
    }

    renderColorCodeCell = (row) => {
      return (
        row.data.currentValue ? <img src={color_codes} border="0px"/> : null
      );
    }

    renderDiscussionJustificationCell = (row) => {
      return (
        <span className="discussion-justification-cell">{row.data.discussionJustification}</span>
      );
    }

    handleOnChange = (newValue) => {
      this.setState({ treeValue: newValue });
    }

    render() {
      const { treeValue } = this.state;
      return (
        <div className="metadata_view">
          <TreeTable height="2000"
            value={treeValue}
            onChange={this.handleOnChange}>
            <TreeTable.Column basis="15%"
                              renderCell={this.renderFieldCell}
                              renderHeaderCell={() => <span>FIELD</span>}/>
            <TreeTable.Column basis="20%"
              renderCell={this.renderCurrentValueCell}
              renderHeaderCell={() => <span>CURRENT VALUE</span>}/>
            <TreeTable.Column basis="18%"
              renderCell={this.renderColorCodeCell}
              renderHeaderCell={() => <span>COLOR CODE</span>}/>
            <TreeTable.Column basis="6%"
              renderCell={this.renderRequiredBySchemaCell}
              renderHeaderCell={() => <span>REQUIRED</span>}/>
            <TreeTable.Column basis="4%"
              renderCell={this.renderFlaggedByScriptCell}
              renderHeaderCell={() => <span>FLAG</span>}/>
            <TreeTable.Column basis="4%"
              renderCell={this.renderScriptResultCell}
              renderHeaderCell={() => <span>SCRIPT</span>}/>
            <TreeTable.Column basis="6%"
              renderCell={this.renderRecommendationCell}
              renderHeaderCell={() => <span>RECOM- DATION</span>}/>
            <TreeTable.Column basis="5%"
              renderCell={this.renderSecondOpinionCell}
              renderHeaderCell={() => <span>2ND OPINION</span>}/>
            <TreeTable.Column basis="9%"
              renderCell={this.renderDiscussionJustificationCell}
              renderHeaderCell={() => <span>DISCUSSION JUSTIFICATION</span>}/>

          </TreeTable>

        </div>
      )
    }
  }
)

function traverse(o, path, key, v) {
    var type = typeof o
    if (Array.isArray(o)) {
      for (let item of o) {
        let data = {data: { field: key, requiredBySchema: "", flaggedByScript: false, scriptResult: "OK",
            currentValue: "", recommendation: "", secondOpinion: false, colorCode: "", discussionJustification: "" },
          height: 32, children: []
        }
        v.children.push(data)
        traverse(item, path, key, data)
      }
      return
    }
    if (type == "object") {
        for (let key in o) {
          let data = {data: { field: key, requiredBySchema: "", flaggedByScript: false, scriptResult: "OK",
              currentValue: "", recommendation: "", secondOpinion: false, colorCode: "", discussionJustification: "" },
            height: 32, children: []
          }
          v.children.push(data)
          traverse(o[key], path+"/"+key, key, data)
        }
    } else {
      console.log("pushing "+path)
      v.data.currentValue = o
      v.data.recommendation = "📎"
      v.data.discussionJustification = "📎"
      v.data.requiredBySchema = "✔️"
      v.height = (32*(Math.ceil(o.length/60)))
    }
}

function genData() {
  let root = {data: { field: "Metadata", requiredBySchema: "", flaggedByScript: false, scriptResult: "OK",
      currentValue: "", recommendation: "", secondOpinion: false, colorCode: "", discussionJustification: "" },
    children: [],
    height: 32,
  }

  traverse(metadata, "", "", root)
  return [root]
  // console.log("v=",root)
  // return [
  //   {
  //     data: { field: "ShortName", requiredBySchema: "true", flaggedByScript: false, scriptResult: "OK",
  //       currentValue: "prove_veg_refi_668", recommendation: "", secondOpinion: false, colorCode: "", discussionJustification: "" },
  //     height: 32,
  //   },
  // ];
}

MetadataView.propTypes = {
  currentUser: PropTypes.string,
  admin: PropTypes.bool,
  role: PropTypes.string,
};

export default MetadataView
