window.kareobanaTemplate = {
  draw: function() {
    var drawpoints, i, p1, p2, p3, ref, results, x, y;
    template.selectAll("*").remove();
    results = [];
    for (x = i = 0, ref = drawWidth / 80; 0 <= ref ? i <= ref : i >= ref; x = 0 <= ref ? ++i : --i) {
      results.push((function() {
        var j, ref1, results1;
        results1 = [];
        for (y = j = 0, ref1 = drawHeight / 80; 0 <= ref1 ? j <= ref1 : j >= ref1; y = 0 <= ref1 ? ++j : --j) {
          p2 = [x * 80, y * 80];
          p1 = [rand(drawWidth), rand(drawHeight)];
          while (dist(p1, p2) < 50 || dist(p1, p2) > 150) {
            p1 = [rand(drawWidth), rand(drawHeight)];
          }
          p3 = [rand(drawWidth), rand(drawHeight)];
          while (dist(p3, p2) < 50 || dist(p3, p2) > 150 || dist(p1, p3) < 50 || dist(p1, p3) > 150) {
            p3 = [rand(drawWidth), rand(drawHeight)];
          }
          drawpoints = [p1, p2, p3];
          results1.push(template.append('path').attr({
            stroke: '#d0d0d0',
            'stroke-width': 3,
            fill: "none",
            d: line(drawpoints)
          }));
        }
        return results1;
      })());
    }
    return results;
  },
  change: function(deltax, deltay) {
    return this.draw();
  }
};
