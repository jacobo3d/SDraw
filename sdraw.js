// Generated by CoffeeScript 1.7.1
var bgrect, body, candsearch, clickedElement, clone, downpoint, downtime, drawPath, draw_mode, duplicated, edit_mode, elements, linecolor, linewidth, mode, modetimeout, moved, movepoint, moving, path, points, randomTimeout, recognition, resettimeout, resize, selected, selfunc, setTemplate, setfunc, snapdx, snapdy, strokes, svg, timeseed, totaldist,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

body = d3.select("body");

svg = d3.select("svg");

bgrect = svg.append('rect');

downpoint = null;

movepoint = null;

elements = [];

selected = [];

points = [];

strokes = [];

moving = false;

moved = null;

duplicated = false;

linewidth = 10;

linecolor = '#000000';

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
  bgrect.attr({
    'x': 0,
    'y': 0,
    'width': window.drawWidth,
    'height': window.drawHeight,
    'fill': '#d0d0d0',
    'stroke': '#ffffff',
    'stroke-width': 0
  });
  $('#candidates').css('height', drawHeight / 2 - 30);
  return $('#suggestions').css('height', drawHeight / 2 - 30);
};

$(function() {
  resize();
  $(window).resize(resize);
  return draw_mode();
});

mode = 'draw';

$('#edit').on('click', function() {
  return edit_mode();
});

$('#delete').on('click', function() {
  var element, newelements, query, _i, _j, _len, _len1;
  if (selected.length === 0) {
    query = $('#searchtext').val();
    return $('#searchtext').val(query.slice(0, -1));
  } else {
    newelements = [];
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      element = elements[_i];
      if (__indexOf.call(selected, element) < 0) {
        newelements.push(element);
      }
    }
    for (_j = 0, _len1 = selected.length; _j < _len1; _j++) {
      element = selected[_j];
      element.remove();
    }
    selected = [];
    elements = newelements;
    if (elements.length === 0) {
      return draw_mode();
    }
  }
});

$('#dup').on('click', function() {
  if (moved && duplicated) {
    clone(moved[0] + 30, moved[1] + 30);
  } else {
    clone(30, 30);
  }
  return duplicated = true;
});

$('#line1').on('click', function() {
  return linewidth = 3;
});

$('#line2').on('click', function() {
  return linewidth = 10;
});

$('#line3').on('click', function() {
  return linewidth = 25;
});

$('#color1').on('click', function() {
  return linecolor = '#ffffff';
});

$('#color2').on('click', function() {
  return linecolor = '#808080';
});

$('#color3').on('click', function() {
  return linecolor = '#000000';
});

clone = function(dx, dy) {
  var attr, cloned, e, element, newselected, nodeName, parent, snappoint, _i, _j, _k, _len, _len1, _len2, _ref;
  newselected = [];
  for (_i = 0, _len = selected.length; _i < _len; _i++) {
    element = selected[_i];
    attr = element.node().attributes;
    nodeName = element.property("nodeName");
    parent = d3.select(element.node().parentNode);
    cloned = parent.append(nodeName);
    for (_j = 0, _len1 = attr.length; _j < _len1; _j++) {
      e = attr[_j];
      cloned.attr(e.nodeName, e.value);
    }
    element.attr('stroke', linecolor);
    cloned.x = element.x + dx;
    cloned.y = element.y + dy;
    if (element.snappoints) {
      cloned.snappoints = element.snappoints.map(function(point) {
        return point.concat();
      });
      _ref = cloned.snappoints;
      for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
        snappoint = _ref[_k];
        snappoint[0] += dx;
        snappoint[1] += dy;
      }
    }
    cloned.attr("transform", "translate(" + cloned.x + "," + cloned.y + ")");
    if (nodeName === 'text') {
      cloned.text(element.text());
    }
    cloned.on('mousedown', function() {
      var clickedElement;
      if (mode !== 'edit') {
        return;
      }
      clickedElement = setfunc(cloned);
      downpoint = d3.mouse(this);
      return moving = true;
    });
    cloned.on('mousemove', selfunc(cloned));
    newselected.push(cloned);
    elements.push(cloned);
  }
  return selected = newselected;
};

