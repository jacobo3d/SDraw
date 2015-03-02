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
bgrect = svg.append 'rect'

downpoint = null  # mousedown時の座標
elements = []     # 描画された要素列
selected = []     # 選択された要素列
points = []       # ストローク座標列
strokes = []      # 始点と終点の組の列
moving = false    # 選択要素を移動中かどうか
moved = null      # 移動操作したときの移動量
linewidth = 10
linecolor = '#000000'

window.browserWidth = ->
  window.innerWidth || document.body.clientWidth

window.browserHeight = ->
  window.innerHeight || document.body.clientHeight

window.hypot = (x, y) -> Math.sqrt(x * x + y * y)
window.dist = (p1, p2) -> hypot p1[0]-p2[0], p1[1]-p2[1]

resize = ->
  window.drawWidth = browserWidth() * 0.69
  window.drawHeight = browserHeight()

  svg
    .attr
      width: drawWidth
      height: drawHeight
    .style
      'background-color': "#ffffff"

  bgrect
    .attr
      'x': 0
      'y': 0
      'width': window.drawWidth
      'height': window.drawHeight
      'fill': '#d0d0d0'
      'stroke': '#ffffff'
      'stroke-width': 0

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

#
# メニューボタン
#
$('#edit').on 'click', ->
  edit_mode()
  
$('#delete').on 'click', ->
  if selected.length == 0
    query = $('#searchtext').val()
    $('#searchtext').val(query[0..-2]) # 最後の文字を消す
  else
    newelements = []
    for element in elements
      newelements.push element unless element in selected
    for element in selected
      element.remove()
    selected = []
    elements = newelements
    if elements.length == 0
      draw_mode()
    #else
    #  alert elements.length        ****** おかしい

$('#dup').on 'click', ->
  clone 30, 30

$('#line1').on 'click', ->
  linewidth = 3
$('#line2').on 'click', ->
  linewidth = 10
$('#line3').on 'click', ->
  linewidth = 25
$('#color1').on 'click', ->
  linecolor = '#ffffff'
$('#color2').on 'click', ->
  linecolor = '#808080'
$('#color3').on 'click', ->
  linecolor = '#000000'
  
clone = (dx, dy) ->
  newselected = []
  for element in selected
    attr = element.node().attributes
    node_name = element.property "nodeName"
    parent = d3.select element.node().parentNode

    cloned = parent.append node_name
    x = 0.0
    y = 0.0
    for e in attr
      cloned.attr e.nodeName, e.value
      x = Number(e.value) if e.nodeName == 'xx'
      y = Number(e.value) if e.nodeName == 'yy'
    element.attr 'stroke', linecolor # コピー元は青に戻す
    cloned.attr "xx", x+dx
    cloned.attr "yy", y+dy
    cloned.attr "transform", "translate(#{x+dx},#{y+dy})"
    cloned.text element.text() if node_name == 'text'

    cloned.on 'mousedown', ->
      return unless mode == 'edit'
      clickedelement = setfunc cloned
      downpoint = d3.mouse(this)
      moving = true
      
    cloned.on 'mousemove', selfunc cloned
    
    newselected.push cloned
    elements.push cloned
  selected = newselected

#
# 繰り返し操作サポート
# selected[n] と selected[n+1]が同じものであり、座標だけ違う場合は
# コピーする
# ... というのはやめて
# selectedを単純に複製すればいいかも
# (OmniGraffle式)
#
$('#repeat').on 'click', ->
  if moved
    clone moved[0]+30, moved[1]+30

$('#selectall').on 'click', ->
  edit_mode()
  svg.selectAll "*"
    .attr "stroke", "yellow"
  selected = elements
  
#  svg.selectAll "*"
#    .remove()
    
#  for element in selected
#    element.attr "stroke", "yellow"
  
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
        cand = d3.select("#cand#{i}")
        cand.selectAll('*').remove()
        cand.append 'image'
          .attr
            'xlink:href': url
            x: 0
            y: 0
            width: 120
            height: 120
            preserveAspectRatio: "meet"

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
    d:                line points
    stroke:           linecolor
    'stroke-width':   linewidth
    'stroke-linecap': "round"
    fill:             "none"

#
# 描画エレメントを選択状態にする関数を返す関数
#
selfunc = (element) ->
  ->
    if mode == 'edit'
      return unless downpoint
      return if moving # 移動中は選択しない
      element.attr "stroke", "yellow"
      selected.push element unless element in selected
      
setfunc = (element) ->
  ->
    return element

modetimeout = null    # 長押しで編集モードにするため
resettimeout = null   # 時間がたつと候補リセット
downtime = null

clickedelement = null # クリックされたパスや文字を覚えておく

