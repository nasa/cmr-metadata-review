$(document).on('turbolinks:load', function(){

  var forms   = ["closed", "finished"];
  var buttons = ["select", "delete", "report", "finished"];

  forms.forEach(function(element) {
    var formInput = 'form#' + element + ' input[name="concept_id_revision"]';
    $(formInput).click(function() {
      buttons.forEach(function(button) {
        var buttonId = 'form#' + element + ' .' + button + 'Button';
        $(buttonId).prop("disabled", false);
      });
    });
  });
});
