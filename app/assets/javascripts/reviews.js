function feedbackClickHandler(cellId, checkId, pId, iconId, daac_curator) {
    if (!daac_curator) {
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
