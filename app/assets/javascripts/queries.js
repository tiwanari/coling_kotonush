// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$('.queries.index, .queries.compare').ready(function () {
  $("tr[data-link]").click(function() {
    window.location = $(this).data("link");
  });
});
