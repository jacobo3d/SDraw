##
## S-Draw: Suggestive-Supportive-Snapping Drawing
##
## Toshiyuki Masui 2015/01/08 21:02:36
##

# 描画要素の色は path.attr 'color' で覚えておく

# 
# グローバル変数は window.xxxx みたいに指定する
# このファイル中のみのグローバル変数は関数定義の外で初期化しておく
#
body = d3.select "body" # body = d3.select("body").style({margin:0, padding:0}), etc.
svg =  d3.select "svg"
bgrect = svg.append 'rect'

downpoint = null  # mousedown時の座標
movepoint = null
uppoint = null
elements = []     # 描画された要素列
selected = []     # 選択された要素列
points = []       # ストローク座標列
strokes = []      # 始点と終点の組の列
recogstrokes = []
moving = false    # 選択要素を移動中かどうか
moved = null      # 移動操作したときの移動量 (繰り返しに使う)
duplicated = false # 複製操作の直後にtrueになる
linewidth = 10
fontsize = 50
linecolor = '#000000'

modetimeout = null    # 長押しで編集モードにするため
resettimeout = null   # 時間がたつと候補リセット
downtime = null
deletestate = 0 # 振ると削除するため
snapdx = 0
snapdy = 0
totaldist = 0
shakepoint = [0, 0]
  
clickedElement = null # クリックされたパスや文字を覚えておく

window.debug = (s) ->
  $('#searchtext').val(s)
      
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
    #nselected = selected.length
    #nelements = elements.length
    # for element in elements
    #  newelements.push element unless element in selected
    #for element in selected
    #  element.remove()
    for element in elements
      if element in selected
        element.remove()
      else
        newelements.push element
        
    selected = []
    elements = newelements
    # debug "#{nelements},  #{nselected}, #{elements.length}"
    #if elements.length == 0
    #  draw_mode()
    # 
    #else
    #  alert elements.length        ****** おかしい
  draw_mode()

$('#dup').on 'click', ->
  if moved && duplicated
    clone moved[0]+30, moved[1]+30
  else
    clone 30, 30
  duplicated = true

$('#line1').on 'click', ->
  draw_mode()
  linewidth = 4
  fontsize = 30
$('#line2').on 'click', ->
  draw_mode()
  linewidth = 10
  fontsize = 50
$('#line3').on 'click', ->
  draw_mode()
  linewidth = 20
  fontsize = 80
$('#color1').on 'click', ->
  draw_mode()
  linecolor = '#ffffff'
$('#color2').on 'click', ->
  draw_mode()
  linecolor = '#808080'
$('#color3').on 'click', ->
  draw_mode()
  linecolor = '#000000'

pen =  d3.select "#pen"
pen.on 'mousedown', ->
  downpoint = d3.mouse(this)
  if downpoint[0] >= 140
    $('#penbg').attr 'src', "pen3.png"
    linecolor = '#000000'
  if downpoint[0] > 110 && downpoint[0] < 140
    $('#penbg').attr 'src', "pen2.png"
    linecolor = '#808080'
  if downpoint[0] > 80 && downpoint[0] < 110
    $('#penbg').attr 'src', "pen1.png"
    linecolor = '#ffffff'
  if downpoint[0] > 50 && downpoint[0] < 80
    $('#pentop1').attr 'src', "pentop2.png"
    $('#pentop2').attr 'src', "pentop2.png"
    $('#pentop3').attr 'src', "pentop1.png"
    linewidth = 20
    fontsize = 80
  if downpoint[0] > 25 && downpoint[0] < 50
    $('#pentop1').attr 'src', "pentop2.png"
    $('#pentop2').attr 'src', "pentop1.png"
    $('#pentop3').attr 'src', "pentop2.png"
    linewidth = 10
    fontsize = 50
  if downpoint[0] > 0 && downpoint[0] < 25
    $('#pentop1').attr 'src', "pentop1.png"
    $('#pentop2').attr 'src', "pentop2.png"
    $('#pentop3').attr 'src', "pentop2.png"
    linewidth = 4
    fontsize = 30
  downpoint = null

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
    cloned.scalex = element.scalex
    cloned.scaley = element.scaley
    if element.snappoints
      cloned.snappoints = element.snappoints.map (point) ->
        point.concat() # 複製を作る
      for snappoint in cloned.snappoints
        snappoint[0] += dx
        snappoint[1] += dy
    cloned.attr "transform", "translate(#{cloned.x},#{cloned.y}) scale(#{cloned.scalex},#{cloned.scaley})"
    cloned.text element.text() if nodeName == 'text'

    ccloned = cloned
    cloned.on 'mousedown', ->
      #return unless mode == 'edit'
      clickedElement = setfunc ccloned
      # 編集中にクリックしたものは選択する
      if mode == 'edit'
        ccloned.attr "stroke", "yellow"
        selected.push ccloned unless ccloned in selected
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
# 画像検索
#
candsearch = -> 
  query = $('#searchtext').val()
  if query.length > 0
    # flickr_search query, (data) ->   # Flickr検索
    bing_search query, (data) ->       # Bing検索
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
        candimage.x = 0
        candimage.y = 0
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

