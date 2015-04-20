window.meshTemplate = {
  params: {
    meshsize: 40,
    offset: {
      x: 0,
      y: 0
    }
  },
  draw: function() {
    var i, j, k, ref, ref1, results, xsize, ysize;
    template.selectAll("*").remove();
    xsize = this.params.meshsize + this.params.offset.x;
    if (xsize > 1) {
      for (i = j = 0, ref = drawWidth / (this.params.meshsize + this.params.offset.x); 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        drawline(i * (this.params.meshsize + this.params.offset.x), 0, i * (this.params.meshsize + this.params.offset.x), drawHeight);
      }
    }
    ysize = this.params.meshsize + this.params.offset.y;
    if (ysize > 1) {
      results = [];
      for (i = k = 0, ref1 = drawHeight / (this.params.meshsize + this.params.offset.y); 0 <= ref1 ? k <= ref1 : k >= ref1; i = 0 <= ref1 ? ++k : --k) {
        results.push(drawline(0, i * (this.params.meshsize + this.params.offset.y), drawWidth, i * (this.params.meshsize + this.params.offset.y)));
      }
      return results;
    }
  },
  change: function(deltax, deltay) {
    this.params.offset.x = deltax;
    this.params.offset.y = deltay;
    return this.draw();
  }
};
