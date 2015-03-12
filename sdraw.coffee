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
duplicated = false # 複製操作の直後にtrueになる
linewidth = 10
linecolor = '#000000'

# SVGElement.getScreenCTM() とか使うべきなのかも

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
  if moved && duplicated
    clone moved[0]+30, moved[1]+30
  else
    clone 30, 30
  duplicated = true

$('#line1').on 'click', -> linewidth = 3
$('#line2').on 'click', -> linewidth = 10
$('#line3').on 'click', -> linewidth = 25
$('#color1').on 'click', -> linecolor = '#ffffff'
$('#color2').on 'click', -> linecolor = '#808080'
$('#color3').on 'click', -> linecolor = '#000000'

clone = (dx, dy) ->
  newselected = []
  for element in selected
    attr = element.node().attributes
    nodeName = element.property "nodeName"
    parent = d3.select element.node().parentNode

    cloned = parent.append nodeName
    for e in attr
      cloned.attr e.nodeName, e.value
    element.attr 'stroke', linecolor # コピー元の色を戻す
    cloned.x = element.x + dx
    cloned.y = element.y + dy
    cloned.snappoints = []
    cloned.snappoints[0] = element.snappoints[0].concat() # 複製を作る
    cloned.snappoints[1] = element.snappoints[1].concat()
    cloned.snappoints[0][0] += dx
    cloned.snappoints[0][1] += dy
    cloned.snappoints[1][0] += dx
    cloned.snappoints[1][1] += dy
    cloned.attr "transform", "translate(#{cloned.x},#{cloned.y})"
    cloned.text element.text() if nodeName == 'text'

    cloned.on 'mousedown', ->
      return unless mode == 'edit'
      clickedElement = setfunc cloned
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
        candimage = cand.append 'image'
          .attr
            'xlink:href': url
            x: 0
            y: 0
            width: 120
            height: 120
            preserveAspectRatio: "meet"
        candimag.x = 0
        candimag.y = 0
        candimage.on 'click', ->
          image = svg.append 'image'
            .attr
              'xlink:href': url
              x: 0
              y: 0
              width: 240
              height: 240
              preserveAspectRatio: "meet"

          iimage = image
          image.on 'mousedown', ->
            clickedElement = setfunc iimage
            downpoint = d3.mouse(this)
            moving = true
    
          # マウスが横切ったら選択する
          image.on 'mousemove', selfunc image  # クロージャ

          image.on 'mouseup', ->

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
setTemplate("template4", kareobanaTemplate4)

############################################################################
##
## ユーザによる線画お絵書き
## 
  
path = null

drawPath = (path) ->
  path.attr
    d:                line points
    stroke:           path.attr 'color'
    'stroke-width':   linewidth
    'stroke-linecap': "round"
    fill:             "none"
  path.x = 0
  path.y = 0

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

clickedElement = null # クリックされたパスや文字を覚えておく

draw_mode = ->
  mode = 'draw'
  moved = null
  duplicated = false

  strokes = []

  template.selectAll "*"
    .remove()
  elements.map (element) ->
    element.attr "stroke", element.attr('color')
    
  bgrect.attr "fill", "#ffffff"

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    
    downpoint = d3.mouse(this)
    downtime = new Date()
    clearTimeout resettimeout if resettimeout
    modetimeout = setTimeout -> # 500msじっとしてると編集モードになるとか
      selected = []
      path.remove()      # drawmodeで描いていた線を消す
      if clickedElement  # pathなどをクリックしてた場合は移動モードにする
        element = clickedElement()
        element.attr "stroke", "yellow"
        f = element.attr "fill"
        if f && f != "none"
          element.attr "fill", "yellow"
        selected.push element
        # moving = true !!!!!
      edit_mode()
    , 500
    
    path = svg.append 'path' # SVGのpath要素 (曲線とか描ける)
    path.attr "color", linecolor
    elements.push path
    points = [ downpoint ]

    ppath = path
    path.on 'mousedown', ->
      # return unless mode == 'edit'
      clickedElement = setfunc ppath
      downpoint = d3.mouse(this)
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
    drawPath path
    strokes.push [ downpoint, uppoint ]
    path.snappoints = [ downpoint, uppoint ] # スナッピングする点のリスト
    downpoint = null
    moving = false # ねんのため
    clickedElement = null

    recognition strokes

  svg.on 'mousemove', ->
    return unless downpoint
    movepoint = d3.mouse(this)
    clearTimeout modetimeout if dist(movepoint,downpoint) > 20.0
    d3.event.preventDefault()
    points.push movepoint
    drawPath path

