##
## S-Draw: Suggestive-Supportive-Snapping Drawing
##
## Toshiyuki Masui 2015/01/08 21:02:36
##

# 
# グローバル変数は window.xxxx みたいに指定する
# このファイル中のみのグローバル変数は関数定義の外で初期化しておく
# 
body = d3.select "body" # body = d3.select("body").style({margin:0, padding:0}), etc.
svg =  d3.select "svg"
svgPos = null

window.browserWidth = ->
  window.innerWidth || document.body.clientWidth

window.browserHeight = ->
  window.innerHeight || document.body.clientHeight

resize = ->
  window.drawWidth = browserWidth() * 0.69
  window.drawHeight = browserHeight()

  svg
    .attr
      width: drawWidth
      height: drawHeight
    .style
      'background-color': "#ffffff"

  $('#candidates')
    .css 'height', drawHeight/2 - 30
  $('#suggestions')
    .css 'height', drawHeight/2 - 30

$ ->
  resize()
  $(window).resize resize
  svgPos = $('svg').offset()

#
# 編集モード/描画モード
# 
editmode = 'draw' # または 'edit'
$('#draw').on 'click', ->
  editmode = 'draw'
$('#edit').on 'click', ->
  editmode = 'edit'

############################################################################
#
# 背景テンプレートはグループでまとめる
# (SVGの機能で <g>....</g> でグループ化できるらしい)
# まとめてtransformできたりする
# このグループのtemplateを書きかえるとバックグラウンドが書き変わる
#
window.template = svg.append "g"

############################################################################
#
# 候補領域
#
candsearch = ->
  query = $('#searchtext').val()
  if query.length > 0
    # flickr_search query, (data) ->
    bing_search query, (data) ->
      data.map (url, i) ->
        $("#cand#{i}").attr 'src', url
$('#searchbutton').on 'click', candsearch
$('#searchtext').on 'keydown', (e) ->
  candsearch() if e.keyCode == 13

imagewidth = 400
imageheight = 400
mousedown = false
pointx = 0
pointy = 0
for i in [0..10]
  #  d3.select("#cand#{i}").on 'click', ->
  d3.select("#cand#{i}").on 'mousedown', ->
    d3.event.preventDefault()
    image = d3.event.target.src
    template.selectAll "*"
      .remove()
    template.append 'image'
      .attr
        'xlink:href': image
        x: 0
        y: 0
        width: 400
        height: 400
        preserveAspectRatio: "meet"
    mousedown = true
    pointx = d3.event.clientX
    pointy = d3.event.clientY
  d3.select("#cand#{i}").on 'mousemove', ->
    if mousedown
      d3.event.preventDefault()
      d3.select("image")
        .attr
          x: d3.event.clientX - pointx
          y: d3.event.clientY - pointy
  d3.select("#cand#{i}").on 'mouseup', ->
    d3.event.preventDefault()
    mousedown = false

############################################################################
#
# pathデータを生成するD3のline関数を定義
# .interpolate 'basis'
# スタイルはhttps://github.com/mbostock/d3/wiki/SVG-Shapes#line_interpolate に説明あり
#
# d3.svg.line() というのはSVG用パス文字列生成関数を作成する関数
# "M36,203L184,203L184,79L36,79" みたいな文字列を生成する関数を返す。
# スプラインなどのときは便利みたい
#

window.line = d3.svg.line()
  .interpolate 'cardinal'  # 指定した点を通る
  .x (d) -> d.x
  .y (d) -> d.y

##
## テンプレート領域
##

window.drawline = (x1, y1, x2, y2) ->
  template.append "polyline"
    .attr
      points: [[x1, y1], [x2, y2]]
      stroke: "#d0d0d0"
      fill: "none"
      "stroke-width": "4"

pointx = 0
pointy = 0
mousedown = false
timeseed = 0           # 時刻とともに変わる数値
randomTimeout = null

setTemplate = (id, template) ->
  d3.select("##{id}").on 'click', ->
    template.draw()
  d3.select("##{id}").on 'mousedown', ->
    mousedown = true
    d3.event.preventDefault()
    if randomTimeout
      clearTimeout randomTimeout
    pointx = d3.event.clientX
    pointy = d3.event.clientY
    srand(timeseed)
  d3.select("##{id}").on 'mousemove', ->
    if mousedown
      d3.event.preventDefault()
      template.change d3.event.clientX - pointx, d3.event.clientY - pointy
      i = Math.floor((d3.event.clientX - pointx) / 10)
      j = Math.floor((d3.event.clientY - pointy) / 10)
      srand(timeseed + i * 100 + j)
  d3.select("##{id}").on 'mouseup', ->
    mousedown = false
    randomTimeout = setTimeout ->
      timeseed = Number(new Date()) # 3秒たつと値が変わる
    , 3000

setTemplate("template0", meshTemplate)
setTemplate("template1", parseTemplate)
setTemplate("template2", kareobanaTemplate)
# setTemplate("template3", kareobanaTemplate2)
setTemplate("template3", kareobanaTemplate3)

############################################################################
##
## ユーザによるお絵書き
## 
  
drawpoints = []
path = null
# SVGElement.getScreenCTM() とか使うべきなのかも
# svgPos = $('svg').offset()

draw = ->
  path.attr
    d:              line drawpoints
    stroke:         'blue'
    'stroke-width': 3
    fill:           "none"

selfunc = (path) ->
  ->
    if editmode == 'edit' && mousedown
      path.attr
        stroke: 'yellow'

svg.on 'mousedown', ->
  d3.event.preventDefault()
  mousedown = true
  if editmode == 'draw'
    path = svg.append 'path' # SVGのpath要素 (曲線とか描ける)
    path.on 'mousemove', selfunc path  # クロージャ
    drawpoints = [
      x: d3.event.clientX - svgPos.left
      y: d3.event.clientY - svgPos.top
    ]
  else # editmode == 'edit'

svg.on 'mouseup', ->
  return unless mousedown
  d3.event.preventDefault()
  if editmode == 'draw'
    drawpoints.push
      x: d3.event.clientX - svgPos.left
      y: d3.event.clientY - svgPos.top
    draw()
  else # editmode == 'edit'
  mousedown = false

svg.on 'mousemove', ->
  return unless mousedown
  d3.event.preventDefault()
  if editmode == 'draw'
    drawpoints.push
      x: d3.event.clientX - svgPos.left
      y: d3.event.clientY - svgPos.top
    draw()
  else # editmode == 'edit'
