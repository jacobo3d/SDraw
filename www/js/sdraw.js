var andlogic, bgrect, body, clickedElement, clickfunc, clone, deletestate, downpoint, downtime, drawPath, draw_mode, duplicated, edit_mode, elementpath, elements, fontsize, hideframe, imagesearch, linecolor, lines, linewidth, mode, modetimeout, moved, movepoint, movetime, moving, path, pen, points, polygon, polyline, randomTimeout, recognition, recogstrokes, resettimeout, resize, selected, selfunc, setTemplate, setfunc, shakepoint, showframe, sizeframe, sizesquare, snapd, strokes, svg, timeseed, totaldist, uppoint, uptime, zooming, zoomorig,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

body = d3.select("body");

svg = d3.select("svg");

bgrect = svg.append('rect');

sizeframe = null;

sizesquare = null;

downpoint = null;

movepoint = null;

uppoint = null;

downtime = null;

uptime = null;

movetime = null;

elements = [];

selected = [];

points = [];

strokes = [];

recogstrokes = [];

moving = false;

zooming = false;

moved = null;

duplicated = false;

linewidth = 10;

fontsize = 50;

linecolor = '#000000';

modetimeout = null;

resettimeout = null;

deletestate = 0;

snapd = [0, 0];

totaldist = 0;

shakepoint = [0, 0];

zoomorig = [0, 0];

clickedElement = null;

window.debug = function(s) {
  return $('#searchtext').val(s);
};

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
  var element, k, len, newelements, query;
  if (selected.length === 0) {
    query = $('#searchtext').val();
    $('#searchtext').val(query.slice(0, -1));
  } else {
    newelements = [];
    for (k = 0, len = elements.length; k < len; k++) {
      element = elements[k];
      if (indexOf.call(selected, element) >= 0) {
        element.remove();
      } else {
        newelements.push(element);
      }
    }
    selected = [];
    elements = newelements;
  }
  return draw_mode();
});

$('#dup').on('click', function() {
  if (moved && duplicated) {
    clone(moved[0] + 30, moved[1] + 30);
  } else {
    clone(30, 30);
  }
  return duplicated = true;
});

pen = d3.select("#pen");

pen.on('mousedown', function() {
  downpoint = d3.mouse(this);
  if (downpoint[0] >= 140) {
    $('#penbg').attr('src', "images/pen3.png");
    linecolor = '#000000';
  }
  if (downpoint[0] > 110 && downpoint[0] < 140) {
    $('#penbg').attr('src', "images/pen2.png");
    linecolor = '#808080';
  }
  if (downpoint[0] > 80 && downpoint[0] < 110) {
    $('#penbg').attr('src', "images/pen1.png");
    linecolor = '#ffffff';
  }
  if (downpoint[0] > 50 && downpoint[0] < 80) {
    $('#pentop1').attr('src', "images/pentop2.png");
    $('#pentop2').attr('src', "images/pentop2.png");
    $('#pentop3').attr('src', "images/pentop1.png");
    linewidth = 20;
    fontsize = 80;
  }
  if (downpoint[0] > 25 && downpoint[0] < 50) {
    $('#pentop1').attr('src', "images/pentop2.png");
    $('#pentop2').attr('src', "images/pentop1.png");
    $('#pentop3').attr('src', "images/pentop2.png");
    linewidth = 10;
    fontsize = 50;
  }
  if (downpoint[0] > 0 && downpoint[0] < 25) {
    $('#pentop1').attr('src', "images/pentop1.png");
    $('#pentop2').attr('src', "images/pentop2.png");
    $('#pentop3').attr('src', "images/pentop2.png");
    linewidth = 4;
    fontsize = 30;
  }
  return downpoint = null;
});

