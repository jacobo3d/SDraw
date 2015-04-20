window.kareobanaTemplate3 = {
  draw: function() {
    var i, j, p1, p2, results;
    template.selectAll("*").remove();
    results = [];
    for (i = j = 0; j <= 200; i = ++j) {
      p1 = [rand(drawWidth), rand(drawHeight)];
      p2 = [rand(drawWidth), rand(drawHeight)];
      while (dist(p1, p2) < 50 || dist(p1, p2) > 120) {
        p2 = [rand(drawWidth), rand(drawHeight)];
      }
      results.push(template.append('path').attr({
        stroke: '#d0d0d0',
        'stroke-width': 3,
        fill: "none",
        d: line([p1, p2])
      }));
    }
    return results;
  },
  change: function(deltax, deltay) {
    return this.draw();
  }
};