$('#repeat').on('click', function() {
  if (moved) {
    return clone(moved[0] + 30, moved[1] + 30);
  }
});

$('#selectall').on('click', function() {
  edit_mode();
  svg.selectAll("*").attr("stroke", "yellow");
  return selected = elements;
});

candsearch = function() {
  var query;
  query = $('#searchtext').val();
  if (query.length > 0) {
    return bing_search(query, function(data) {
      return data.map(function(url, i) {
        var cand, candimage;
        cand = d3.select("#cand" + i);
        cand.selectAll('*').remove();
        candimage = cand.append('image').attr({
          'xlink:href': url,
          x: 0,
          y: 0,
          width: 120,
          height: 120,
          preserveAspectRatio: "meet"
        });
        candimag.x = 0;
        candimag.y = 0;
        return candimage.on('click', function() {
          var iimage, image;
          image = svg.append('image').attr({
            'xlink:href': url,
            x: 0,
            y: 0,
            width: 240,
            height: 240,
            preserveAspectRatio: "meet"
          });
          iimage = image;
          image.on('mousedown', function() {
            var clickedElement;
            clickedElement = setfunc(iimage);
            downpoint = d3.mouse(this);
            return moving = true;
          });
          image.on('mousemove', selfunc(image));
          return image.on('mouseup', function() {});
        });
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

window.line = d3.svg.line().interpolate('cardinal').x(function(d) {
  return d[0];
}).y(function(d) {
  return d[1];
});

window.template = svg.append("g");

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
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    if (randomTimeout) {
      clearTimeout(randomTimeout);
    }
    return srand(timeseed);
  });
  d3.select("#" + id).on('mousemove', function() {
    var i, j, x, y, _ref;
    if (downpoint) {
      d3.event.preventDefault();
      _ref = d3.mouse(this), x = _ref[0], y = _ref[1];
      template.change(x - downpoint[0], y - downpoint[1]);
      i = Math.floor((x - downpoint[0]) / 10);
      j = Math.floor((y - downpoint[1]) / 10);
      return srand(timeseed + i * 100 + j);
    }
  });
  return d3.select("#" + id).on('mouseup', function() {
    return downpoint = null;
  });
};

setTemplate("template0", meshTemplate);

setTemplate("template1", parseTemplate);

setTemplate("template2", kareobanaTemplate);

setTemplate("template3", kareobanaTemplate3);

setTemplate("template4", kareobanaTemplate4);

path = null;

drawPath = function(path) {
  path.attr({
    d: line(points),
    stroke: path.attr('color'),
    'stroke-width': linewidth,
    'stroke-linecap': "round",
    fill: "none"
  });
  path.x = 0;
  return path.y = 0;
};

selfunc = function(element) {
  return function() {
    if (mode === 'edit') {
      if (!downpoint) {
        return;
      }
      if (moving) {
        return;
      }
      element.attr("stroke", "yellow");
      if (__indexOf.call(selected, element) < 0) {
        return selected.push(element);
      }
    }
  };
};

setfunc = function(element) {
  return function() {
    return element;
  };
};

modetimeout = null;

resettimeout = null;

downtime = null;

clickedElement = null;

draw_mode = function() {
  mode = 'draw';
  moved = null;
  duplicated = false;
  strokes = [];
  template.selectAll("*").remove();
  elements.map(function(element) {
    return element.attr("stroke", element.attr('color'));
  });
  bgrect.attr("fill", "#ffffff");
  svg.on('mousedown', function() {
    var ppath;
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    downtime = new Date();
    if (resettimeout) {
      clearTimeout(resettimeout);
    }
    modetimeout = setTimeout(function() {
      var element, f;
      selected = [];
      path.remove();
      if (clickedElement) {
        element = clickedElement();
        element.attr("stroke", "yellow");
        f = element.attr("fill");
        if (f && f !== "none") {
          element.attr("fill", "yellow");
        }
        selected.push(element);
      }
      return edit_mode();
    }, 500);
    path = svg.append('path');
    path.attr("color", linecolor);
    elements.push(path);
    points = [downpoint];
    ppath = path;
    path.on('mousedown', function() {
      clickedElement = setfunc(ppath);
      downpoint = d3.mouse(this);
      return moving = true;
    });
    path.on('mousemove', selfunc(path));
    return path.on('mouseup', function() {});
  });
  svg.on('mouseup', function() {
    var uppoint, uptime;
    if (!downpoint) {
      return;
    }
    d3.event.preventDefault();
    uppoint = d3.mouse(this);
    uptime = new Date();
    if (modetimeout) {
      clearTimeout(modetimeout);
    }
    if (resettimeout) {
      clearTimeout(resettimeout);
    }
    resettimeout = setTimeout(function() {
      strokes = [];
      points = [];
      return [0, 1, 2, 3, 4, 5].forEach(function(i) {
        var candsvg;
        candsvg = d3.select("#cand" + i);
        return candsvg.selectAll("*").remove();
      });
    }, 2000);
    points.push(uppoint);
    drawPath(path);
    strokes.push([downpoint, uppoint]);
    path.snappoints = [downpoint, uppoint];
    downpoint = null;
    moving = false;
    clickedElement = null;
    return recognition(strokes);
  });
  return svg.on('mousemove', function() {
    if (!downpoint) {
      return;
    }
    movepoint = d3.mouse(this);
    if (dist(movepoint, downpoint) > 20.0) {
      clearTimeout(modetimeout);
    }
    d3.event.preventDefault();
    points.push(movepoint);
    return drawPath(path);
  });
};

snapdx = 0;

snapdy = 0;

totaldist = 0;

edit_mode = function() {
  mode = 'edit';
  template.selectAll("*").remove();
  bgrect.attr("fill", "#e0e0e0");
  svg.on('mousedown', function() {
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    movepoint = downpoint;
    downtime = new Date();
    moved = null;
    return totaldist = 0;
  });
  svg.on('mousemove', function() {
    var d, dd, element, movex, movey, oldmovepoint, point, refpoint, refpoints, snappoint, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _results;
    if (!downpoint) {
      return;
    }
    if (!moving) {
      return;
    }
    oldmovepoint = movepoint;
    movepoint = d3.mouse(this);
    totaldist += dist(movepoint, oldmovepoint);
    snapdx = 0;
    snapdy = 0;
    if (totaldist > 200) {
      points = [];
      refpoints = [];
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        if (element.snappoints) {
          if (__indexOf.call(selected, element) >= 0) {
            _ref = element.snappoints;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              snappoint = _ref[_j];
              points.push([snappoint[0] + movepoint[0] - downpoint[0], snappoint[1] + movepoint[1] - downpoint[1]]);
            }
          } else {
            _ref1 = element.snappoints;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              snappoint = _ref1[_k];
              refpoints.push([snappoint[0], snappoint[1]]);
            }
          }
        }
      }
      d = 10000000;
      for (_l = 0, _len3 = points.length; _l < _len3; _l++) {
        point = points[_l];
        for (_m = 0, _len4 = refpoints.length; _m < _len4; _m++) {
          refpoint = refpoints[_m];
          dd = dist(point, refpoint);
          if (dd < d) {
            d = dd;
            snapdx = point[0] - refpoint[0];
            snapdy = point[1] - refpoint[1];
          }
        }
      }
    }
    if (Math.abs(snapdx) > 50 || Math.abs(snapdy > 50)) {
      snapdx = 0;
      snapdy = 0;
    }
    _results = [];
    for (_n = 0, _len5 = selected.length; _n < _len5; _n++) {
      element = selected[_n];
      movex = element.x + movepoint[0] - downpoint[0] - snapdx;
      movey = element.y + movepoint[1] - downpoint[1] - snapdy;
      _results.push(element.attr("transform", "translate(" + movex + "," + movey + ")"));
    }
    return _results;
  });
  return svg.on('mouseup', function() {
    var element, f, snappoint, uppoint, uptime, _i, _j, _k, _len, _len1, _len2, _ref;
    if (!downpoint) {
      return;
    }
    d3.event.preventDefault();
    uppoint = d3.mouse(this);
    if (moving) {
      for (_i = 0, _len = selected.length; _i < _len; _i++) {
        element = selected[_i];
        element.x = element.x + uppoint[0] - downpoint[0] - snapdx;
        element.y = element.y + uppoint[1] - downpoint[1] - snapdy;
        if (element.snappoints) {
          _ref = element.snappoints;
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            snappoint = _ref[_j];
            snappoint[0] += uppoint[0] - downpoint[0] - snapdx;
            snappoint[1] += uppoint[1] - downpoint[1] - snapdx;
          }
        }
      }
      moved = [uppoint[0] - downpoint[0], uppoint[1] - downpoint[1]];
    }
    moving = false;
    downpoint = null;
    clickedElement = null;
    uptime = new Date();
    if (uptime - downtime < 300) {
      duplicated = false;
      if (selected.length === 0) {
        selected = [];
        strokes = [];
        return draw_mode();
      } else {
        for (_k = 0, _len2 = selected.length; _k < _len2; _k++) {
          element = selected[_k];
          element.attr("stroke", element.attr('color'));
          f = element.attr("fill");
          if (f && f !== "none") {
            element.attr("fill", element.attr('color'));
          }
        }
        return selected = [];
      }
    }
  });
};

