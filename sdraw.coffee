##
## S-Draw: Suggestive-Supportive-Snapping Drawing
##
## Toshiyuki Masui 2015/01/08 21:02:36
##

# 
# グローバル変数は window.xxxx みたいに指定する
# このファイル中のみのグローバル変数は関数定義の外で初期化しておく
#
# 
body = d3.select "body" # body = d3.select("body").style({margin:0, padding:0}), etc.
svg =  d3.select "svg"
#a = svg.attr().property()
#for x, y of a
#  alert "#{x} => #{y}"

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
  draw_mode()

  $.getJSON "kanji/kanji.json", (data) ->
    window.kanjidata = data
  $.getJSON "figures.json", (data) ->
    window.figuredata = data

#
# 編集モード/描画モード
# 
mode = 'draw' # または 'edit' または 'move'
$('#draw').on 'click', -> draw_mode()
$('#edit').on 'click', -> edit_mode()

$('#delete').on 'click', ->
  for element in selected
    element.remove()

$('#dup').on 'click', ->
  for element in selected
    attr = element.node().attributes
    node_name = element.property "nodeName"
    parent = d3.select element.node().parentNode

    cloned = parent.append node_name
    for a in attr
      cloned.attr a.nodeName, a.value
    cloned.attr "transform", "translate(30,30)"
    cloned.on 'mousedown', ->
      if mode == 'edit'
        downpoint = d3.mouse(this)
        move_mode()

    cloned.on 'mousemove', selfunc cloned

#    selected.push cloned

$('#test').on 'click', ->
  svg.append "text"
    .attr "x", 50
    .attr "y", 100
    .attr "font-size", '60px'
    .attr "fill", "blue"
    .text "テキストを表示できます"

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
        cand = $("#cand#{i}")
        cand.children().remove()
        img = $("<img>")
        img.attr 'class', 'candimage'
        img.attr 'src', url
        cand.append img

        # $("#cand#{i}").attr 'src', url
$('#searchbutton').on 'click', candsearch
$('#searchtext').on 'keydown', (e) ->
  candsearch() if e.keyCode == 13

imagewidth = 400
imageheight = 400
mousedown = false
pointx = 0
pointy = 0
elementx = 0
elementy = 0
#for i in [0..10]
#  d3.select("#cand#{i}").on 'mousedown', ->
#    d3.event.preventDefault()
#    image = d3.event.target.src
#    template.selectAll "*"
#      .remove()
#    template.append 'image'
#      .attr
#        'xlink:href': image
#        x: 0
#        y: 0
#        width: 400
#        height: 400
#        preserveAspectRatio: "meet"
#    mousedown = true
#    pointx = d3.event.clientX
#    pointy = d3.event.clientY
#  d3.select("#cand#{i}").on 'mousemove', ->
#    if mousedown
#      d3.event.preventDefault()
#      d3.select("image")
#        .attr
#          x: d3.event.clientX - pointx
#          y: d3.event.clientY - pointy
#  d3.select("#cand#{i}").on 'mouseup', ->
#    d3.event.preventDefault()
#    mousedown = false

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
  .x (d) -> d[0]
  .y (d) -> d[1]

##
## テンプレート領域
##

window.drawline = (x1, y1, x2, y2) ->
  template.append "polyline"
    .attr
      points: [[x1, y1], [x2, y2]]
      stroke: "#d0d0d0"
      fill: "none"
      "stroke-width": "3"

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
    [pointx, pointy] = d3.mouse(this)
    srand(timeseed)
  d3.select("##{id}").on 'mousemove', ->
    if mousedown
      d3.event.preventDefault()
      [x, y] = d3.mouse(this)
      template.change x - pointx, y - pointy
      i = Math.floor((x - pointx) / 10)
      j = Math.floor((y - pointy) / 10)
      srand(timeseed + i * 100 + j)
  d3.select("##{id}").on 'mouseup', ->
    mousedown = false
    #randomTimeout = setTimeout ->
    #  timeseed = Number(new Date()) # 3秒たつと値が変わる
    #, 3000

setTemplate("template0", meshTemplate)
setTemplate("template1", parseTemplate)
setTemplate("template2", kareobanaTemplate)
# setTemplate("template3", kareobanaTemplate2)
setTemplate("template3", kareobanaTemplate3)

############################################################################
##
## ユーザによるお絵書き
## 
  
points = []
path = null
# SVGElement.getScreenCTM() とか使うべきなのかも

strokes = []

draw = ->
  path.attr
    d:              line points
    stroke:         'blue'
    'stroke-width': 8
    fill:           "none"

selected = []

selfunc = (path) ->
  ->
    if mode == 'edit'
      return unless mousedown
      path.attr "stroke", "yellow"
      selected.push path unless path in selected 

downpoint = []

draw_mode = ->
  mode = 'draw'

  strokes = []

  template.selectAll "*"
    .remove()
  svg.selectAll "*"
    .attr "stroke", 'blue'

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    mousedown = true
    path = svg.append 'path' # SVGのpath要素 (曲線とか描ける)
    downpoint = d3.mouse(this)
    points = [ downpoint ]

    # マウスが横切ったら選択する
    path.on 'mousemove', selfunc path  # クロージャ
    
    path.on 'mousedown', ->
      if mode == 'edit'
        downpoint = d3.mouse(this)
        move_mode()

  svg.on 'mouseup', ->
    return unless mousedown
    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    points.push uppoint
    draw()
    mousedown = false
    strokes.push [ downpoint, uppoint ]

    recognition() # !!!!!

  svg.on 'mousemove', ->
    return unless mousedown
    d3.event.preventDefault()
    #[x, y] = d3.mouse(this)
    #points.push
    #  x: d3.mouse(this)[0]
    #  y: d3.mouse(this)[1]
    points.push d3.mouse(this)
    draw()

