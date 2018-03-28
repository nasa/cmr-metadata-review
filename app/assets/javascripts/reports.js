$(document).on('turbolinks:load', function(){
  $("#pdf_button").click(function(){
    window.print();
  });
});
