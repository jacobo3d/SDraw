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
sizeframe = null          # 拡大/縮小フレーム
sizesquare = null

downpoint = null  # mousedown時の座標
movepoint = null
uppoint = null
downtime = null
uptime = null
movetime = null

elements = []     # 描画されたすべての要素列
selected = []     # 選択された要素列
points = []       # ストローク座標列
strokes = []      # 始点と終点の組の列
recogstrokes = []

moving = false    # 選択要素を移動中かどうか
zooming = false   # 拡大/縮小操作中かどうか
moved = null      # 移動操作したときの移動量 (繰り返しに使う)
duplicated = false # 複製操作の直後にtrueになる

linewidth = 10
fontsize = 50
linecolor = '#000000'

modetimeout = null    # 長押しで編集モードにするため
resettimeout = null   # 時間がたつと候補リセット

deletestate = 0 # 振ると削除するため
snapd = [0, 0]      # スナッピングするときの移動値
totaldist = 0
shakepoint = [0, 0]
zoomorig = [0, 0]     # 拡大/縮小するときの原点

clickedElement = null # クリックされたパスや文字を覚えておく

window.debug = (s) ->  $('#searchtext').val(s)
      
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
      if element in selected
        element.remove()
      else
        newelements.push element
        
    selected = []
    elements = newelements

  draw_mode()

$('#dup').on 'click', ->
  if moved && duplicated
    clone moved[0]+30, moved[1]+30
  else
    clone 30, 30
  duplicated = true

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
    if element.snappoints
      cloned.snappoints = element.snappoints.map (point) ->
        point.concat() # 複製を作る
      for snappoint in cloned.snappoints
        snappoint[0] += dx
        snappoint[1] += dy

    cpoints = JSON.parse(element.attr('origpoints')).map (point) ->
      [point[0]+dx, point[1]+dy]
    cloned.attr 'points', JSON.stringify cpoints
    cloned.attr 'origpoints', JSON.stringify cpoints
    cloned.attr 'd', elementpath element, cpoints

    cloned.text element.text() if nodeName == 'text'

    cloned.on 'mousedown', clickfunc cloned
      
    cloned.on 'mousemove', selfunc cloned
    
    cloned.on 'mouseup', ->
      
    newselected.push cloned
    elements.push cloned
    
  selected = newselected
  showframe()

$('#selectall').on 'click', ->
  svg.selectAll "*"
    .attr "stroke", "yellow"
  selected = elements
  showframe()
  edit_mode()
  
############################################################################
#
# 画像検索
#
imagesearch = -> 
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
        candimage.x = 0 # たぶん不要
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

$('#searchbutton').on 'click', imagesearch
$('#searchtext').on 'keydown', (e) ->
  imagesearch() if e.keyCode == 13

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
  .interpolate 'cardinal'  # 指定した点を通るスプライン
  .x (d) -> d[0]
  .y (d) -> d[1]

polyline = d3.svg.line()  # 普通のポリライン
  .x (d) -> d[0]
  .y (d) -> d[1]

polygon = (points) ->
  s = "M" +
    points.map (point) ->
      "#{point[0]},#{point[1]}"
    .join "L"
  res = s + "z"
  res

lines = (points) ->
  s = ""
  points.forEach (entry, ind) ->
    if ind % 2 == 0
      s += "M#{entry[0]},#{entry[1]}"
    else
      s += "L#{entry[0]},#{entry[1]}"
  s

elementpath = (element, points) ->
  switch element.attr 'name'
    when 'circle'
      circlepath points
    when 'polyline'
      polyline points
    when 'polygon'
      polygon points
    when 'lines'
      lines points
    else # なめらかな手書き曲線
      line points
      
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
## ユーザによる手書き線画お絵書き
## 
  
path = null

drawPath = (path) ->
  path.attr
    d:                line points
    stroke:           path.attr 'color'
    'stroke-width':   linewidth
    'stroke-linecap': "round"
    fill:             "none"
    points:           JSON.stringify points

#
# 描画エレメントを選択状態にする関数を返す関数
#
selfunc = (element) ->
  ->
    if mode == 'edit'
      return unless downpoint
      return if moving # 移動中は選択しない
      return if zooming # 拡大/縮小中も選択しない
      element.attr "stroke", "yellow"
      selected.push element unless element in selected
      showframe()

setfunc = (element) ->
  ->
    return element

clickfunc = (element) -> # 要素がクリックされたとき呼ばれる関数 クロージャ利用
  ->
    clickedElement = element
    if mode == 'edit'
      element.attr "stroke", "yellow"
      selected.push element unless element in selected
      showframe()
    downpoint = d3.mouse(this)
    moving = true

#
# 拡大/縮小
#

