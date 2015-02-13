// Generated by CoffeeScript 1.7.1
var body, candsearch, downpoint, draw, draw_mode, edit_mode, figuredata, imageheight, imagewidth, kanjidata, mode, mousedown, move_mode, path, points, pointx, pointy, randomTimeout, recognition, resize, selected, selfunc, setTemplate, strokes, svg, svgPos, timeseed;

body = d3.select("body");

svg = d3.select("svg");

svgPos = null;

kanjidata = null;

figuredata = null;

window.browserWidth = function() {
  return window.innerWidth || document.body.clientWidth;
};

window.browserHeight = function() {
  return window.innerHeight || document.body.clientHeight;
};

resize = function() {
  window.drawWidth = browserWidth() * 0.69;
  window.drawHeight = browserHeight();
  svg.attr({
    width: drawWidth,
    height: drawHeight
  }).style({
    'background-color': "#ffffff"
  });
  $('#candidates').css('height', drawHeight / 2 - 30);
  return $('#suggestions').css('height', drawHeight / 2 - 30);
};

$(function() {
  resize();
  $(window).resize(resize);
  svgPos = $('svg').offset();
  draw_mode();
  $.getJSON("kanji/kanji.json", function(data) {
    return kanjidata = data;
  });
  return $.getJSON("figures.json", function(data) {
    return figuredata = data;
  });
});

mode = 'draw';

$('#draw').on('click', function() {
  return draw_mode();
});

$('#edit').on('click', function() {
  return edit_mode();
});

$('#delete').on('click', function() {
  var element, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = selected.length; _i < _len; _i++) {
    element = selected[_i];
    _results.push(element.remove());
  }
  return _results;
});

$('#dup').on('click', function() {
  var a, attr, cloned, element, length, node_name, parent, _i, _j, _len, _len1, _results;
  _results = [];
  for (_i = 0, _len = selected.length; _i < _len; _i++) {
    element = selected[_i];
    attr = element.node().attributes;
    length = attr.length;
    node_name = element.property("nodeName");
    parent = d3.select(element.node().parentNode);
    cloned = parent.append(node_name);
    for (_j = 0, _len1 = attr.length; _j < _len1; _j++) {
      a = attr[_j];
      cloned.attr(a.nodeName, a.value);
    }
    _results.push(cloned.on('mousedown', function() {
      var downpoint;
      if (mode === 'select') {
        downpoint = {
          x: d3.event.clientX - svgPos.left,
          y: d3.event.clientY - svgPos.top
        };
        return move_mode();
      }
    }));
  }
  return _results;
});

$('#test').on('click', function() {
  return svg.append("text").attr("x", 50).attr("y", 100).attr("font-size", '60px').attr("fill", "blue").text("テキストを表示できます");
});

window.template = svg.append("g");

candsearch = function() {
  var query;
  query = $('#searchtext').val();
  if (query.length > 0) {
    return bing_search(query, function(data) {
      return data.map(function(url, i) {
        var cand, img;
        cand = $("#cand" + i);
        cand.children().remove();
        img = $("<img>");
        img.attr('class', 'candimage');
        img.attr('src', url);
        return cand.append(img);
      });
    });
  }
};

$('#searchbutton').on('click', candsearch);

$('#searchtext').on('keydown', function(e) {
  if (e.keyCode === 13) {
    return candsearch();
  }
});

imagewidth = 400;

imageheight = 400;

mousedown = false;

pointx = 0;

pointy = 0;

window.line = d3.svg.line().interpolate('cardinal').x(function(d) {
  return d.x;
}).y(function(d) {
  return d.y;
});

window.drawline = function(x1, y1, x2, y2) {
  return template.append("polyline").attr({
    points: [[x1, y1], [x2, y2]],
    stroke: "#d0d0d0",
    fill: "none",
    "stroke-width": "3"
  });
};

timeseed = 0;

randomTimeout = null;

setTemplate = function(id, template) {
  d3.select("#" + id).on('click', function() {
    return template.draw();
  });
  d3.select("#" + id).on('mousedown', function() {
    mousedown = true;
    d3.event.preventDefault();
    if (randomTimeout) {
      clearTimeout(randomTimeout);
    }
    pointx = d3.event.clientX;
    pointy = d3.event.clientY;
    return srand(timeseed);
  });
  d3.select("#" + id).on('mousemove', function() {
    var i, j;
    if (mousedown) {
      d3.event.preventDefault();
      template.change(d3.event.clientX - pointx, d3.event.clientY - pointy);
      i = Math.floor((d3.event.clientX - pointx) / 10);
      j = Math.floor((d3.event.clientY - pointy) / 10);
      return srand(timeseed + i * 100 + j);
    }
  });
  return d3.select("#" + id).on('mouseup', function() {
    mousedown = false;
    return randomTimeout = setTimeout(function() {
      return timeseed = Number(new Date());
    }, 3000);
  });
};