snapdx = 0
snapdy = 0
  
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

  svg.on 'mousemove', -> # 選択項目移動
    return unless downpoint
    return unless moving
    movepoint = d3.mouse(this)
    #
    # スナッピング処理
    #
    d = dist movepoint, downpoint
    snapdx = 0
    snapdy = 0
    if d > 100
      points = []     # 移動オブジェクトの端点リスト
      refpoints = []  # それ以外のオブジェクトの端点リスト
      for element in elements
        if element.snappoints # 謎...
          if element in selected
            for snappoint in element.snappoints
              points.push [snappoint[0]+movepoint[0]-downpoint[0], snappoint[1]+movepoint[1]-downpoint[1]]
          else
            for snappoint in element.snappoints
              refpoints.push [snappoint[0], snappoint[1]]
      #  
      # 他のオブジェクトにスナッピング
      # 
      d = 10000000
      for point in points
        for refpoint in refpoints
          dd = dist point, refpoint
          if dd < d
            d = dd
            snapdx = point[0] - refpoint[0]
            snapdy = point[1] - refpoint[1]

    if Math.abs(snapdx) > 50 || Math.abs (snapdy) > 50
      snapdx = 0
      snapdy = 0
    for element in selected
      movex = element.x+movepoint[0]-downpoint[0]-snapdx
      movey = element.y+movepoint[1]-downpoint[1]-snapdy
      element.attr "transform", "translate(#{movex},#{movey})"

  svg.on 'mouseup', ->
    return unless downpoint
    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    if moving
      for element in selected
        element.x = element.x+uppoint[0]-downpoint[0] - snapdx
        element.y = element.y+uppoint[1]-downpoint[1] - snapdy

        if element.snappoints
          element.snappoints[0][0] += (uppoint[0]-downpoint[0]-snapdx)
          element.snappoints[0][1] += (uppoint[1]-downpoint[1]-snapdy)
          element.snappoints[1][0] += (uppoint[0]-downpoint[0]-snapdx)
          element.snappoints[1][1] += (uppoint[1]-downpoint[1]-snapdy)

      moved = [uppoint[0]-downpoint[0], uppoint[1]-downpoint[1]]
    moving = false
    downpoint = null
    clickedElement = null

    uptime = new Date()
    if uptime - downtime < 300
      duplicated = false
      if selected.length == 0
        selected = []
        strokes = []
        draw_mode()
      else
        for element in selected
          element.attr "stroke", element.attr('color') # 線分の色を戻す
          f = element.attr "fill"
          if f && f != "none"
            element.attr "fill", element.attr('color')   # 文字の色を戻す
        selected = []

#
# 文字認識 + 候補表示
# 
recognition = (strokes) ->
  cands = recognize strokes, window.kanjidata, window.figuredata

  # 候補表示
  [0..5].forEach (i) ->
    cand = cands[i]
    candsvg = d3.select "#cand#{i}"
    candsvg.selectAll "*"
      .remove()
    candelement = candsvg.append cand.type
    candelement.attr cand.attr
    if cand.snappoints
      candelement.snappoints = cand.snappoints
    if cand.text
      candelement.text cand.text
    # candelement.attr 'fill', 'black'
    candelement.attr 'color', 'black'

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
      copied_element.x = 0
      copied_element.y = 0
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
        clickedElement = setfunc copied_element
        selected.push copied_element
        moving = true

    candelement.on 'mouseup', ->
      return unless downpoint
      d3.event.preventDefault()
      downpoint = null