draw_mode = ->
  mode = 'draw'
  moved = null
  duplicated = false
  deletestate = 0

  strokes = []
  recogstrokes = []

  template.selectAll "*"
    .remove()
  elements.map (element) ->
    element.attr "stroke", element.attr('color')
    
  bgrect.attr "fill", "#ffffff"

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    
    downpoint = d3.mouse(this)
    downtime = d3.event.timeStamp
    downpoint.push downtime
    clearTimeout resettimeout if resettimeout
    modetimeout = setTimeout -> # 500msじっとしてると編集モードになるとか
      if clickedElement  # pathなどをクリックしてた場合は移動モードにする
        selected = []
        path.remove()      # drawmodeで描いていた線を消す
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

      # 編集中にクリックしたものは選択する
      if mode == 'edit'
        ppath.attr "stroke", "yellow"
        selected.push ppath unless ppath in selected
      
      downpoint = d3.mouse(this)
      moving = true
        
    # マウスが横切ったら選択する
    path.on 'mousemove', selfunc path  # クロージャ
    
    path.on 'mouseup', ->

  svg.on 'mouseup', ->
    return unless downpoint
    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    uptime = d3.event.timeStamp
    uppoint.push uptime
    clearTimeout modetimeout if modetimeout
    clearTimeout resettimeout if resettimeout
    resettimeout = setTimeout -> # 2秒じっとしていると候補を消す
      strokes = []
      recogstrokes = []
      points = []
      [0..7].forEach (i) ->
        candsvg = d3.select "#cand#{i}"
        candsvg.selectAll "*"
          .remove()
    , 1500

    if clickedElement && uptime-downtime < 300 && dist(uppoint,downpoint) < 20
      selected = []
      path.remove()      # drawmodeで描いていた線を消す

      ##### pathを消す
      newelements = []
      for element in elements
        newelements.push element unless element == path
      elements = newelements
      
      element = clickedElement()
      element.attr "stroke", "yellow"
      f = element.attr "fill"
      if f && f != "none"
        element.attr "fill", "yellow"
      selected.push element
      # moving = true !!!!!
      edit_mode()
        
    # mouseup時にdrawPathすると端点が汚くなる。
    # 同じ点が続くとちゃんと描画してくれないのかもしれないので除いておく
    points.push uppoint
    # drawPath path

    recogstrokes = recogstrokes.concat(splitstroke(points))
    strokes.push [ downpoint, uppoint ]
    
    path.snappoints = [ downpoint, uppoint ] # スナッピングする点のリスト
    path.scalex = 1
    path.scaley = 1
    downpoint = null
    moving = false # ねんのため
    clickedElement = null

    recognition recogstrokes

  svg.on 'mousemove', ->
    return unless downpoint
    movepoint = d3.mouse(this)
    movetime = d3.event.timeStamp
    movepoint.push movetime
    clearTimeout modetimeout if dist(movepoint,downpoint) > 20.0
    d3.event.preventDefault()
    points.push movepoint
    drawPath path

edit_mode = ->
  mode = 'edit'
  deletestate = 0
  shakepoint = downpoint
  
  template.selectAll "*"
    .remove()
  bgrect.attr "fill", "#c0c0c0"

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    downpoint = d3.mouse(this)
    movepoint = downpoint
    # downtime = new Date()
    downtime = d3.event.timeStamp
    moved = null
    totaldist = 0
    deletestate = 0
    shakepoint = downpoint

  svg.on 'mousemove', -> # 選択項目移動
    return unless downpoint
    return unless moving
    oldmovepoint = movepoint
    movepoint = d3.mouse(this)
    movetime = d3.event.timeStamp
    #
    # 削除ジェスチャ取得
    #
    switch deletestate
      when 0
        if movepoint[0] - shakepoint[0] > 30
          deletestate = 1
          shakepoint = movepoint
      when 1
        if shakepoint[0] - movepoint[0] > 30
          deletestate = 2
          shakepoint = movepoint
      when 2
        if movepoint[0] - shakepoint[0] > 30
          deletestate = 3
          shakepoint = movepoint
      when 3
        if shakepoint[0] - movepoint[0] > 30 && movetime - downtime < 2000
          # 削除!
          newelements = []
          for element in elements
            newelements.push element unless element in selected
          for element in selected
            element.remove()
          selected = []
          elements = newelements
          draw_mode()
    
    totaldist += dist movepoint, oldmovepoint
    #
    # スナッピング処理
    #
    # d = dist movepoint, downpoint
    snapdx = 0
    snapdy = 0
    if totaldist > 200
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

    if Math.abs(snapdx) > 50 || Math.abs (snapdy) > 50 # 遠いときはスナップしない
      snapdx = 0
      snapdy = 0
    for element in selected
      movex = element.x+movepoint[0]-downpoint[0]-snapdx
      movey = element.y+movepoint[1]-downpoint[1]-snapdy
      element.attr "transform", "translate(#{movex},#{movey}) scale(#{element.scalex ? 1},#{element.scaley ? 1})"
      #alert element.attr('scalex')
              
  svg.on 'mouseup', ->
    return unless downpoint

    d3.event.preventDefault()
    uppoint = d3.mouse(this)
    if moving
      moved = [uppoint[0]-downpoint[0]-snapdx, uppoint[1]-downpoint[1]-snapdy]
      for element in selected
        element.x += moved[0]
        element.y += moved[1]

        if element.snappoints
          for snappoint in element.snappoints
            snappoint[0] += moved[0]
            snappoint[1] += moved[1]

    moving = false
    downpoint = null

    # uptime = new Date()
    uptime = d3.event.timeStamp
    if uptime - downtime < 300 && !clickedElement
      duplicated = false
      if selected.length == 0
        selected = []
        strokes = []
        recogstrokes = []
        draw_mode()
      else
        for element in selected
          element.attr "stroke", element.attr('color') # 線分の色を戻す
          f = element.attr "fill"
          if f && f != "none"
            element.attr "fill", element.attr('color')   # 文字の色を戻す
        selected = []
        draw_mode() # 選択物がなくなったら描画モードに戻してみる
     
    clickedElement = null