clone = function(dx, dy) {
  var attr, cloned, cpoints, e, element, k, l, len, len1, len2, m, newselected, nodeName, parent, ref, snappoint;
  newselected = [];
  for (k = 0, len = selected.length; k < len; k++) {
    element = selected[k];
    attr = element.node().attributes;
    nodeName = element.property("nodeName");
    parent = d3.select(element.node().parentNode);
    cloned = parent.append(nodeName);
    for (l = 0, len1 = attr.length; l < len1; l++) {
      e = attr[l];
      cloned.attr(e.nodeName, e.value);
    }
    element.attr('stroke', linecolor);
    if (element.snappoints) {
      cloned.snappoints = element.snappoints.map(function(point) {
        return point.concat();
      });
      ref = cloned.snappoints;
      for (m = 0, len2 = ref.length; m < len2; m++) {
        snappoint = ref[m];
        snappoint[0] += dx;
        snappoint[1] += dy;
      }
    }
    cpoints = JSON.parse(element.attr('origpoints')).map(function(point) {
      return [point[0] + dx, point[1] + dy];
    });
    cloned.attr('points', JSON.stringify(cpoints));
    cloned.attr('origpoints', JSON.stringify(cpoints));
    cloned.attr('d', elementpath(element, cpoints));
    if (nodeName === 'text') {
      cloned.text(element.text());
    }
    cloned.on('mousedown', clickfunc(cloned));
    cloned.on('touchstart', clickfunc(cloned));
    cloned.on('mousemove', selfunc(cloned));
    cloned.on('touchmove', selfunc(cloned));
    cloned.on('mouseup', function() {});
    cloned.on('touchend', function() {});
    newselected.push(cloned);
    elements.push(cloned);
  }
  selected = newselected;
  return showframe();
};

$('#selectall').on('click', function() {
  svg.selectAll("*").attr("stroke", "yellow");
  selected = elements;
  showframe();
  return edit_mode();
});

imagesearch = function() {
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
        candimage.x = 0;
        candimage.y = 0;
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

$('#searchbutton').on('click', imagesearch);

$('#searchtext').on('keydown', function(e) {
  if (e.keyCode === 13) {
    return imagesearch();
  }
});

window.line = d3.svg.line().interpolate('cardinal').x(function(d) {
  return d[0];
}).y(function(d) {
  return d[1];
});

polyline = d3.svg.line().x(function(d) {
  return d[0];
}).y(function(d) {
  return d[1];
});

polygon = function(points) {
  var res, s;
  s = "M" + points.map(function(point) {
    return point[0] + "," + point[1];
  }).join("L");
  res = s + "z";
  return res;
};

andlogic = function(points) {
  var r, s, x, y;
  r = (points[1][1] - points[0][1]) / 2;
  x = points[0][0];
  y = points[0][1];
  return s = "M" + (x + r) + "," + y + "a" + r + "," + r + ",-90,0,1,0," + (2 * r) + " M" + (x + r) + "," + y + "L" + x + "," + y + "L" + x + "," + (y + 2 * r) + "L" + (x + r) + "," + (y + 2 * r);
};

lines = function(points) {
  var s;
  s = "";
  points.forEach(function(entry, ind) {
    if (ind % 2 === 0) {
      return s += "M" + entry[0] + "," + entry[1];
    } else {
      return s += "L" + entry[0] + "," + entry[1];
    }
  });
  return s;
};

elementpath = function(element, points) {
  switch (element.attr('name')) {
    case 'circle':
      return circlepath(points);
    case 'polyline':
      return polyline(points);
    case 'polygon':
      return polygon(points);
    case 'lines':
      return lines(points);
    case 'and':
      return andlogic(points);
    default:
      return line(points);
  }
};

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
  var template_mousedown, template_mousemove, template_mouseup;
  d3.select("#" + id).on('click', function() {
    return template.draw();
  });
  d3.select("#" + id).on('touchstart', function() {
    return template.draw();
  });
  template_mousedown = function() {
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    if (randomTimeout) {
      clearTimeout(randomTimeout);
    }
    return srand(timeseed);
  };
  d3.select("#" + id).on('mousedown', template_mousedown);
  d3.select("#" + id).on('touchstart', template_mousedown);
  template_mousemove = function() {
    var i, j, ref, x, y;
    if (downpoint) {
      d3.event.preventDefault();
      ref = d3.mouse(this), x = ref[0], y = ref[1];
      template.change(x - downpoint[0], y - downpoint[1]);
      i = Math.floor((x - downpoint[0]) / 10);
      j = Math.floor((y - downpoint[1]) / 10);
      return srand(timeseed + i * 100 + j);
    }
  };
  d3.select("#" + id).on('mousemove', template_mousemove);
  d3.select("#" + id).on('touchmove', template_mousemove);
  template_mouseup = function() {
    return downpoint = null;
  };
  d3.select("#" + id).on('mouseup', template_mouseup);
  return d3.select("#" + id).on('touchend', template_mouseup);
};

