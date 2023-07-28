$( document ).on('ready turbolinks:load', function() {

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
    var formInput = 'form#' + form + ' input[name="record_id[]"]';
    var formInputChecked = $(formInput + ':checked').val();

    addButtonActions(form);

    if (formInputChecked) {
      toggleAllButtons(form);
    } else {
      $(formInput).click(function(){
        toggleAllButtons(form);
      });
    }
  });
});

function toggleAllButtons(form) {
  var formInput = 'form#' + form + ' input[name="record_id[]"]';
  var checkedFormInputs = $(formInput + ':checked')

  var buttons = formButtons();

  buttons.forEach(function(button){
    var buttonId = 'form#' + form + ' .' + button.name + 'Button';
    $(buttonId).prop("disabled", checkedFormInputs.length > 1 ? !button.multiSelect : checkedFormInputs.length === 0);
  });
}

function disableAllButtons(form) {
  var buttons = formButtons();
  buttons.forEach(function(button){
    var buttonId = 'form#' + form + ' .' + button.name + 'Button';
    $(buttonId).prop("disabled", true)
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
    $(formId).prop("method", "post");
    $(formId + ' input[name="_method"]').val("post");
  });

  $(formId + ' .refreshButton').click(function(){
    showLoading("Refreshing Record");
  });

  $(formId + ' .completeButton').click(function() {
    $(formId).prop("method", "post");
    $(formId + ' input[name="_method"]').val("post");
  });

  $(formId + ' .revertButton').click(function(){
    $(formId).prop("method", "post");
    $(formId + ' input[name="_method"]').val("revert");
  });
}

function formButtons() {
  return [
    {name: "select", multiSelect: false},
    {name: "delete", multiSelect: true},
    {name: "report", multiSelect: true},
    {name: "complete", multiSelect: true},
    {name: "finished", multiSelect: false},
    {name: "refresh", multiSelect: false},
    {name: "cmrUpdate", multiSelect: false},
    {name: "revert", multiSelect: false}
  ];
}
