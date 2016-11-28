$('.welcome.query, .queries.compare').ready(function () {
  // toggle button
  $('button#toggle_reasons').on('click', function(){
      $('div#result_reasons').toggle();
      if ($.trim($(this).text()) === 'show result reasons') {
        $(this).text('hide result reasons');
        $('.ranking_table tr').attr('style', 'cursor: pointer;');
      } else {
        $(this).text('show result reasons');
        $('.ranking_table tr').attr('style', 'cursor: auto;');
      }
  });
  // update table of result reasons
  $("tr[data-id]").click(function() {
    var id = $(this).data("id");
    var reasons_hash = gon.reasons_hash[id];
    var types = ['co_occurrences', 'dependencies', 'similia', 'comparatives'];
    var pos_negs = ['pos', 'neg'];
    $.each(types,function(i, type){
      $.each(pos_negs,function(j, pos_neg){
        $("td."+ type +"_"+ pos_neg +"_count").html(reasons_hash[type][pos_neg]['count']);
        $("td."+ type +"_"+ pos_neg +"_sentences").html(reasons_hash[type][pos_neg]['sentences']);
      });
    });
  });
});