setTemplate("template0", meshTemplate);

setTemplate("template1", parseTemplate);

setTemplate("template2", kareobanaTemplate);

setTemplate("template3", kareobanaTemplate3);

setTemplate("template4", kareobanaTemplate4);

path = null;

drawPath = function(path) {
  return path.attr({
    d: line(points),
    stroke: path.attr('color'),
    'stroke-width': linewidth,
    'stroke-linecap': "round",
    fill: "none",
    points: JSON.stringify(points)
  });
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
      if (zooming) {
        return;
      }
      element.attr("stroke", "yellow");
      if (indexOf.call(selected, element) < 0) {
        selected.push(element);
      }
      return showframe();
    }
  };
};

setfunc = function(element) {
  return function() {
    return element;
  };
};

clickfunc = function(element) {
  return function() {
    clickedElement = element;
    if (mode === 'edit') {
      element.attr("stroke", "yellow");
      if (indexOf.call(selected, element) < 0) {
        selected.push(element);
      }
      showframe();
    }
    downpoint = d3.mouse(this);
    return moving = true;
  };
};

showframe = function() {
  var element, fpoints, k, l, len, len1, maxx, maxy, minx, miny, point, ref, sizesquare_mousedown, x, y;
  hideframe();
  fpoints = [];
  for (k = 0, len = selected.length; k < len; k++) {
    element = selected[k];
    ref = JSON.parse(element.attr('points'));
    for (l = 0, len1 = ref.length; l < len1; l++) {
      point = ref[l];
      fpoints.push(point);
    }
  }
  x = fpoints.map(function(e) {
    return e[0];
  });
  y = fpoints.map(function(e) {
    return e[1];
  });
  maxx = Math.max.apply(Math, x);
  minx = Math.min.apply(Math, x);
  maxy = Math.max.apply(Math, y);
  miny = Math.min.apply(Math, y);
  sizeframe = svg.append('path');
  sizeframe.attr({
    d: "M" + (minx - 5) + "," + (miny - 5) + "L" + (minx - 5) + "," + (maxy + 5) + "L" + (maxx + 5) + "," + (maxy + 5) + "L" + (maxx + 5) + "," + (miny - 5) + "Z",
    fill: 'none',
    'stroke': '#0000ff',
    'stroke-opacity': 0.5,
    'stroke-width': 2
  });
  sizesquare = svg.append('path');
  sizesquare.attr({
    d: "M" + (maxx - 10) + "," + (maxy - 10) + "L" + (maxx - 10) + "," + (maxy + 10) + "L" + (maxx + 10) + "," + (maxy + 10) + "L" + (maxx + 10) + "," + (maxy - 10) + "Z",
    fill: '#ff0000',
    'fill-opacity': 0.5
  });
  sizesquare_mousedown = function() {
    downpoint = d3.mouse(this);
    zoomorig = [minx, miny];
    zooming = true;
    return moving = false;
  };
  sizesquare.on('mousedown', sizesquare_mousedown);
  return sizesquare.on('touchstart', sizesquare_mousedown);
};

hideframe = function() {
  if (sizeframe) {
    sizeframe.remove();
  }
  if (sizesquare) {
    return sizesquare.remove();
  }
};