edit_mode = ->
  selected = []
  mode = 'edit'
  strokes = []

  template.selectAll "*"
    .remove()

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    mousedown = true

  svg.on 'mousemove', ->

  svg.on 'mouseup', ->
    return unless mousedown
    d3.event.preventDefault()
    mousedown = false

move_mode = ->
  mode = 'move'

  template.selectAll "*"
    .remove()

  svg.on 'mousedown', ->
    downpoint = d3.mouse(this)
    mousedown = true

  svg.on 'mousemove', ->
    return unless mousedown
    [x, y] = d3.mouse(this)
    for element in selected
      element.attr "transform", "translate(#{x-downpoint[0]},#{y-downpoint[1]})"

  svg.on 'mouseup', ->
    return unless mousedown
    d3.event.preventDefault()
    mousedown = false
    edit_mode()

###############

copied_element = null
recognition = ->
  #
  # strokesを正規化する。
  #
  nstrokes = strokes.length
  [minx, miny, maxx, maxy] = [1000, 1000, 0, 0]
  for stroke in strokes
    minx = Math.min minx, stroke[0][0]
    maxx = Math.max maxx, stroke[0][0]
    minx = Math.min minx, stroke[1][0]
    maxx = Math.max maxx, stroke[1][0]
    miny = Math.min miny, stroke[0][1]
    maxy = Math.max maxy, stroke[0][1]
    miny = Math.min miny, stroke[1][1]
    maxy = Math.max maxy, stroke[1][1]
  width = maxx - minx
  height = maxy - miny
  size = Math.max width, height
  normalized_strokes = []
  for stroke in strokes
    x0 = (stroke[0][0]-minx) * 1000.0 / size
    y0 = (stroke[0][1]-miny) * 1000.0 / size
    x1 = (stroke[1][0]-minx) * 1000.0 / size
    y1 = (stroke[1][1]-miny) * 1000.0 / size
    normalized_strokes.push [[x0, y0], [x1, y1]]
  #
  # 漢字ストロークデータとマッチングをとる
  #
  cands = []
  for data in [window.kanjidata, window.figuredata]
    for entry in data
      kstrokes = entry.strokes
      continue if kstrokes.length < nstrokes
      [minx, miny, maxx, maxy] = [1000, 1000, 0, 0]
      [0...nstrokes].forEach (i) ->
        points = kstrokes[i]
        stroke = []
        stroke[0] = points[0]
        stroke[1] = points[points.length-1]
        minx = Math.min minx, stroke[0][0]
        maxx = Math.max maxx, stroke[0][0]
        minx = Math.min minx, stroke[1][0]
        maxx = Math.max maxx, stroke[1][0]
        miny = Math.min miny, stroke[0][1]
        maxy = Math.max maxy, stroke[0][1]
        miny = Math.min miny, stroke[1][1]
        maxy = Math.max maxy, stroke[1][1]
      width = maxx - minx
      height = maxy - miny
      size = Math.max width, height
      kanji_strokes = []
      [0...nstrokes].forEach (i) ->
        points = kstrokes[i]
        stroke = []
        stroke[0] = points[0]
        stroke[1] = points[points.length-1]
        x0 = (stroke[0][0]-minx) * 1000.0 / size
        y0 = (stroke[0][1]-miny) * 1000.0 / size
        x1 = (stroke[1][0]-minx) * 1000.0 / size
        y1 = (stroke[1][1]-miny) * 1000.0 / size
        kanji_strokes.push [[x0, y0], [x1, y1]]
      #
      # normalized_strokes と kanji_strokes を比較する
      #
      totaldist = 0.0
      [0...nstrokes].forEach (i) ->
        dx = kanji_strokes[i][0][0] - normalized_strokes[i][0][0]
        dy = kanji_strokes[i][0][1] - normalized_strokes[i][0][1]
        totaldist += Math.sqrt(dx * dx + dy * dy)
        dx = kanji_strokes[i][1][0] - normalized_strokes[i][1][0]
        dy = kanji_strokes[i][1][1] - normalized_strokes[i][1][1]
        totaldist += Math.sqrt(dx * dx + dy * dy)
      cands.push [entry, totaldist]

  #
  # 図形ストロークデータとマッチング
  #

  # スコア順にソート
  cands = cands.sort (a,b) ->
    a[1] - b[1]

  # 候補表示
  [0..5].forEach (i) ->
    cand = cands[i][0]
    candsvg = d3.select "#cand#{i}"
    candsvg.selectAll "*"
      .remove()
    candelement = candsvg.append cand.type
    candelement.attr cand.attr
    candelement.text cand.text if cand.text

    candelement.on 'mousedown', ->
      d3.event.preventDefault()
      mousedown = true
      downpoint = d3.mouse(this)
      # [pointx, pointy] = d3.mouse(this)
      strokes = []
      target = d3.event.target
      copied_element = svg.append target.nodeName
      for attr in target.attributes
        copied_element.attr attr.nodeName, attr.value
        #elementx = Number(attr.value) if attr.nodeName == 'x'
        #elementy = Number(attr.value) if attr.nodeName == 'y'
      copied_element.text target.innerHTML if target.innerHTML

    candelement.on 'mousemove', ->
      return unless mousedown
      d3.event.preventDefault()
      $('#searchtext').val(elementy)
      [x, y] = d3.mouse(this)
      copied_element.attr "transform", "translate(#{x - downpoint[0]},#{y - downpoint[1]})"

    candelement.on 'mouseup', ->
      return unless mousedown
      d3.event.preventDefault()
      mousedown = false
