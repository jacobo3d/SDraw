#
# S-Draw: Suggestive-Supportive-Snapping Drawing
#
# Toshiyuki Masui 2015/01/08 21:02:36
#

body = d3.select "body" # body = d3.select("body").style({margin:0, padding:0}), etc.
svg =  d3.select "svg"

window.browserWidth = ->
  window.innerWidth || document.body.clientWidth

window.browserHeight = ->
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
window.line = d3.svg.line()
  .interpolate 'cardinal'  # 指定した点を通る
  .x (d) -> d.x
  .y (d) -> d.y

#
# テンプレート
#

#
# 背景テンプレートはグループでまとめる
#
window.template = svg.append "g"

setTemplate = (id, template) ->
  $("##{id}").on 'click', ->
    template.draw()

window.drawline = (x1, y1, x2, y2) ->
  template.append "polyline"
    .attr
      points: [[x1, y1], [x2, y2]]
      stroke: "#d0d0d0"
      fill: "none"
      "stroke-width": "4"
          
setTemplate("meshTemplate", meshTemplate)
setTemplate("perseTemplate", parseTemplate)
setTemplate("kareobanaTemplate", kareobanaTemplate)
setTemplate("kareobanaTemplate2", kareobanaTemplate2)


#################
#
# お絵書き
# 
  
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