draw_mode = function() {
  var draw_mousedown, draw_mousemove, draw_mouseup;
  hideframe();
  mode = 'draw';
  moved = null;
  duplicated = false;
  deletestate = 0;
  strokes = [];
  recogstrokes = [];
  template.selectAll("*").remove();
  elements.map(function(element) {
    return element.attr("stroke", element.attr('color'));
  });
  bgrect.attr("fill", "#ffffff");
  draw_mousedown = function() {
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    downtime = d3.event.timeStamp;
    downpoint.push(downtime);
    if (resettimeout) {
      clearTimeout(resettimeout);
    }
    modetimeout = setTimeout(function() {
      var element, f;
      if (clickedElement) {
        selected = [];
        path.remove();
        element = clickedElement;
        element.attr("stroke", "yellow");
        f = element.attr("fill");
        if (f && f !== "none") {
          element.attr("fill", "yellow");
        }
        selected.push(element);
        showframe();
        return edit_mode();
      }
    }, 500);
    path = svg.append('path');
    path.attr("color", linecolor);
    elements.push(path);
    points = [downpoint];
    path.on('mousedown', clickfunc(path));
    path.on('touchstart', clickfunc(path));
    path.on('mousemove', selfunc(path));
    path.on('touchmove', selfunc(path));
    path.on('mouseup', function() {});
    return path.on('touchend', function() {});
  };
  svg.on('mousedown', draw_mousedown);
  svg.on('touchstart', draw_mousedown);
  draw_mouseup = function() {
    var element, f, k, len, newelements;
    if (!downpoint) {
      return;
    }
    d3.event.preventDefault();
    uppoint = d3.mouse(this);
    uptime = d3.event.timeStamp;
    uppoint.push(uptime);
    if (modetimeout) {
      clearTimeout(modetimeout);
    }
    if (resettimeout) {
      clearTimeout(resettimeout);
    }
    resettimeout = setTimeout(function() {
      strokes = [];
      recogstrokes = [];
      points = [];
      return [0, 1, 2, 3, 4, 5, 6, 7].forEach(function(i) {
        var candsvg;
        candsvg = d3.select("#cand" + i);
        return candsvg.selectAll("*").remove();
      });
    }, 2500);
    if (clickedElement && uptime - downtime < 300 && dist(uppoint, downpoint) < 20) {
      selected = [];
      path.remove();
      newelements = [];
      for (k = 0, len = elements.length; k < len; k++) {
        element = elements[k];
        if (element !== path) {
          newelements.push(element);
        }
      }
      elements = newelements;
      element = clickedElement;
      element.attr("stroke", "yellow");
      f = element.attr("fill");
      if (f && f !== "none") {
        element.attr("fill", "yellow");
      }
      selected.push(element);
      downpoint = null;
      showframe();
      zooming = false;
      edit_mode();
    }
    points.push(uppoint);
    recogstrokes = recogstrokes.concat(splitstroke(points));
    strokes.push([downpoint, uppoint]);
    path.snappoints = [downpoint, uppoint];
    downpoint = null;
    moving = false;
    zooming = false;
    clickedElement = null;
    return recognition(recogstrokes);
  };
  svg.on('mouseup', draw_mouseup);
  svg.on('touchend', draw_mouseup);
  draw_mousemove = function() {
    if (!downpoint) {
      return;
    }
    movepoint = d3.mouse(this);
    movetime = d3.event.timeStamp;
    movepoint.push(movetime);
    if (dist(movepoint, downpoint) > 20.0) {
      clearTimeout(modetimeout);
    }
    d3.event.preventDefault();
    points.push(movepoint);
    return drawPath(path);
  };
  svg.on('mousemove', draw_mousemove);
  return svg.on('touchmove', draw_mousemove);
};