setTemplate("template0", meshTemplate);

setTemplate("template1", parseTemplate);

setTemplate("template2", kareobanaTemplate);

setTemplate("template3", kareobanaTemplate3);

points = [];

path = null;

strokes = [];

draw = function() {
  return path.attr({
    d: line(points),
    stroke: 'blue',
    'stroke-width': 8,
    fill: "none"
  });
};

selected = [];

selfunc = function(path) {
  return function() {
    if (mode === 'select') {
      if (!mousedown) {
        return;
      }
      path.attr({
        stroke: 'yellow'
      });
      if (selected.indexOf(path) < 0) {
        return selected.push(path);
      }
    }
  };
};

downpoint = {};

draw_mode = function() {
  mode = 'draw';
  strokes = [];
  template.selectAll("*").remove();
  svg.selectAll("*").attr({
    stroke: 'blue'
  });
  svg.on('mousedown', function() {
    d3.event.preventDefault();
    mousedown = true;
    path = svg.append('path');
    downpoint = {
      x: d3.event.clientX - svgPos.left,
      y: d3.event.clientY - svgPos.top
    };
    points = [downpoint];
    path.on('mousemove', selfunc(path));
    return path.on('mousedown', function() {
      if (mode === 'select') {
        downpoint = {
          x: d3.event.clientX - svgPos.left,
          y: d3.event.clientY - svgPos.top
        };
        return move_mode();
      }
    });
  });
  svg.on('mouseup', function() {
    var uppoint;
    if (!mousedown) {
      return;
    }
    d3.event.preventDefault();
    uppoint = {
      x: d3.event.clientX - svgPos.left,
      y: d3.event.clientY - svgPos.top
    };
    points.push(uppoint);
    draw();
    mousedown = false;
    strokes.push([[downpoint.x, downpoint.y], [uppoint.x, uppoint.y]]);
    return recognition();
  });
  return svg.on('mousemove', function() {
    if (!mousedown) {
      return;
    }
    d3.event.preventDefault();
    points.push({
      x: d3.event.clientX - svgPos.left,
      y: d3.event.clientY - svgPos.top
    });
    return draw();
  });
};

edit_mode = function() {
  selected = [];
  mode = 'select';
  strokes = [];
  template.selectAll("*").remove();
  svg.on('mousedown', function() {
    d3.event.preventDefault();
    return mousedown = true;
  });
  svg.on('mousemove', function() {});
  return svg.on('mouseup', function() {
    if (!mousedown) {
      return;
    }
    d3.event.preventDefault();
    return mousedown = false;
  });
};

move_mode = function() {
  mode = 'move';
  template.selectAll("*").remove();
  svg.on('mousedown', function() {
    return mousedown = true;
  });
  svg.on('mousemove', function() {
    var element, x, y, _i, _len, _results;
    if (!mousedown) {
      return;
    }
    x = d3.event.clientX - svgPos.left;
    y = d3.event.clientY - svgPos.top;
    _results = [];
    for (_i = 0, _len = selected.length; _i < _len; _i++) {
      element = selected[_i];
      _results.push(element.attr("transform", "translate(" + (x - downpoint.x) + "," + (y - downpoint.y) + ")"));
    }
    return _results;
  });
  return svg.on('mouseup', function() {
    if (!mousedown) {
      return;
    }
    d3.event.preventDefault();
    mousedown = false;
    return edit_mode();
  });
};

