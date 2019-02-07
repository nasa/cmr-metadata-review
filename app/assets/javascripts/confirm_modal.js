/* https://stackoverflow.com/questions/36110789/rails-5-how-to-use-document-ready-with-turbo-links */
$( document ).on('ready turbolinks:load', function() {
  $('.confirm-modal-button').leanModal({closeButton:".confirm-no-button,.modal-close"})
})