#
# 文字/ストローク認識 + 候補表示
# 
recognition = (recogStrokes) ->
  # 認識アルゴリズムを読んで候補を得る
  #cands = recognize recogStrokes, points, window.kanjidata, window.figuredata
  cands = recognize recogStrokes, points, window.figuredata

  # 候補表示
  [0..7].forEach (i) ->
    cand = cands[i]
    candsvg = d3.select "#cand#{i}"
    candsvg.selectAll "*"
      .remove()
    candElement = candsvg.append cand.type
    candElement.attr cand.attr
    if cand.snappoints
      # candElement.snappoints = cand.snappoints # 何故これで駄目なのかわからない
      candElement.attr 'snappoints', JSON.stringify(cand.snappoints)
    if cand.text
      candElement.text cand.text
    # candElement.attr 'fill', 'black'
    candElement.attr 'color', 'black'

    scalexx = cand.scalex ? 1
    scaleyy = cand.scaley ? 1
    candselfunc = ->
      d3.event.preventDefault()
      downpoint = d3.mouse(this)
      target = d3.event.target

      # 候補文字/ストロークの背景svgをクリックしたときは
      # 候補本体を選ぶようにする
      if target.nodeName == 'svg'
        target = target.childNodes[0]

      #
      # 文字認識に使った最初のストローク位置を得る
      #
      xx = 1000
      yy = 1000
      for stroke in recogStrokes
        for point in stroke
          xx = point[0] if point[0] < xx
          yy = point[1] if point[1] < yy
      #
      # Strokesを消す
      #
      [0...strokes.length].forEach (i) ->
        element = elements.pop()
        element.remove()
      #
      # 候補情報をコピーして描画領域に貼り付ける
      #
      copiedElement = svg.append target.nodeName # "text", "path", etc.
      copiedElement.x = 0
      copiedElement.y = 0
      for attr in target.attributes
        copiedElement.attr attr.nodeName, attr.value
        if attr.nodeName == 'snappoints'
          copiedElement.snappoints = JSON.parse(attr.value)
      copiedElement.attr 'x', xx  # コピー先の位置
      copiedElement.attr 'y', yy
      copiedElement.attr 'font-size', fontsize
      copiedElement.attr 'stroke-width', linewidth if target.nodeName != 'text'
      # if copiedElement.property("nodeName") == 'path'
      if target.nodeName == 'path'
        copiedElement.attr "transform", "translate(#{xx},#{yy}) scale(#{scalexx},#{scaleyy})"
        for snappoint in copiedElement.snappoints
          snappoint[0] *= scalexx
          snappoint[1] *= scaleyy
          snappoint[0] += xx
          snappoint[1] += yy
        copiedElement.attr "stroke-width", linewidth / scalexx
        copiedElement.x = xx
        copiedElement.y = yy
        copiedElement.attr 'stroke', linecolor
        copiedElement.attr 'color', linecolor

      if target.nodeName == 'text'
        for snappoint in copiedElement.snappoints
          snappoint[0] += xx
          snappoint[1] += yy
      copiedElement.attr 'scalex', scalexx
      copiedElement.scalex = scalexx
      copiedElement.attr 'scaley', scaleyy
      copiedElement.scaley = scaleyy
      if target.innerHTML
        copiedElement.text target.innerHTML
        text = $('#searchtext').val()
        $('#searchtext').val text + target.innerHTML
      elements.push copiedElement
      ## copiedElement.snappoints = target.snappoints ########!!!!!!
      
      # マウスが横切ったら選択する
      copiedElement.on 'mousemove', selfunc copiedElement

      ce = copiedElement
      copiedElement.on 'mousedown', ->
        clickedElement = setfunc ce # copiedElement
        ce.attr "stroke", "yellow"
        selected.push ce unless ce in selected
        moving = true
        
      strokes = []
      recogstrokes = []

    candElement.on 'mousedown', candselfunc
    #if cand.type == 'path'
    if ! cand.text
      candsvg.on 'mousedown', candselfunc

    candElement.on 'mouseup', ->
      return unless downpoint
      d3.event.preventDefault()
      downpoint = null