showframe = -> # 拡大/縮小用の枠表示
  hideframe()
  fpoints = []
  for element in selected
    for point in JSON.parse(element.attr('points'))
      fpoints.push point
  x = fpoints.map (e) -> e[0]
  y = fpoints.map (e) -> e[1]
  maxx = Math.max x...
  minx = Math.min x...
  maxy = Math.max y...
  miny = Math.min y...
  sizeframe = svg.append 'path'
  sizeframe.attr
    d: "M#{minx-5},#{miny-5}L#{minx-5},#{maxy+5}L#{maxx+5},#{maxy+5}L#{maxx+5},#{miny-5}Z"
    fill: 'none'
    'stroke': '#0000ff'
    'stroke-opacity': 0.5
    'stroke-width': 2
  sizesquare = svg.append 'path'
  sizesquare.attr
    d: "M#{maxx-10},#{maxy-10}L#{maxx-10},#{maxy+10}L#{maxx+10},#{maxy+10}L#{maxx+10},#{maxy-10}Z"
    fill: '#ff0000'
    'fill-opacity': 0.5
    
  sizesquare.on 'mousedown', ->
    downpoint = d3.mouse(this)
    zoomorig = [minx, miny]
    zooming = true
    moving = false

hideframe = ->
  sizeframe.remove() if sizeframe
  sizesquare.remove() if sizesquare

