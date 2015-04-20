window.kareobanaTemplate2 = {
  draw: function() {
    var i, j, p1, p2, p3, results;
    template.selectAll("*").remove();
    results = [];
    for (i = j = 0; j <= 40; i = ++j) {
      p1 = {
        x: rand(drawWidth),
        y: rand(drawHeight)
      };
      p2 = {
        x: rand(drawWidth),
        y: rand(drawHeight)
      };
      while (dist(p1, p2) < 50 || dist(p1, p2) > 150) {
        p2 = {
          x: rand(drawWidth),
          y: rand(drawHeight)
        };
      }
      p3 = {
        x: rand(drawWidth),
        y: rand(drawHeight)
      };
      while (dist(p1, p3) < 50 || dist(p1, p3) > 150 || dist(p2, p3) < 50 || dist(p2, p3) > 150) {
        p3 = {
          x: rand(drawWidth),
          y: rand(drawHeight)
        };
      }
      results.push(template.append('path').attr({
        stroke: '#d0d0d0',
        'stroke-width': 3,
        fill: "none",
        d: line([p1, p2, p3])
      }));
    }
    return results;
  },
  change: function(deltax, deltay) {
    return this.draw();
  }
};
