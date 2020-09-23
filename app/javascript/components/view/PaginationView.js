import React from "react"
import PaginationItemView from './PaginationItemView';
import { observer } from 'mobx-react'

/**
 * The view takes a PaginationTableViewModel implementation which responds with the data necessary to render the view and
 * respond to intents.
 */

const PaginationView = observer(
    class PaginationView extends React.Component {
        render() {
            let viewModel = this.props.viewModel;
            let totalItems = viewModel.totalItems;
            let itemsPerPage = viewModel.itemsPerPage;

            let pages = []
            if (totalItems > 0 && itemsPerPage > 0) {
                let currentPage = viewModel.currentPage;
                let totalPages = viewModel.totalPages;

                var [startPage, endPage] = this.getStartEndPage(currentPage, totalPages);

                pages = [];
                for (let i = startPage; i <= endPage; i++) {
                    pages.push(<PaginationItemView formId={this.props.formId} active={currentPage === i} viewModel={viewModel} key={i}>{i}</PaginationItemView>)
                }
            }
            return (
                <div style={{display:"flex", flexDirection:"row", alignItems: "center"}}>
                  <div style={{marginRight:"10px"}}>Total: {totalItems}</div>
                    <ul className="eui-pagination">
                        <PaginationItemView formId={this.props.formId} name="First" viewModel={viewModel} />
                        <PaginationItemView formId={this.props.formId} name="Prev" viewModel={viewModel} />
                        {pages}
                        <PaginationItemView formId={this.props.formId} name="Next" viewModel={viewModel} />
                        <PaginationItemView formId={this.props.formId} name="Last" viewModel={viewModel} />
                    </ul>
                </div>
            );
        }

        // https://jasonwatmore.com/post/2017/03/14/react-pagination-example-with-logic-like-google
        getStartEndPage(currentPage, totalPages) {
            let startPage, endPage;

            if (totalPages <= 10) {
                startPage = 1;
                endPage = totalPages;
            } else {
                if (currentPage <= 6) {
                    startPage = 1;
                    endPage = 10;
                } else if (currentPage + 4 >= totalPages) {
                    startPage = totalPages - 9;
                    endPage = totalPages;
                } else {
                    startPage = currentPage - 5;
                    endPage = currentPage + 4;
                }
            }
            return [startPage, endPage];
        }

    }
)
export default PaginationView
