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
  var buttons = ["select", "delete", "report", "finished", "refresh"];

  buttons.forEach(function(button){
    var buttonId = 'form#' + form + ' .' + button + 'Button';
    $(buttonId).prop("disabled", false);
  });
}
