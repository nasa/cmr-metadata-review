$( document ).on('ready turbolinks:load', function() {
  var revisionIdElement;

  $(".associated_granule_value").change(function (event) {
    var target = event.target;
    var revision_id = target.getAttribute("revision_id");
    var form_id = "#form-" + revision_id;
    $(form_id).submit()
  });

  $(".granule_revision")
    .mouseover(function (event) {
      $(event.target).addClass("mouse_over_draggable");
    })
    .mouseout(function (event) {
      $(event.target).removeClass("mouse_over_draggable");
    });

  $(".granule_revision").draggable({
    start: function (event, ui) {
      revisionIdElement = event.target;
    },
    stop: function (event, ui) {
      revisionIdElement.style.top = 0;
      revisionIdElement.style.left = 0;
    }
  });

  $(".collection_revision").droppable({
    over: function (event, ui) {
      $(event.target).find("th").addClass("revision_id_over_collection");
    },
    out: function (event, ui) {
      $(event.target).find("th").removeClass("revision_id_over_collection");
    },
    drop: function (event, ui) {
      var granuleId = revisionIdElement.getAttribute("granule_option_id");
      $(event.target).find("h4 select").val(granuleId).change();
      revisionIdElement.style.top = 0;
      revisionIdElement.style.left = 0;
    }
  });

});
