$(document).on('turbolinks:load', function(){

  var forms = [
    "open",
    "in_arc_review",
    "awaiting_daac_review",
    "in_daac_review",
    "provide_feedback",
    "closed",
    "finished"
  ];

  forms.forEach(function(form) {
    var formInput = 'form#' + form + ' input[name="record_id"]';
    var formInputChecked = $(formInput + ':checked').val();

    addButtonActions(form);

    if (formInputChecked) {
      enableAllButtons(form);
    } else {
      $(formInput).click(function(){
        enableAllButtons(form);
      });
    }
  });
});

function enableAllButtons(form){
  var buttons = ["select", "delete", "report", "finished", "refresh", "cmrUpdate"];

  buttons.forEach(function(button){
    var buttonId = 'form#' + form + ' .' + button + 'Button';
    $(buttonId).prop("disabled", false);
  });
}

function addButtonActions(form) {
  var formId = 'form#' + form;

  $(formId + ' .selectButton').click(function(){
    $(formId).prop("method", "get");
  });

  $(formId + ' .deleteButton').click(function(){
    $(formId).prop("method", "post");
    $(formId + ' input[name="_method"]').val("delete");
  });

  $(formId + ' .reportButton').click(function(){
    $(formId).prop("method", "get");
  });

  $(formId + ' .refreshButton').click(function(){
    showLoading("Refreshing Record");
  });
}
