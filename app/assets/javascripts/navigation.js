$(document).on('turbolinks:load', function(){
  $("#record_refresh").click(function(){
    showLoading("Refreshing Records From CMR");
  });
});