recognition = function(strokes) {
  var cands;
  cands = recognize(strokes, window.kanjidata, window.figuredata);
  return [0, 1, 2, 3, 4, 5].forEach(function(i) {
    var cand, candElement, candsvg;
    cand = cands[i];
    candsvg = d3.select("#cand" + i);
    candsvg.selectAll("*").remove();
    candElement = candsvg.append(cand.type);
    candElement.attr(cand.attr);
    if (cand.snappoints) {
      candElement.attr('snappoints', JSON.stringify(cand.snappoints));
    }
    if (cand.text) {
      candElement.text(cand.text);
    }
    candElement.attr('color', 'black');
    candElement.on('mousedown', function() {
      var attr, copiedElement, target, text, xx, yy, _i, _j, _len, _ref, _ref1, _results;
      d3.event.preventDefault();
      downpoint = d3.mouse(this);
      target = d3.event.target;
      xx = strokes[0][0][0];
      yy = strokes[0][0][1];
      (function() {
        _results = [];
        for (var _i = 0, _ref = strokes.length; 0 <= _ref ? _i < _ref : _i > _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this).forEach(function(i) {
        var element;
        element = elements.pop();
        return element.remove();
      });
      strokes = [];
      copiedElement = svg.append(target.nodeName);
      copiedElement.x = 0;
      copiedElement.y = 0;
      _ref1 = target.attributes;
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        attr = _ref1[_j];
        copiedElement.attr(attr.nodeName, attr.value);
        if (attr.nodeName === 'snappoints') {
          copiedElement.snappoints = JSON.parse(attr.value);
        }
        if (attr.nodeName === 'x') {
          copiedElement.attr('x', xx);
        }
        if (attr.nodeName === 'y') {
          copiedElement.attr('y', yy);
        }
      }
      if (target.innerHTML) {
        copiedElement.text(target.innerHTML);
        text = $('#searchtext').val();
        $('#searchtext').val(text + target.innerHTML);
      }
      elements.push(copiedElement);
      copiedElement.on('mousemove', selfunc(copiedElement));
      return copiedElement.on('mousedown', function() {
        clickedElement = setfunc(copiedElement);
        selected.push(copiedElement);
        return moving = true;
      });
    });
    return candElement.on('mouseup', function() {
      if (!downpoint) {
        return;
      }
      d3.event.preventDefault();
      return downpoint = null;
    });
  });
};