edit_mode = function() {
  var edit_mousedown, edit_mousemove, edit_mouseup, element, k, len;
  mode = 'edit';
  deletestate = 0;
  shakepoint = downpoint;
  template.selectAll("*").remove();
  bgrect.attr("fill", "#c0c0c0");
  for (k = 0, len = selected.length; k < len; k++) {
    element = selected[k];
    element.attr('origpoints', element.attr('points'));
  }
  edit_mousedown = function() {
    var l, len1, results;
    d3.event.preventDefault();
    downpoint = d3.mouse(this);
    movepoint = downpoint;
    downtime = d3.event.timeStamp;
    moved = null;
    totaldist = 0;
    deletestate = 0;
    shakepoint = downpoint;
    results = [];
    for (l = 0, len1 = selected.length; l < len1; l++) {
      element = selected[l];
      results.push(element.attr('origpoints', element.attr('points')));
    }
    return results;
  };
  svg.on('mousedown', edit_mousedown);
  svg.on('touchstart', edit_mousedown);
  edit_mousemove = function() {
    var d, dd, l, len1, len2, len3, len4, len5, len6, len7, len8, len9, m, move, mpoints, n, newelements, o, oldmovepoint, point, q, ref, ref1, refpoint, refpoints, scale, snappoint, t, u, v, w;
    if (!downpoint) {
      return;
    }
    oldmovepoint = movepoint;
    movepoint = d3.mouse(this);
    movetime = d3.event.timeStamp;
    if (zooming) {
      if (downpoint) {
        scale = [(movepoint[0] - zoomorig[0]) / (downpoint[0] - zoomorig[0]), (movepoint[1] - zoomorig[1]) / (downpoint[1] - zoomorig[1])];
        for (l = 0, len1 = selected.length; l < len1; l++) {
          element = selected[l];
          mpoints = JSON.parse(element.attr('origpoints')).map(function(point) {
            return [zoomorig[0] + (point[0] - zoomorig[0]) * scale[0], zoomorig[1] + (point[1] - zoomorig[1]) * scale[1]];
          });
          element.attr('points', JSON.stringify(mpoints));
          element.attr('d', elementpath(element, mpoints));
        }
        showframe();
      }
    }
    if (moving) {
      switch (deletestate) {
        case 0:
          if (movepoint[0] - shakepoint[0] > 30) {
            deletestate = 1;
            shakepoint = movepoint;
          }
          break;
        case 1:
          if (shakepoint[0] - movepoint[0] > 30) {
            deletestate = 2;
            shakepoint = movepoint;
          }
          break;
        case 2:
          if (movepoint[0] - shakepoint[0] > 30) {
            deletestate = 3;
            shakepoint = movepoint;
          }
          break;
        case 3:
          if (shakepoint[0] - movepoint[0] > 30 && movetime - downtime < 2000) {
            newelements = [];
            for (m = 0, len2 = elements.length; m < len2; m++) {
              element = elements[m];
              if (indexOf.call(selected, element) < 0) {
                newelements.push(element);
              }
            }
            for (n = 0, len3 = selected.length; n < len3; n++) {
              element = selected[n];
              element.remove();
            }
            selected = [];
            elements = newelements;
            draw_mode();
          }
      }
      totaldist += dist(movepoint, oldmovepoint);
      snapd = [0, 0];
      if (totaldist > 200) {
        mpoints = [];
        refpoints = [];
        for (o = 0, len4 = elements.length; o < len4; o++) {
          element = elements[o];
          if (element.snappoints) {
            if (indexOf.call(selected, element) >= 0) {
              ref = element.snappoints;
              for (q = 0, len5 = ref.length; q < len5; q++) {
                snappoint = ref[q];
                mpoints.push([snappoint[0] + movepoint[0] - downpoint[0], snappoint[1] + movepoint[1] - downpoint[1]]);
              }
            } else {
              ref1 = element.snappoints;
              for (t = 0, len6 = ref1.length; t < len6; t++) {
                snappoint = ref1[t];
                refpoints.push([snappoint[0], snappoint[1]]);
              }
            }
          }
        }
        d = 10000000;
        for (u = 0, len7 = mpoints.length; u < len7; u++) {
          point = mpoints[u];
          for (v = 0, len8 = refpoints.length; v < len8; v++) {
            refpoint = refpoints[v];
            dd = dist(point, refpoint);
            if (dd < d) {
              d = dd;
              snapd = [point[0] - refpoint[0], point[1] - refpoint[1]];
            }
          }
        }
      }
      if (Math.abs(snapd[0]) > 50 || Math.abs(snapd[1] > 50)) {
        snapd = [0, 0];
      }
      for (w = 0, len9 = selected.length; w < len9; w++) {
        element = selected[w];
        move = [movepoint[0] - downpoint[0] - snapd[0], movepoint[1] - downpoint[1] - snapd[1]];
        mpoints = JSON.parse(element.attr('origpoints')).map(function(point) {
          return [point[0] + move[0], point[1] + move[1]];
        });
        element.attr('points', JSON.stringify(mpoints));
        element.attr('d', elementpath(element, mpoints));
      }
      return showframe();
    }
  };
  svg.on('mousemove', edit_mousemove);
  svg.on('touchmove', edit_mousemove);
  edit_mouseup = function() {
    var f, l, len1, len2, len3, m, n, scale, upoints;
    if (!downpoint) {
      return;
    }
    d3.event.preventDefault();
    uppoint = d3.mouse(this);
    if (zooming) {
      scale = [(uppoint[0] - zoomorig[0]) / (downpoint[0] - zoomorig[0]), (uppoint[1] - zoomorig[1]) / (downpoint[1] - zoomorig[1])];
      for (l = 0, len1 = selected.length; l < len1; l++) {
        element = selected[l];
        element.snappoints = element.snappoints.map(function(point) {
          return [zoomorig[0] + (point[0] - zoomorig[0]) * scale[0], zoomorig[1] + (point[1] - zoomorig[1]) * scale[1]];
        });
        upoints = JSON.parse(element.attr('origpoints')).map(function(point) {
          return [zoomorig[0] + (point[0] - zoomorig[0]) * scale[0], zoomorig[1] + (point[1] - zoomorig[1]) * scale[1]];
        });
        element.attr('points', JSON.stringify(upoints));
        element.attr('origpoints', JSON.stringify(upoints));
        element.attr('d', elementpath(element, upoints));
      }
    }
    if (moving) {
      moved = [uppoint[0] - downpoint[0] - snapd[0], uppoint[1] - downpoint[1] - snapd[1]];
      for (m = 0, len2 = selected.length; m < len2; m++) {
        element = selected[m];
        element.snappoints = element.snappoints.map(function(point) {
          return [point[0] + moved[0], point[1] + moved[1]];
        });
        upoints = JSON.parse(element.attr('origpoints')).map(function(point) {
          return [point[0] + moved[0], point[1] + moved[1]];
        });
        element.attr('points', JSON.stringify(upoints));
        element.attr('origpoints', JSON.stringify(upoints));
        element.attr('d', elementpath(element, upoints));
      }
    }
    element.attr('origpoints', element.attr('points'));
    uptime = d3.event.timeStamp;
    if (uptime - downtime < 300 && !clickedElement) {
      duplicated = false;
      if (selected.length === 0) {
        selected = [];
        strokes = [];
        recogstrokes = [];
        hideframe();
        draw_mode();
      } else {
        for (n = 0, len3 = selected.length; n < len3; n++) {
          element = selected[n];
          element.attr("stroke", element.attr('color'));
          f = element.attr("fill");
          if (f && f !== "none") {
            element.attr("fill", element.attr('color'));
          }
        }
        selected = [];
        hideframe();
        draw_mode();
      }
    }
    downpoint = null;
    moving = false;
    zooming = false;
    return clickedElement = null;
  };
  svg.on('mouseup', edit_mouseup);
  return svg.on('touchend', edit_mouseup);
};

