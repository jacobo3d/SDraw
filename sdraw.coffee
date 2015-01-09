#
# S-Draw: Suggestive-Supportive-Snapping Drawing
#
# Toshiyuki Masui 2015/01/08 21:02:36
#

body = d3.select "body" # body = d3.select("body").style({margin:0, padding:0}), etc.
svg =  d3.select "svg"

browserWidth = ->
  window.innerWidth || document.body.clientWidth

browserHeight = ->
  window.innerHeight || document.body.clientHeight

resize = ->
  drawWidth = browserWidth() * 0.69
  drawHeight = browserHeight()

  svg
    .attr
      width: drawWidth
      height: drawHeight
    .style
      'background-color': "#ffffff"

  $('#candidates')
    .css 'height', drawHeight/2
  $('#suggestions')
    .css 'height', drawHeight/2

resize()

$(window).resize resize

# pathデータを生成するline関数を定義
# .interpolate 'basis'
# スタイルはhttps://github.com/mbostock/d3/wiki/SVG-Shapes#line_interpolate に説明あり
#
line = d3.svg.line()
  .interpolate 'cardinal'  # 指定した点を通る
  .x (d) -> d.x
  .y (d) -> d.y

#
# テンプレート
#

#
# 背景テンプレートはグループでまとめる
#
template = svg.append "g"

setTemplate = (id, template) ->
  $("##{id}").on 'click', ->
    template.draw()

linetemplate = (x1, y1, x2, y2) ->
  template.append "polyline"
    .attr
      points: [[x1, y1], [x2, y2]]
      stroke: "#d0d0d0"
      fill: "none"
      "stroke-width": "4"
          
# 方眼紙テンプレート
meshTemplate =
  draw: ->
    template.selectAll "polyline"
      .remove()
    template.selectAll "path"
      .remove()
    for i in [0..20]
      linetemplate i * 40, 0, i * 40, browserHeight()
    for i in [0..20]
      linetemplate 0, i * 40, browserWidth(), i * 40

setTemplate("meshTemplate", meshTemplate)

# 透視図法テンプレート
parseTemplate =
  draw: ->
    template.selectAll "polyline"
      .remove()
    template.selectAll "path"
      .remove()
    for i in [0..10]
      linetemplate 10, 10, browserWidth(), 10 + i * 50

setTemplate("perseTemplate", parseTemplate)

# 枯尾花テンプレート
drawkare = (p1, p2, p3) ->
  drawpoints = [p1, p2, p3]
  path = template.append 'path'
  path.attr
    stroke:         '#d0d0d0'
    'stroke-width': 3
    fill:           "none"
    d:              line drawpoints
    
kareobanaTemplate =
  draw: ->
    template.selectAll "polyline"
      .remove()
    template.selectAll "path"
      .remove()
    drawWidth = browserWidth() * 0.69
    drawHeight = browserHeight()
    for x in [0..drawWidth / 80]
      for y in [0..drawHeight / 80]
        p2 = {x: x * 80, y: y * 80}
        p1 = {x: rand(drawWidth), y: rand(drawHeight)}
        while dist(p1,p2) < 50 || dist(p1,p2) > 150
          p1 = {x: rand(drawWidth), y: rand(drawHeight)}
        p3 = {x: rand(drawWidth), y: rand(drawHeight)}
        while dist(p3,p2) < 50 || dist(p3,p2) > 150 || dist(p1,p3) < 50 || dist(p1,p3) > 150
          p3 = {x: rand(drawWidth), y: rand(drawHeight)}
        drawkare p1, p2, p3

setTemplate("kareobanaTemplate", kareobanaTemplate)

# # ランダム曲線2
# #for i in [0..40]
# #  p1 = [rand(640), rand(480)]
# #  p2 = [rand(640), rand(480)]
# #  while dist(p1,p2) < 50 || dist(p1,p2) > 150
# #    p2 = [rand(640), rand(480)]
# #  p3 = [rand(640), rand(480)]
# #  while dist(p1,p3) < 50 || dist(p1,p3) > 150 || dist(p2,p3) < 50 || dist(p2,p3) > 150
# #    p3 = [rand(640), rand(480)]
# #  drawkare p1, p2, p3

#################################
# お絵書き
  
drawpoints = []

# SVGのpath要素を追加
path = svg.append 'path'

draw = ->
  path.attr
    d:              line drawpoints
    stroke:         'blue'
    'stroke-width': 3
    fill:           "none"

drawing = false

body.on 'mousedown', ->
  d3.event.preventDefault()
  drawing = true
  path = svg.append 'path'
  drawpoints = [{x: d3.event.clientX, y: d3.event.clientY}]

body.on 'mouseup', ->
  d3.event.preventDefault()
  if drawing
    drawpoints.push  {x: d3.event.clientX, y: d3.event.clientY}
    draw()
    drawing = false

body.on 'mousemove', ->
  d3.event.preventDefault()
  if drawing
    drawpoints.push  {x: d3.event.clientX, y: d3.event.clientY}
    draw()

