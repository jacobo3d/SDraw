var recognize,
  slice = [].slice;

$(function() {
  $.getJSON("kanji/kanji.json", function(data) {
    return window.kanjidata = data;
  });
  return $.getJSON("data/figures.json", function(data) {
    return window.figuredata = data;
  });
});

recognize = function() {
  var cands, data, entry, height, hline, j, k, kanji_strokes, kstrokes, l, len, len1, len2, len3, m, maxx, maxy, minx, miny, n, normalized_strokes, nstrokes, o, p, points, ref, ref1, register, results, results1, results2, size, stroke, strokedata, strokeheight, strokes, strokewidth, totaldist, vline, width, x0, x1, y0, y1;
  strokes = arguments[0], points = arguments[1], strokedata = 3 <= arguments.length ? slice.call(arguments, 2) : [];
  nstrokes = strokes.length;
  ref = [1000, 1000, 0, 0], minx = ref[0], miny = ref[1], maxx = ref[2], maxy = ref[3];
  for (j = 0, len = strokes.length; j < len; j++) {
    stroke = strokes[j];
    minx = Math.min(minx, stroke[0][0]);
    maxx = Math.max(maxx, stroke[0][0]);
    minx = Math.min(minx, stroke[1][0]);
    maxx = Math.max(maxx, stroke[1][0]);
    miny = Math.min(miny, stroke[0][1]);
    maxy = Math.max(maxy, stroke[0][1]);
    miny = Math.min(miny, stroke[1][1]);
    maxy = Math.max(maxy, stroke[1][1]);
  }
  strokewidth = maxx - minx;
  strokeheight = maxy - miny;
  size = Math.max(strokewidth, strokeheight);
  normalized_strokes = [];
  for (k = 0, len1 = strokes.length; k < len1; k++) {
    stroke = strokes[k];
    x0 = (stroke[0][0] - minx) * 1000.0 / size;
    y0 = (stroke[0][1] - miny) * 1000.0 / size;
    x1 = (stroke[1][0] - minx) * 1000.0 / size;
    y1 = (stroke[1][1] - miny) * 1000.0 / size;
    normalized_strokes.push([[x0, y0], [x1, y1]]);
  }
  cands = [];
  if (nstrokes === 1 && strokewidth > 100 && strokeheight / strokewidth < 0.1) {
    hline = {
      strokes: [[[0, 0], [80, 0]], [[0, 0], [80, 0]]],
      snappoints: [[0, 0], [strokewidth, 0]],
      type: 'path',
      attr: {
        d: "M10,40L" + strokewidth + ",40",
        stroke: '#000000',
        fill: 'none',
        'stroke-width': 5,
        name: 'lines',
        points: JSON.stringify([[0, 0], [strokewidth, 0]])
      }
    };
    cands.push([hline, 0]);
    register = {
      strokes: [[[0, 40], [15, 40]], [[15, 40], [20, 20]], [[20, 20], [30, 60]], [[30, 60], [40, 20]], [[40, 20], [50, 60]], [[50, 60], [60, 20]], [[60, 20], [70, 60]], [[70, 60], [75, 40]], [[75, 40], [90, 40]]],
      snappoints: [[0, 40], [90, 40]],
      type: 'path',
      attr: {
        d: "M0,40L15,40L20,20L30,60L40,20L50,60L60,20L70,60L75,40L90,40",
        stroke: '#000000',
        fill: 'none',
        'stroke-width': 2,
        name: 'polyline',
        points: JSON.stringify([[0, 40], [(15 * strokewidth) / 90, 40], [(20 * strokewidth) / 90, 20], [(30 * strokewidth) / 90, 60], [(40 * strokewidth) / 90, 20], [(50 * strokewidth) / 90, 60], [(60 * strokewidth) / 90, 20], [(70 * strokewidth) / 90, 60], [(75 * strokewidth) / 90, 40], [(90 * strokewidth) / 90, 40]])
      }
    };
    cands.push([register, 1]);
  }
  if (nstrokes === 1 && strokeheight > 100 && strokewidth / strokeheight < 0.1) {
    vline = {
      strokes: [[[10, 10], [10, 80]], [[10, 10], [10, 80]]],
      snappoints: [[0, 0], [0, strokeheight]],
      type: 'path',
      attr: {
        d: "M40,10L40," + strokeheight,
        stroke: '#000000',
        fill: 'none',
        'stroke-width': 2,
        name: 'lines',
        points: JSON.stringify([[0, 0], [0, strokeheight]])
      }
    };
    cands.push([vline, 0]);
    register = {
      strokes: [[[40, 0], [40, 15]], [[40, 15], [60, 20]], [[60, 20], [20, 30]], [[20, 30], [60, 40]], [[60, 40], [20, 50]], [[20, 50], [60, 60]], [[60, 60], [20, 70]], [[20, 70], [40, 75]], [[40, 75], [40, 90]]],
      snappoints: [[40, 0], [40, strokeheight]],
      type: 'path',
      attr: {
        d: "M40,0L40,15L60,20L20,30L60,40L20,50L60,60L20,70L40,75L40,90",
        stroke: '#000000',
        fill: 'none',
        'stroke-width': 2,
        name: 'polyline',
        points: JSON.stringify([[40, (strokeheight * 0) / 90], [40, (strokeheight * 15) / 90], [60, (strokeheight * 20) / 90], [20, (strokeheight * 30) / 90], [60, (strokeheight * 40) / 90], [20, (strokeheight * 50) / 90], [60, (strokeheight * 60) / 90], [20, (strokeheight * 70) / 90], [40, (strokeheight * 75) / 90], [40, (strokeheight * 90) / 90]])
      }
    };
    cands.push([register, 1]);
  }
  circlerecog(points, nstrokes, cands);
  for (l = 0, len2 = strokedata.length; l < len2; l++) {
    data = strokedata[l];
    for (m = 0, len3 = data.length; m < len3; m++) {
      entry = data[m];
      kstrokes = entry.strokes;
      if (kstrokes.length < nstrokes) {
        continue;
      }
      ref1 = [1000, 1000, 0, 0], minx = ref1[0], miny = ref1[1], maxx = ref1[2], maxy = ref1[3];
      (function() {
        results = [];
        for (var n = 0; 0 <= nstrokes ? n < nstrokes : n > nstrokes; 0 <= nstrokes ? n++ : n--){ results.push(n); }
        return results;
      }).apply(this).forEach(function(i) {
        var ppoints;
        ppoints = kstrokes[i];
        stroke = [];
        stroke[0] = ppoints[0];
        stroke[1] = ppoints[ppoints.length - 1];
        minx = Math.min(minx, stroke[0][0]);
        maxx = Math.max(maxx, stroke[0][0]);
        minx = Math.min(minx, stroke[1][0]);
        maxx = Math.max(maxx, stroke[1][0]);
        miny = Math.min(miny, stroke[0][1]);
        maxy = Math.max(maxy, stroke[0][1]);
        miny = Math.min(miny, stroke[1][1]);
        return maxy = Math.max(maxy, stroke[1][1]);
      });
      width = maxx - minx;
      height = maxy - miny;
      size = Math.max(width, height);
      if (entry.type === 'path') {
        entry.scalex = strokewidth / width;
        entry.scaley = strokeheight / height;
      } else {
        entry.scalex = 1;
        entry.scaley = 1;
      }
      strokes = [];
      kanji_strokes = [];
      (function() {
        results1 = [];
        for (var o = 0; 0 <= nstrokes ? o < nstrokes : o > nstrokes; 0 <= nstrokes ? o++ : o--){ results1.push(o); }
        return results1;
      }).apply(this).forEach(function(i) {
        var ppoints;
        ppoints = kstrokes[i];
        stroke = [];
        stroke[0] = ppoints[0];
        stroke[1] = ppoints[ppoints.length - 1];
        x0 = (stroke[0][0] - minx) * 1000.0 / size;
        y0 = (stroke[0][1] - miny) * 1000.0 / size;
        x1 = (stroke[1][0] - minx) * 1000.0 / size;
        y1 = (stroke[1][1] - miny) * 1000.0 / size;
        return kanji_strokes.push([[x0, y0], [x1, y1]]);
      });
      totaldist = 0.0;
      (function() {
        results2 = [];
        for (var p = 0; 0 <= nstrokes ? p < nstrokes : p > nstrokes; 0 <= nstrokes ? p++ : p--){ results2.push(p); }
        return results2;
      }).apply(this).forEach(function(i) {
        var dx, dy;
        dx = kanji_strokes[i][0][0] - normalized_strokes[i][0][0];
        dy = kanji_strokes[i][0][1] - normalized_strokes[i][0][1];
        totaldist += hypot(dx, dy);
        dx = kanji_strokes[i][1][0] - normalized_strokes[i][1][0];
        dy = kanji_strokes[i][1][1] - normalized_strokes[i][1][1];
        return totaldist += hypot(dx, dy);
      });
      cands.push([entry, totaldist]);
    }
  }
  return cands.sort(function(a, b) {
    return a[1] - b[1];
  }).map(function(e) {
    return e[0];
  });
};