recognition = function(recogStrokes) {
  var cands;
  cands = recognize(recogStrokes, points, window.figuredata);
  return [0, 1, 2, 3, 4, 5, 6, 7].forEach(function(i) {
    var cand, candElement, candselfunc, candsvg, ref, ref1, scalex, scaley;
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
    scalex = (ref = cand.scalex) != null ? ref : 1;
    scaley = (ref1 = cand.scaley) != null ? ref1 : 1;
    if (scalex === Infinity) {
      scalex = 1;
    }
    if (scaley === Infinity) {
      scaley = 1;
    }
    candselfunc = function() {
      var attr, copiedElement, k, l, len, len1, len2, m, minx, miny, n, ref2, ref3, ref4, ref5, results, snappoint, target, text, x, y;
      d3.event.preventDefault();
      downpoint = d3.mouse(this);
      target = d3.event.target;
      if (target.nodeName === 'svg') {
        target = target.childNodes[0];
      }
      x = flatten(recogStrokes).map(function(p) {
        return p[0];
      });
      minx = Math.min.apply(Math, x);
      y = flatten(recogStrokes).map(function(p) {
        return p[1];
      });
      miny = Math.min.apply(Math, y);
      (function() {
        results = [];
        for (var k = 0, ref2 = strokes.length; 0 <= ref2 ? k < ref2 : k > ref2; 0 <= ref2 ? k++ : k--){ results.push(k); }
        return results;
      }).apply(this).forEach(function(i) {
        var element;
        element = elements.pop();
        return element.remove();
      });
      copiedElement = svg.append(target.nodeName);
      ref3 = target.attributes;
      for (l = 0, len = ref3.length; l < len; l++) {
        attr = ref3[l];
        copiedElement.attr(attr.nodeName, attr.value);
        if (attr.nodeName === 'snappoints') {
          copiedElement.snappoints = JSON.parse(attr.value);
        }
      }
      copiedElement.attr('font-size', fontsize);
      if (target.nodeName !== 'text') {
        copiedElement.attr('stroke-width', linewidth);
      }
      if (target.nodeName === 'path') {
        ref4 = copiedElement.snappoints;
        for (m = 0, len1 = ref4.length; m < len1; m++) {
          snappoint = ref4[m];
          snappoint[0] *= scalex;
          snappoint[1] *= scaley;
          snappoint[0] += minx;
          snappoint[1] += miny;
          copiedElement.attr("stroke-width", linewidth);
        }
        copiedElement.attr('stroke', linecolor);
        copiedElement.attr('color', linecolor);
        points = JSON.parse(copiedElement.attr('points')).map(function(point) {
          var z;
          return z = [minx + point[0] * scalex, miny + point[1] * scaley];
        });
        copiedElement.attr('points', JSON.stringify(points));
        copiedElement.attr('d', elementpath(copiedElement, points));
      }
      if (target.nodeName === 'text') {
        ref5 = copiedElement.snappoints;
        for (n = 0, len2 = ref5.length; n < len2; n++) {
          snappoint = ref5[n];
          snappoint[0] += minx;
          snappoint[1] += miny;
        }
      }
      if (target.innerHTML) {
        copiedElement.text(target.innerHTML);
        text = $('#searchtext').val();
        $('#searchtext').val(text + target.innerHTML);
      }
      elements.push(copiedElement);
      copiedElement.on('mousemove', selfunc(copiedElement));
      copiedElement.on('touchmove', selfunc(copiedElement));
      copiedElement.on('mousedown', clickfunc(copiedElement));
      copiedElement.on('touchstart', clickfunc(copiedElement));
      strokes = [];
      return recogstrokes = [];
    };
    candElement.on('mousedown', candselfunc);
    if (!cand.text) {
      candsvg.on('mousedown', candselfunc);
    }
    return candElement.on('mouseup', function() {
      if (!downpoint) {
        return;
      }
      d3.event.preventDefault();
      return downpoint = null;
    });
  });
};
