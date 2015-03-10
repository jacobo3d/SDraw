// Generated by CoffeeScript 1.7.1
var bgrect, body, candsearch, clickedElement, clone, downpoint, downtime, drawPath, draw_mode, duplicated, edit_mode, elements, linecolor, linewidth, mode, modetimeout, moved, moving, path, points, randomTimeout, recognition, resettimeout, resize, selected, selfunc, setTemplate, setfunc, strokes, svg, timeseed,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

body = d3.select("body");

svg = d3.select("svg");

bgrect = svg.append('rect');

downpoint = null;

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
  var attr, cloned, e, element, newselected, nodeName, parent, _i, _j, _len, _len1;
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
    var movepoint;
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

edit_mode = function() {
  mode = 'edit';
  template.selectAll("*").remove();
  bgrect.attr("fill", "#e0e0e0");
  svg.on('mousedown', function() {
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    downtime = new Date();
    return moved = null;
  });
  svg.on('mousemove', function() {
    var d, dx, dy, element, movepoint, p, point, _i, _j, _k, _len, _len1, _len2, _results;
    if (!downpoint) {
      return;
    }
    if (!moving) {
      return;
    }
    movepoint = d3.mouse(this);
    d = dist(movepoint, downpoint);
    dx = 0;
    dy = 0;
    if (d > 200) {
      points = [];
      for (_i = 0, _len = selected.length; _i < _len; _i++) {
        element = selected[_i];
        points.push([element.snappoints[0][0] + movepoint[0] - downpoint[0], element.snappoints[0][1] + movepoint[1] - downpoint[1]]);
        points.push([element.snappoints[1][0] + movepoint[0] - downpoint[0], element.snappoints[1][1] + movepoint[1] - downpoint[1]]);
      }
      d = 10000000;
      p = [];
      for (_j = 0, _len1 = points.length; _j < _len1; _j++) {
        point = points[_j];
        [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].forEach(function(x) {
          p[0] = x * 100;
          return [-10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].forEach(function(y) {
            var dd;
            p[1] = y * 100;
            dd = dist(p, point);
            if (dd < d) {
              d = dd;
              dx = point[0] - p[0];
              return dy = point[1] - p[1];
            }
          });
        });
      }
    }
    _results = [];
    for (_k = 0, _len2 = selected.length; _k < _len2; _k++) {
      element = selected[_k];
      _results.push(element.attr("transform", "translate(" + (element.x + movepoint[0] - downpoint[0] - dx) + "," + (element.y + movepoint[1] - downpoint[1] - dy) + ")"));
    }
    return _results;
  });
  return svg.on('mouseup', function() {
    var element, f, uppoint, uptime, _i, _j, _len, _len1;
    if (!downpoint) {
      return;
    }
    d3.event.preventDefault();
    uppoint = d3.mouse(this);
    if (moving) {
      for (_i = 0, _len = selected.length; _i < _len; _i++) {
        element = selected[_i];
        element.x = element.x + uppoint[0] - downpoint[0];
        element.y = element.y + uppoint[1] - downpoint[1];
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
        for (_j = 0, _len1 = selected.length; _j < _len1; _j++) {
          element = selected[_j];
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
    var cand, candelement, candsvg;
    cand = cands[i][0];
    candsvg = d3.select("#cand" + i);
    candsvg.selectAll("*").remove();
    candelement = candsvg.append(cand.type);
    candelement.attr(cand.attr);
    if (cand.text) {
      candelement.text(cand.text);
    }
    candelement.attr('fill', 'black');
    candelement.attr('color', 'black');
    candelement.on('mousedown', function() {
      var attr, copied_element, target, text, xx, yy, _i, _j, _len, _ref, _ref1, _results;
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
      copied_element = svg.append(target.nodeName);
      copied_element.x = 0;
      copied_element.y = 0;
      _ref1 = target.attributes;
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        attr = _ref1[_j];
        copied_element.attr(attr.nodeName, attr.value);
        if (attr.nodeName === 'x') {
          copied_element.attr('x', xx);
        }
        if (attr.nodeName === 'y') {
          copied_element.attr('y', yy);
        }
      }
      if (target.innerHTML) {
        copied_element.text(target.innerHTML);
        text = $('#searchtext').val();
        $('#searchtext').val(text + target.innerHTML);
      }
      elements.push(copied_element);
      copied_element.on('mousemove', selfunc(copied_element));
      return copied_element.on('mousedown', function() {
        clickedElement = setfunc(copied_element);
        selected.push(copied_element);
        return moving = true;
      });
    });
    return candelement.on('mouseup', function() {
      if (!downpoint) {
        return;
      }
      d3.event.preventDefault();
      return downpoint = null;
    });
  });
};
