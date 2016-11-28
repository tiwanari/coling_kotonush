// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$('.welcome.index').ready(function() {
    $('#query_adjective_id').select2();
    var $query_concepts = $('#query_concepts');

    $query_concepts.select2({
      ajax: {
        url: '/welcome/list_suffixes',
        dataType: 'json',
        delay: 200,
        data: function (params) {
          return {
            q: params.term,
            pre_concepts: function () {
              pre_concepts = $("#query_concepts").select2('val');
              return pre_concepts == null ? '' : pre_concepts;
            }
          };
        },
        processResults: function (data, params) {
          return {
            results: data.items
          };
        },
        cache: true
      },
      escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
      // minimumInputLength: 1,
      // tags: true,
      templateResult: formatRepo,
      templateSelection: formatRepoSelection
    });

    // format of the displayed concepts list
    function formatRepo (repo) {
      if (repo.loading) return 'Searching...';
      var markup = "<div class='select2-result-repository clearfix'>" +
        "<div class='select2-result-repository__meta'>" +
          "<div class='select2-result-repository__title'>" + repo.entity + "</div>";
      return markup;
    }
    // format of the selected concept
    function formatRepoSelection (repo) {
      return repo.entity || repo.text;
    }

    // after deciding a concept, show the list of synonyms.
    // select the target node
    var target = $('.select2-selection__rendered')[0];
    // create an observer instance
    var observer = new MutationObserver(function(mutations) {
      $('.select2-search__field').click();
    });
    // configuration of the observer:
    var config = { attributes: true, childList: true, characterData: true };
    // pass in the target node, as well as the observer options
    observer.observe(target, config);
});
