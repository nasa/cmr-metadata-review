function showLoading(message) {
  var processingModal = document.createElement("p");
  processingModal.innerHTML = message;
  processingModal.innerHTML += "<br><i class=\"fa fa\-refresh fa\-spin fa\-3x fa\-fw\"><\/i>";
  processingModal.className += " processing_modal";
  document.body.append(processingModal);

  var processingModalCover = document.createElement("div");
  processingModalCover.className += " processing_modal_cover";
  document.body.append(processingModalCover);
}