recognition = function() {
  var cands, data, entry, height, kanji_strokes, kstrokes, maxx, maxy, minx, miny, normalized_strokes, nstrokes, size, stroke, totaldist, width, x0, x1, y0, y1, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _n, _o, _ref, _ref1, _ref2, _results, _results1, _results2;
  nstrokes = strokes.length;
  _ref = [1000, 1000, 0, 0], minx = _ref[0], miny = _ref[1], maxx = _ref[2], maxy = _ref[3];
  for (_i = 0, _len = strokes.length; _i < _len; _i++) {
    stroke = strokes[_i];
    minx = Math.min(minx, stroke[0][0]);
    maxx = Math.max(maxx, stroke[0][0]);
    minx = Math.min(minx, stroke[1][0]);
    maxx = Math.max(maxx, stroke[1][0]);
    miny = Math.min(miny, stroke[0][1]);
    maxy = Math.max(maxy, stroke[0][1]);
    miny = Math.min(miny, stroke[1][1]);
    maxy = Math.max(maxy, stroke[1][1]);
  }
  width = maxx - minx;
  height = maxy - miny;
  size = Math.max(width, height);
  normalized_strokes = [];
  for (_j = 0, _len1 = strokes.length; _j < _len1; _j++) {
    stroke = strokes[_j];
    x0 = (stroke[0][0] - minx) * 1000.0 / size;
    y0 = (stroke[0][1] - miny) * 1000.0 / size;
    x1 = (stroke[1][0] - minx) * 1000.0 / size;
    y1 = (stroke[1][1] - miny) * 1000.0 / size;
    normalized_strokes.push([[x0, y0], [x1, y1]]);
  }
  cands = [];
  _ref1 = [kanjidata, figuredata];
  for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
    data = _ref1[_k];
    for (_l = 0, _len3 = data.length; _l < _len3; _l++) {
      entry = data[_l];
      kstrokes = entry.strokes;
      if (kstrokes.length < nstrokes) {
        continue;
      }
      _ref2 = [1000, 1000, 0, 0], minx = _ref2[0], miny = _ref2[1], maxx = _ref2[2], maxy = _ref2[3];
      (function() {
        _results = [];
        for (var _m = 0; 0 <= nstrokes ? _m < nstrokes : _m > nstrokes; 0 <= nstrokes ? _m++ : _m--){ _results.push(_m); }
        return _results;
      }).apply(this).forEach(function(i) {
        points = kstrokes[i];
        stroke = [];
        stroke[0] = points[0];
        stroke[1] = points[points.length - 1];
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
      kanji_strokes = [];
      (function() {
        _results1 = [];
        for (var _n = 0; 0 <= nstrokes ? _n < nstrokes : _n > nstrokes; 0 <= nstrokes ? _n++ : _n--){ _results1.push(_n); }
        return _results1;
      }).apply(this).forEach(function(i) {
        points = kstrokes[i];
        stroke = [];
        stroke[0] = points[0];
        stroke[1] = points[points.length - 1];
        x0 = (stroke[0][0] - minx) * 1000.0 / size;
        y0 = (stroke[0][1] - miny) * 1000.0 / size;
        x1 = (stroke[1][0] - minx) * 1000.0 / size;
        y1 = (stroke[1][1] - miny) * 1000.0 / size;
        return kanji_strokes.push([[x0, y0], [x1, y1]]);
      });
      totaldist = 0.0;
      (function() {
        _results2 = [];
        for (var _o = 0; 0 <= nstrokes ? _o < nstrokes : _o > nstrokes; 0 <= nstrokes ? _o++ : _o--){ _results2.push(_o); }
        return _results2;
      }).apply(this).forEach(function(i) {
        var dx, dy;
        dx = kanji_strokes[i][0][0] - normalized_strokes[i][0][0];
        dy = kanji_strokes[i][0][1] - normalized_strokes[i][0][1];
        totaldist += Math.sqrt(dx * dx + dy * dy);
        dx = kanji_strokes[i][1][0] - normalized_strokes[i][1][0];
        dy = kanji_strokes[i][1][1] - normalized_strokes[i][1][1];
        return totaldist += Math.sqrt(dx * dx + dy * dy);
      });
      cands.push([entry, totaldist]);
    }
  }
  cands = cands.sort(function(a, b) {
    return a[1] - b[1];
  });
  return [0, 1, 2, 3, 4, 5].forEach(function(i) {
    var c, cand, candsvg;
    cand = cands[i][0];
    candsvg = d3.select("#cand" + i);
    candsvg.selectAll("*").remove();
    c = candsvg.append(cand.type);
    c.attr(cand.attr);
    if (cand.text) {
      c.text(cand.text);
    }
    c['ind'] = i;
    return c.on('mousedown', function() {
      var attr, copy, target, _len4, _p, _ref3;
      d3.event.preventDefault();
      strokes = [];
      target = d3.event.target;
      copy = svg.append(target.nodeName);
      _ref3 = target.attributes;
      for (_p = 0, _len4 = _ref3.length; _p < _len4; _p++) {
        attr = _ref3[_p];
        copy.attr(attr.nodeName, attr.value);
      }
      if (target.innerHTML) {
        return copy.text(target.innerHTML);
      }
    });
  });
};