draw_mode = ->
  mode = 'draw'
  moved = null

  strokes = []

  template.selectAll "*"
    .remove()
  svg.selectAll "*"
    .attr "stroke", linecolor
  bgrect.attr "fill", "#ffffff"

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    
    downpoint = d3.mouse(this)
    downtime = new Date()
    clearTimeout resettimeout if resettimeout
    modetimeout = setTimeout -> # 500msじっとしてると編集モードになるとか
      selected = []
      path.remove()      # drawmodeで描いていた線を消す
      if clickedelement  # pathなどをクリックしてた場合は移動モードにする
        element = clickedelement()
        element.attr "stroke", "yellow"
        selected.push element
        moving = true
      edit_mode()
    , 500
    
    path = svg.append 'path' # SVGのpath要素 (曲線とか描ける)
    elements.push path
    points = [ downpoint ]

    ppath = path
    path.on 'mousedown', ->
      # return unless mode == 'edit'
      clickedelement = setfunc ppath
      downpoint = d3.mouse(this)
      for element in selected
        attr = element.node().attributes
        x = 0.0
        y = 0.0
        for e in attr
          x = Number(e.value) if e.nodeName == 'xx'
          y = Number(e.value) if e.nodeName == 'yy'
        element.attr "xx", x
        element.attr "yy", y
      moving = true
        
    # マウスが横切ったら選択する
    path.on 'mousemove', selfunc path  # クロージャ
    
    path.on 'mouseup', ->

  svg.on 'mouseup', ->
    return unless downpoint
    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    uptime = new Date()
    clearTimeout modetimeout if modetimeout
    clearTimeout resettimeout if resettimeout
    resettimeout = setTimeout -> # 2秒じっとしていると候補を消す
      strokes = []
      points = []
      [0..5].forEach (i) ->
        candsvg = d3.select "#cand#{i}"
        candsvg.selectAll "*"
          .remove()
    , 2000

    points.push uppoint
    draw()
    strokes.push [ downpoint, uppoint ]
    downpoint = null
    moving = false # ねんのため
    clickedelement = null

    recognition() # !!!!!

  svg.on 'mousemove', ->
    return unless downpoint
    movepoint = d3.mouse(this)
    clearTimeout modetimeout if dist(movepoint,downpoint) > 20.0
    d3.event.preventDefault()
    points.push movepoint
    draw()

edit_mode = ->
  mode = 'edit'
  
  template.selectAll "*"
    .remove()
  bgrect.attr "fill", "#e0e0e0"

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    downpoint = d3.mouse(this)
    downtime = new Date()
    moved = null

  svg.on 'mousemove', -> # 項目移動
    return unless downpoint
    return unless moving
    movepoint = d3.mouse(this)
    # clearTimeout modetimeout if dist(movepoint,downpoint) > 20.0
    # $('#searchtext').val("move-move selected = #{selected.length}")
    for element in selected
      attr = element.node().attributes
      x = 0.0
      y = 0.0
      for e in attr
        x = Number(e.value) if e.nodeName == 'xx' # 何故か文字列になってしまうことがあるため
        y = Number(e.value) if e.nodeName == 'yy'
      element.attr "transform", "translate(#{x+movepoint[0]-downpoint[0]},#{y+movepoint[1]-downpoint[1]})"

  svg.on 'mouseup', ->
    return unless downpoint
    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    if moving
      for element in selected
        attr = element.node().attributes
        x = 0.0
        y = 0.0
        for e in attr
          x = Number(e.value) if e.nodeName == 'xx'
          y = Number(e.value) if e.nodeName == 'yy'
        element.attr 'xx', x+uppoint[0]-downpoint[0]
        element.attr 'yy', y+uppoint[1]-downpoint[1]

    moved = [uppoint[0]-downpoint[0], uppoint[1]-downpoint[1]]
    moving = false
    downpoint = null
    clickedelement = null

    uptime = new Date()
    if uptime - downtime < 300
      if selected.length == 0
        selected = []
        strokes = []
        draw_mode()
      else
        for element in selected
          element.attr "stroke", linecolor
        selected = []

#
# 文字認識
# 
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
        ppoints = kstrokes[i]
        stroke = []
        stroke[0] = ppoints[0]
        stroke[1] = ppoints[ppoints.length-1]
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
        ppoints = kstrokes[i]
        stroke = []
        stroke[0] = ppoints[0]
        stroke[1] = ppoints[ppoints.length-1]
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
        totaldist += hypot dx, dy
        dx = kanji_strokes[i][1][0] - normalized_strokes[i][1][0]
        dy = kanji_strokes[i][1][1] - normalized_strokes[i][1][1]
        totaldist += hypot dx, dy
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
    if cand.text
      candelement.text cand.text

    candelement.on 'mousedown', ->
      d3.event.preventDefault()
      downpoint = d3.mouse(this)
      target = d3.event.target

      #
      # 文字認識に使った最初のストローク位置を得る
      # 
      xx = strokes[0][0][0]
      yy = strokes[0][0][1]
      #
      # Strokesを消す
      # 
      [0...strokes.length].forEach (i) ->
        element = elements.pop()
        element.remove()
      strokes = []
      #
      # 候補情報をコピーして描画領域に貼り付ける
      # 
      copied_element = svg.append target.nodeName # "text", "path", etc.
      for attr in target.attributes
        copied_element.attr attr.nodeName, attr.value
        if attr.nodeName == 'x'
          copied_element.attr 'x', xx
        if attr.nodeName == 'y'
          copied_element.attr 'y', yy
      if target.innerHTML
        copied_element.text target.innerHTML
        text = $('#searchtext').val()
        $('#searchtext').val text + target.innerHTML
      elements.push copied_element
      
      # マウスが横切ったら選択する
      copied_element.on 'mousemove', selfunc copied_element
    
      copied_element.on 'mousedown', ->
        clickedelement = copied_element
        moving = true

    candelement.on 'mouseup', ->
      return unless downpoint
      d3.event.preventDefault()
      downpoint = null