#
# 描画モード
# 
draw_mode = ->
  hideframe()
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

  svg.on 'touchstart', ->
    alert 'touchstart'
    
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
        element = clickedElement
        element.attr "stroke", "yellow"
        f = element.attr "fill"
        if f && f != "none"
          element.attr "fill", "yellow"
        selected.push element
        showframe()
        # moving = true !!!!!
        edit_mode()
    , 500
    
    path = svg.append 'path' # SVGのpath要素 (曲線とか描ける)
    path.attr "color", linecolor
    elements.push path
    points = [ downpoint ]

    path.on 'mousedown', clickfunc path
        
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
    resettimeout = setTimeout -> # 1.5秒じっとしていると候補を消す
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

      # pathを消す
      newelements = []
      for element in elements
        newelements.push element unless element == path
      elements = newelements
      
      element = clickedElement
      element.attr "stroke", "yellow"
      f = element.attr "fill"
      if f && f != "none"
        element.attr "fill", "yellow"
      selected.push element
      # moving = true !!!!!
      downpoint = null
      showframe()
      zooming = false
      edit_mode()
        
    # mouseup時にdrawPathすると端点が汚くなる。
    # 同じ点が続くとちゃんと描画してくれないのかもしれないので除いておく
    points.push uppoint
    # drawPath path

    recogstrokes = recogstrokes.concat(splitstroke(points))
    strokes.push [ downpoint, uppoint ]
    path.snappoints = [ downpoint, uppoint ] # スナッピングする点のリスト

    downpoint = null
    moving = false
    zooming = false
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

  for element in selected
    element.attr 'origpoints', (element.attr 'points')

  svg.on 'mousedown', ->
    d3.event.preventDefault()
    downpoint = d3.mouse(this)
    movepoint = downpoint
    downtime = d3.event.timeStamp
    moved = null
    totaldist = 0
    deletestate = 0
    shakepoint = downpoint
    
    for element in selected
      element.attr 'origpoints', (element.attr 'points')
    

  svg.on 'mousemove', -> # 選択項目移動
    return unless downpoint
    oldmovepoint = movepoint
    movepoint = d3.mouse(this)
    movetime = d3.event.timeStamp

    if zooming
      if downpoint
        scale = [
          (movepoint[0] - zoomorig[0]) / (downpoint[0] - zoomorig[0])
          (movepoint[1] - zoomorig[1]) / (downpoint[1] - zoomorig[1])
        ]
        for element in selected
          mpoints = JSON.parse(element.attr('origpoints')).map (point) ->
            [zoomorig[0] + (point[0]-zoomorig[0]) * scale[0], zoomorig[1] + (point[1]-zoomorig[1]) * scale[1]]
          element.attr 'points', JSON.stringify mpoints
          element.attr 'd', elementpath element, mpoints
        showframe()

    if moving
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
      snapd = [0, 0]
      if totaldist > 200
        mpoints = []     # 移動オブジェクトの端点リスト
        refpoints = []  # それ以外のオブジェクトの端点リスト
        for element in elements
          if element.snappoints # 謎...
            if element in selected
              for snappoint in element.snappoints
                mpoints.push [snappoint[0]+movepoint[0]-downpoint[0], snappoint[1]+movepoint[1]-downpoint[1]]
            else
              for snappoint in element.snappoints
                refpoints.push [snappoint[0], snappoint[1]]
        #  
        # 他のオブジェクトにスナッピング
        # 
        d = 10000000
        for point in mpoints
          for refpoint in refpoints
            dd = dist point, refpoint
            if dd < d
              d = dd
              snapd = [point[0] - refpoint[0], point[1] - refpoint[1]]
  
      if Math.abs(snapd[0]) > 50 || Math.abs (snapd[1]) > 50 # 遠いときはスナップしない
        snapd = [0, 0]
      for element in selected
        move = [
          movepoint[0]-downpoint[0]-snapd[0]
          movepoint[1]-downpoint[1]-snapd[1]
        ]
        mpoints = JSON.parse(element.attr('origpoints')).map (point) ->
          [point[0]+move[0], point[1]+move[1]]
        element.attr 'points', JSON.stringify mpoints
        element.attr 'd', elementpath element, mpoints

       showframe()

  svg.on 'mouseup', ->
    return unless downpoint

    d3.event.preventDefault()
    uppoint = d3.mouse(this)

    if zooming
      scale = [
        (uppoint[0] - zoomorig[0]) / (downpoint[0] - zoomorig[0])
        (uppoint[1] - zoomorig[1]) / (downpoint[1] - zoomorig[1])
      ]
      for element in selected
        element.snappoints = element.snappoints.map (point) ->
          [zoomorig[0] + (point[0]-zoomorig[0]) * scale[0], zoomorig[1] + (point[1]-zoomorig[1]) * scale[1]]
        upoints = JSON.parse(element.attr('origpoints')).map (point) ->
          [zoomorig[0] + (point[0]-zoomorig[0]) * scale[0], zoomorig[1] + (point[1]-zoomorig[1]) * scale[1]]
        element.attr 'points', JSON.stringify upoints
        element.attr 'origpoints', JSON.stringify upoints
        element.attr 'd', elementpath element, upoints
      
    if moving
      moved = [uppoint[0]-downpoint[0]-snapd[0], uppoint[1]-downpoint[1]-snapd[1]]
      for element in selected
        element.snappoints = element.snappoints.map (point) ->
          [point[0] + moved[0], point[1] + moved[1]]
        upoints = JSON.parse(element.attr('origpoints')).map (point) ->
          [point[0]+moved[0], point[1]+moved[1]]
        element.attr 'points', JSON.stringify upoints
        element.attr 'origpoints', JSON.stringify upoints
        element.attr 'd', elementpath element, upoints

    element.attr 'origpoints', (element.attr 'points')

    uptime = d3.event.timeStamp
    if uptime - downtime < 300 && !clickedElement
      duplicated = false
      if selected.length == 0
        selected = []
        strokes = []
        recogstrokes = []
        hideframe()
        draw_mode()
      else
        for element in selected
          element.attr "stroke", element.attr('color') # 線分の色を戻す
          f = element.attr "fill"
          if f && f != "none"
            element.attr "fill", element.attr('color')   # 文字の色を戻す
        selected = []
        hideframe()
        draw_mode() # 選択物がなくなったら描画モードに戻してみる

    downpoint = null
    moving = false
    zooming = false
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

    scalex = cand.scalex ? 1
    scaley = cand.scaley ? 1
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
      x = flatten(recogStrokes).map (p) -> p[0]
      minx = Math.min x...
      y = flatten(recogStrokes).map (p) -> p[1]
      miny = Math.min y...

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
      for attr in target.attributes
        copiedElement.attr attr.nodeName, attr.value
        if attr.nodeName == 'snappoints'
          copiedElement.snappoints = JSON.parse(attr.value)
      copiedElement.attr 'font-size', fontsize
      copiedElement.attr 'stroke-width', linewidth if target.nodeName != 'text'
      if target.nodeName == 'path'
        for snappoint in copiedElement.snappoints
          snappoint[0] *= scalex
          snappoint[1] *= scaley
          snappoint[0] += minx
          snappoint[1] += miny
          copiedElement.attr "stroke-width", linewidth
        copiedElement.attr 'stroke', linecolor
        copiedElement.attr 'color', linecolor
        points = JSON.parse(copiedElement.attr('points')).map (point) ->
          z = [minx + point[0] * scalex, miny + point[1] * scaley]
        copiedElement.attr 'points', JSON.stringify points
        copiedElement.attr 'd', elementpath copiedElement, points

      if target.nodeName == 'text'
        for snappoint in copiedElement.snappoints
          snappoint[0] += minx
          snappoint[1] += miny
      if target.innerHTML
        copiedElement.text target.innerHTML
        text = $('#searchtext').val()
        $('#searchtext').val text + target.innerHTML
      elements.push copiedElement
      
      # マウスが横切ったら選択する
      copiedElement.on 'mousemove', selfunc copiedElement

      copiedElement.on 'mousedown', clickfunc copiedElement
        
      strokes = []
      recogstrokes = []

    candElement.on 'mousedown', candselfunc
    if ! cand.text
      candsvg.on 'mousedown', candselfunc

    candElement.on 'mouseup', ->
      return unless downpoint
      d3.event.preventDefault()
      downpoint = null
