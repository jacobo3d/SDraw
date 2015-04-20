window.parseTemplate = {
  params: {
    center: {
      x: 800 / 2,
      y: 600 / 2
    },
    offset: {
      x: 0,
      y: 0
    }
  },
  draw: function() {
    var centerx, centery, cos, degree, i, j, radian, results, sin;
    template.selectAll("*").remove();
    results = [];
    for (i = j = 0; j <= 72; i = ++j) {
      degree = i * 5;
      radian = degree * Math.PI / 180;
      sin = Math.sin(radian);
      cos = Math.cos(radian);
      centerx = this.params.center.x + this.params.offset.x;
      centery = this.params.center.y + this.params.offset.y;
      results.push(drawline(centerx, centery, centerx + cos * 1000, centery + sin * 1000));
    }
    return results;
  },
  change: function(deltax, deltay) {
    this.params.offset.x = deltax * 4;
    this.params.offset.y = deltay * 4;
    return this.draw();
  }
};
