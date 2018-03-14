$(document).on('turbolinks:load', function(){

  var forms   = ["closed", "finished"];

  forms.forEach(function(form) {
    var formInput = 'form#' + form + ' input[name="concept_id_revision"]';
    var formInputChecked = $(formInput + ':checked').val();

    if (formInputChecked) {
      enableAllButtons(form);
    } else {
      $(formInput).click(function(){
        enableAllButtons(form)
      });
    }
  });
});

function enableAllButtons(form){
  var buttons = ["select", "delete", "report", "finished"];

  buttons.forEach(function(button){
    var buttonId = 'form#' + form + ' .' + button + 'Button';
    $(buttonId).prop("disabled", false);
  });
}
