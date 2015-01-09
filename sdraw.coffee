#
# S-Draw: Suggestive-Supportive-Snapping Drawing
#
# Toshiyuki Masui 2015/01/08 21:02:36
#

body = d3.select "body" # body = d3.select("body").style({margin:0, padding:0}), etc.
svg =  d3.select "svg"

browserWidth = ->
  if window.innerWidth
    window.innerWidth
  else
    document.body.clientWidth

browserHeight = ->
  if window.innerHeight
    window.innerHeight
  else
    document.body.clientHeight

drawWidth = Math.round browserWidth() * 0.69
drawHeight = Math.round browserHeight()
svg
  .attr
    width: drawWidth
    height: drawHeight
  .style
    'background-color': "#ffff00"

#
# Math functions
#
rand = (n) -> Math.round Math.random() * n
hypot = (x, y) -> Math.sqrt(x * x + y * y)
dist = (p1, p2) ->
  hypot p1[0]-p2[0], p1[1]-p2[1]
  
# pathデータを生成するline関数を定義
# .interpolate 'basis'
# スタイルはhttps://github.com/mbostock/d3/wiki/SVG-Shapes#line_interpolate に説明あり
#
line = d3.svg.line()
  .interpolate 'cardinal'  # 指定した点を通る
  .x (d) -> d[0]
  .y (d) -> d[1]

#
# テンプレート
#
## 透視図法サポート
## linetemplate = (x1, y1, x2, y2) ->
##   svg.append "polyline"
##   .attr
##     points: [[x1, y1], [x2, y2]]
##     stroke: "#d0d0d0"
##     fill: "none"
##     "stroke-width": "10"
## 
## for i in [0..10]
##   linetemplate 10, 10, 600, 10 + i * 50

drawkare = (p1, p2, p3) ->
  drawpoints = [[p1[0], p1[1]], [p2[0], p2[1]], [p3[0], p3[1]]]
  path = svg.append 'path'
  path.attr
    stroke:         '#d0d0d0'
    'stroke-width': 3
    fill:           "none"
    d:              line drawpoints

for x in [0..6]
  for y in [0..4]
    p2 = [x * 80, y * 80]
    p1 = [rand(640), rand(480)]
    while dist(p1,p2) < 50 || dist(p1,p2) > 150
      p1 = [rand(640), rand(480)]
    p3 = [rand(640), rand(480)]
    while dist(p3,p2) < 50 || dist(p3,p2) > 150 || dist(p1,p3) < 50 || dist(p1,p3) > 150
      p3 = [rand(640), rand(480)]
    drawkare p1, p2, p3

#for i in [0..40]
#  p1 = [rand(640), rand(480)]
#  p2 = [rand(640), rand(480)]
#  while dist(p1,p2) < 50 || dist(p1,p2) > 150
#    p2 = [rand(640), rand(480)]
#  p3 = [rand(640), rand(480)]
#  while dist(p1,p3) < 50 || dist(p1,p3) > 150 || dist(p2,p3) < 50 || dist(p2,p3) > 150
#    p3 = [rand(640), rand(480)]
#  drawkare p1, p2, p3

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
  drawpoints = [[d3.event.clientX, d3.event.clientY]]

body.on 'mouseup', ->
  d3.event.preventDefault()
  if drawing
    drawpoints.push [d3.event.clientX, d3.event.clientY]
    draw()
    drawing = false

body.on 'mousemove', ->
  d3.event.preventDefault()
  if drawing
    drawpoints.push [d3.event.clientX, d3.event.clientY]
    draw()

