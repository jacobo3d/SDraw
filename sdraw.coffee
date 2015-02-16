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
#

downpoint = null  # mousedown時の座標
selected = []     # 選択された要素列
points = []       # ストローク座標列
strokes = []      # 始点と終点の組の列
moving = false

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
mode = 'draw' # または 'edit'
$('#draw').on 'click', ->
  draw_mode()
$('#edit').on 'click', ->
  selected = []
  edit_mode()

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

    cloned.on 'mousemove', selfunc cloned

#    selected.push cloned

$('#test').on 'click', ->
  svg.append "text"
    .text "テキストを表示できます"
    .attr "x", 50
    .attr "y", 100
    .attr "font-size", '60px'
    .attr "fill", "blue"

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

############################################################################
#
# 背景テンプレート
# 
# SVGの機能で <g>....</g> でグループ化してまとめてtransformしたりする
# このグループのtemplateを書きかえるとバックグラウンドが書き変わる
#
window.template = svg.append "g"

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
    d3.event.preventDefault()
    downpoint = d3.mouse(this)
    if randomTimeout
      clearTimeout randomTimeout
    srand(timeseed)
  d3.select("##{id}").on 'mousemove', ->
    if downpoint
      d3.event.preventDefault()
      [x, y] = d3.mouse(this)
      template.change x - downpoint[0], y - downpoint[1]
      i = Math.floor((x - downpoint[0]) / 10)
      j = Math.floor((y - downpoint[1]) / 10)
      srand(timeseed + i * 100 + j)
  d3.select("##{id}").on 'mouseup', ->
    downpoint = null
    #randomTimeout = setTimeout ->
    #  timeseed = Number(new Date()) # 3秒たつと値が変わる
    #, 3000

setTemplate("template0", meshTemplate)
setTemplate("template1", parseTemplate)
setTemplate("template2", kareobanaTemplate)
setTemplate("template3", kareobanaTemplate3)

############################################################################
##
## ユーザによる線画お絵書き
## 
  
path = null
# SVGElement.getScreenCTM() とか使うべきなのかも

draw = ->
  path.attr
    d:              line points
    stroke:         'blue'
    'stroke-width': 8
    fill:           "none"

#
# 描画エレメントを選択状態にする関数を返す関数
#
selfunc = (element) ->
  ->
    if mode == 'edit'
      return unless downpoint
      element.attr "stroke", "yellow"
      selected.push element unless element in selected 

draw_mode = ->
  mode = 'draw'

  strokes = []

  template.selectAll "*"
    .remove()
  svg.selectAll "*"
    .attr "stroke", 'blue'

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    downpoint = d3.mouse(this)
    path = svg.append 'path' # SVGのpath要素 (曲線とか描ける)
    points = [ downpoint ]

    path.on 'mousedown', ->
      return unless mode == 'edit'
      downpoint = d3.mouse(this)
      $('#searchtext').val(downpoint[0])
      attr = path.node().attributes
      xisset = false
      for x in attr
        xisset = true if x.nodeName == 'x'
      unless xisset
        path.attr "x", 0.0 # downpoint[0]
        path.attr "y", 0.0 # downpoint[1]
      moving = true
      #move_mode()
        
    # マウスが横切ったら選択する
    path.on 'mousemove', selfunc path  # クロージャ
    
    path.on 'mouseup', ->
      #if mode == 'move'
      #  target = d3.event.target
      #  for attr in target.attributes
      #    alert attr.nodeName

      # これらはsvg.on('mouseup')でセットする
      #drawpoint = null
      #moving = false

  svg.on 'mouseup', ->
    return unless downpoint
    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    points.push uppoint
    draw()
    strokes.push [ downpoint, uppoint ]
    downpoint = null
    moving = false # ねんのため

    recognition() # !!!!!

  svg.on 'mousemove', ->
    return unless downpoint
    d3.event.preventDefault()
    points.push d3.mouse(this)
    draw()

edit_mode = ->
  mode = 'edit'
  
  template.selectAll "*"
    .remove()

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    downpoint = d3.mouse(this)
    $('#searchtext').val("edit-down")

  svg.on 'mousemove', ->
    return unless downpoint
    return unless moving
    movepoint = d3.mouse(this)
    $('#searchtext').val("move-move selected = #{selected.length}")
    for element in selected
      # element.attr "transform", "translate(#{movepoint[0]-downpoint[0]},#{movepoint[1]-downpoint[1]})"
      attr = element.node().attributes
      x = 0.0
      y = 0.0
      for e in attr
        x = e.value if e.nodeName == 'x'
        y = e.value if e.nodeName == 'y'
        
      #$('#searchtext').val("xy(#{x},#{y})d(#{downpoint[0]},#{downpoint[1]})m(#{movepoint[0]},#{movepoint[1]})-t(#{movepoint[0]-downpoint[0]+x},#{movepoint[1]-downpoint[1]+y})")
      $('#searchtext').val("#{movepoint[0]-downpoint[0]+Number(x)},#{movepoint[1]-downpoint[1]+Number(y)}")
      element.attr "transform", "translate(#{Number(movepoint[0])-Number(downpoint[0])+Number(x)},#{Number(movepoint[1])-Number(downpoint[1])+Number(y)})"

  svg.on 'mouseup', ->
    return unless downpoint
    d3.event.preventDefault()
    $('#searchtext').val('move-up')
    uppoint = d3.mouse(this)
    if moving
      for element in selected
        element.attr 'x', uppoint[0]-downpoint[0]
        element.attr 'y', uppoint[1]-downpoint[1]
      
      #attr = element.node().attributes
      #a = element.attr().property()
      #a = element.attr()
      #for x, y of attr
      #  alert "#{x} => #{y}"
      #for x in attr
      #  alert x.nodeName
      #  alert x.value
    
    downpoint = null
    moving = false

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
  # 漢字/図形ストロークデータとマッチングをとる
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
      downpoint = d3.mouse(this)
      strokes = [] # 候補選択したらストローク情報はクリアする
      target = d3.event.target
      #
      # 候補情報をコピーして描画領域に貼り付ける
      # 
      copied_element = svg.append target.nodeName # "text", "path", etc.
      for attr in target.attributes
        copied_element.attr attr.nodeName, attr.value
      copied_element.text target.innerHTML if target.innerHTML

      # マウスが横切ったら選択する
      copied_element.on 'mousemove', selfunc copied_element
    
      copied_element.on 'mousedown', ->
        return unless mode == 'edit'
        d3.event.preventDefault()
        downpoint = d3.mouse(this)
        move_mode()

    candelement.on 'mouseup', ->
      return unless downpoint
      d3.event.preventDefault()
      downpoint = null

    #candelement.on 'mousemove', ->
    #  return unless downpoint
    #  d3.event.preventDefault()
    #  $('#searchtext').val(elementy)
    #  [x, y] = d3.mouse(this)
    #  copied_element.attr "transform", "translate(#{x - downpoint[0]},#{y - downpoint[1]})"



