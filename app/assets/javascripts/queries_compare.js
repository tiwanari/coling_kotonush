$('.queries.compare').ready(function () {
  if (!gon.show_scatter_plot) {
    return;
  }
  $('button#toggle_scatter_plot').on('click', function(){
      $('div#scatter_plot').toggle();
      if ($.trim($(this).text()) === 'show scatter plot') {
        $(this).text('hide scatter plot');
      } else {
        $(this).text('show scatter plot');
      }
  });

  //
  // scatter plot
  //
  var width = 450;
  var height = 450;
  var x_offset = 90;
  var y_offset = 45;
  // set color originally.
  var colors = [];
  d3.select(".ranking_table") // first ranking table
    .selectAll("tbody > tr")
    .each(function() {
        colors.push(d3.select(this).style("background-color"));
    });
  var tooltip = d3.select("body")
      .append("div")
      .attr("class", "tooltip");

  function getDomainList(min, max) {
    var offset = (max - min) / 5;
    return [ min - offset, max + offset ];
  }
  var x_min = d3.min(gon.results, function(d) { return d.q1_value; });
  var x_max = d3.max(gon.results, function(d) { return d.q1_value; });
  var y_min = d3.min(gon.results, function(d) { return d.q2_value; });
  var y_max = d3.max(gon.results, function(d) { return d.q2_value; });
  var min = (x_min > y_min) ? y_min : x_min
  var max = (x_max > y_max) ? x_max : y_max
  var xScale = d3.scale.linear()
                        .domain(getDomainList(min, max))
                        .range([0, width]);
  var yScale = d3.scale.linear()
                        .domain(getDomainList(min, max))
                        .range([height, 0]);
  var populationScale = d3.scale.sqrt()
                                .domain([0, 1e9])
                                .range([1, 50]);

  var xAxis = d3.svg.axis()
                    .orient("bottom")
                    .scale(xScale);
  var yAxis = d3.svg.axis()
                    .orient("left")
                    .scale(yScale);
  var svg = d3.select("div#scatter_plot")
              .append("svg")
              .attr("width", 1.5 * width)
              .attr("height", 1.5 * height)
              .attr("font-size", "15px")
              .attr("transform", "translate("+ x_offset +","+ y_offset +")");

  // x axis
  svg.append("g")
     .attr("class", "xAxis")
     .attr("fill", "none")
     .attr("stroke", "black")
     .attr("shape-rendering", "crispEdges")
     .attr("transform", "translate("+ x_offset +","+ (height + y_offset) +")")
     .call(xAxis);
  // y axis
  svg.append("g")
     .attr("class", "yAxis")
     .attr("fill", "none")
     .attr("stroke", "black")
     .attr("shape-rendering", "crispEdges")
     .attr("transform", "translate("+ x_offset +","+ y_offset +")")
     .call(yAxis);
  // modify appearance
  svg.selectAll("g")
     .selectAll("text")
     .attr("fill", "black")
     .attr("stroke", "none");
  // label name of title
  svg.append("text")
      .attr("class", "title")
      .style("font-weight", "bold")
      .attr("text-anchor", "middle")
      .attr("x", (width / 2) + x_offset)
      .attr("y", 20)
      .text(gon.title);
  // label name of x axis
  svg.append("text")
     .attr("class", "xLabel")
     .style("font-weight", "bold")
     .attr("text-anchor", "middle")
     .attr("x", (width / 2) + x_offset)
     .attr("y", height + y_offset + 40)
     .text(gon.xLabel);
  // label name of y axis
  svg.append("text")
     .attr("class", "yLabel")
     .style("font-weight", "bold")
     .attr("text-anchor", "middle")
     .attr("x", -1 * ((height / 2 ) + y_offset))
     .attr("y", x_offset - 50)
     .attr("transform", "rotate(-90)")
     .text(gon.yLabel);

  // global value
  group = svg.append("g")
              .attr("class", "circles")
              .selectAll(".circle")
              .data(gon.results)
              .enter();
  circle = group.append("circle")
       .attr("class", "circle")
       .attr("fill", function(d, idx){
         return colors[idx];
       })
       .attr("stroke", "black")
       .call(position);

  circleText = group.append("text")
        .text(function(d) {
          return d.concept;
        })
        .attr("fill", function(d, idx){
            return colors[idx];
        })
        .call(position);

  var circleMouse = circle.call(mouseover);
  var circleTextMouse = circleText.call(mouseover);

  // set position and size of circles
  function position(p) {
      p.attr("cx", function(d){
          return xScale(d.q1_value) + x_offset;
      });
      p.attr("cy", function(d){
          return yScale(d.q2_value) + y_offset;
      });
      p.attr("x", function(d){
          return xScale(d.q1_value) + x_offset;
      });
      p.attr("y", function(d){
          return yScale(d.q2_value) + y_offset;
      });
      p.attr("r", function(d){
          return 5;
      });
  }

  // display tooltip on mouseover
  function mouseover(p) {
    p.on("mouseover", function(){
        // animation: rumble 0.12s linear infinite;
        return tooltip.style("visibility", "visible");
      })
      .on("mousemove", function(d, idx){
        return tooltip
        .style("top", (d3.event.pageY-10)+"px")
        .style("left",(d3.event.pageX+10)+"px")
        .html("<h4>"+ d.concept +"</h4>"+
              "q1_rank: "+ d.q1_rank +"<br>"+
              "q2_rank: "+ d.q2_rank +"<br>"+
              "q1_value: "+ d.q1_value +"<br>"+
              "q2_value: "+ d.q2_value)
        .style("color", colors[idx])
        .style("opacity", 0.9);
      })
      .on("mouseout", function(){
        return tooltip.style("visibility", "hidden");
      })
      .sort(order);
  }

  // decide display order to deal with circles being overlapped
  function order(a,b) {
      // bring smaller circles to the front
      return 1;
      // return b.value - a.value;
  }
});
