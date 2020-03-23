$( document ).on('ready turbolinks:load', function() {
  $("#pdf_button").click(function(){
    window.print();
  });
});
