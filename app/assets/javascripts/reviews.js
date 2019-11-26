function feedbackClickHandler(e) {
  title = $(e).attr("column_value");
  cellId = "feedback_cell_" + title;
  checkId = "feedback_check_" + title;
  pId = "feedback_text_" + title;
  iconId = "feedback_icon_" + title;
  daac_curator = $(e).attr("daac_curator");

  if (daac_curator == "false") {
    return;
  }

  activateSaveButton();
  var checkbox = document.getElementById(checkId);
  checkbox.checked = !checkbox.checked;
  var iconClass = checkbox.checked ? 'eui-icon eui-check-o' : 'fa fa-comments';
  document.getElementById(iconId).className = iconClass;

  var cellEl = document.getElementById(cellId), cellClass = "review-toggle__cell";
  var textEl = document.getElementById(pId), textClass = "review-toggle__text";

  if (checkbox.checked) {
    cellEl.classList.add(cellClass);
    textEl.classList.add(textClass);
  } else {
    cellEl.classList.remove(cellClass);
    textEl.classList.remove(textClass);
  }
}
