var circlepath, circlerecog;

circlepath = function(points) {
  var endx, endy, rx, ry, startx, starty;
  startx = points[0][0];
  starty = points[0][1];
  endx = points[1][0];
  endy = points[1][1];
  rx = points[2][0] - startx;
  ry = points[3][1] - starty;
  return "M " + startx + "," + starty + " A " + rx + "," + ry + " 0 1,1 " + endx + "," + endy + " A " + rx + "," + ry + " 0 1,1 " + startx + "," + starty + " z";
};

circlerecog = function(points, nstrokes, cands) {
  var cline, endx, endy, maxx, maxy, minx, miny, rx, ry, startx, starty, x, y;
  x = points.map(function(e) {
    return e[0];
  });
  y = points.map(function(e) {
    return e[1];
  });
  maxx = Math.max.apply(Math, x);
  minx = Math.min.apply(Math, x);
  maxy = Math.max.apply(Math, y);
  miny = Math.min.apply(Math, y);
  if (nstrokes === 1 && maxx - minx > 50 && maxy - miny > 50 && dist(strokes[0][0], strokes[0][1]) < 40) {
    rx = (maxx - minx) / 2;
    ry = (maxy - miny) / 2;
    startx = minx - minx;
    starty = 0;
    endx = maxx - minx;
    endy = 0;
    points = [[startx, starty], [endx, endy], [startx + rx, starty - ry], [startx + rx, starty + ry]];
    cline = {
      strokes: [[[10, 10], [10, 80]], [[10, 10], [10, 80]]],
      snappoints: [[0, 0], [maxx - minx, 0], [rx, 0]],
      type: 'path',
      attr: {
        d: circlepath(points),
        stroke: '#000000',
        fill: 'none',
        'stroke-width': 5,
        points: JSON.stringify(points),
        name: 'circle'
      }
    };
    return cands.push([cline, 0]);
  }
};
