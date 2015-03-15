#
# 文字認識
# 
$ ->
  $.getJSON "kanji/kanji.json", (data) ->
    window.kanjidata = data
  $.getJSON "figures.json", (data) ->
    window.figuredata = data

recognize = (strokes, points, strokedata...) -> # strokedataは可変個引数
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
  strokewidth = maxx - minx
  strokeheight = maxy - miny
  size = Math.max strokewidth, strokeheight
  normalized_strokes = []
  for stroke in strokes
    x0 = (stroke[0][0]-minx) * 1000.0 / size
    y0 = (stroke[0][1]-miny) * 1000.0 / size
    x1 = (stroke[1][0]-minx) * 1000.0 / size
    y1 = (stroke[1][1]-miny) * 1000.0 / size
    normalized_strokes.push [[x0, y0], [x1, y1]]

  cands = []
  #
  # 直線データは特別扱い
  #
  # 横一直線
  if nstrokes == 1 && strokewidth > 100 && strokeheight/strokewidth < 0.1
    hline = 
      strokes: [[[0, 0], [80, 0]], [[0, 0], [80, 0]]]
      snappoints: [[10, 40], [strokewidth, 40]]
      type: 'path'
      attr:
        d: "M10,40L#{strokewidth},40",
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 5
    cands.push [hline, 0]
  # 縦一直線
  if nstrokes == 1 && strokeheight > 100 && strokewidth/strokeheight < 0.1
    vline = 
      strokes: [[[10, 10], [10, 80]], [[10, 10], [10, 80]]]
      snappoints: [[40, 10], [40, strokeheight]]
      type: 'path'
      attr:
        d: "M40,10L40,#{strokeheight}",
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 5
    cands.push [vline, 0]

  # 円
  minx = 1000
  miny = 1000
  maxx = -1000
  maxy = -1000
  for point in points
    minx = point[0] if point[0] < minx
    miny = point[1] if point[1] < miny
    maxx = point[0] if point[0] > maxx
    maxy = point[1] if point[1] > maxy
  #alert "h=#{maxy-miny}, w=#{maxx-minx}, d=#{dist strokes[0][0], strokes[0][1]}"
  if nstrokes == 1 && maxx-minx > 50 && maxy-miny > 50 && dist(strokes[0][0], strokes[0][1]) < 40
    rx = (maxx - minx) / 2
    ry = (maxy - miny) / 2
    startx = minx
    starty = miny + ry
    endx = maxx
    endy = starty
    #alert "M #{startx},#{starty} A #{rx},#{ry} 0 1,1 #{endx},#{endy} A #{rx},#{ry} 0 1,1 #{startx},#{starty} z"
    cline = 
      strokes: [[[10, 10], [10, 80]], [[10, 10], [10, 80]]]
      snappoints: [[40, 10], [40, strokeheight]]
      type: 'path'
      attr:
        #      始点    半径 rot l swee 終点
        # d: "M 25,100 A 75,75 0 1,1 175,100 A 75,75 0 1,1 25,100 z",
        d: "M #{startx},#{starty} A #{rx},#{ry} 0 1,1 #{endx},#{endy} A #{rx},#{ry} 0 1,1 #{startx},#{starty} z",
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 5
    cands.push [cline, 0]

  #
  # 漢字/図形ストロークデータとマッチングをとる
  #
  for data in strokedata
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
      if entry.type == 'path'
        entry.scalex = strokewidth / width
        entry.scaley = strokeheight / height
      else
        entry.scalex = 1
        entry.scaley = 1
      strokes = []
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
  cands.sort (a,b) -> a[1] - b[1]
    .map (e) -> e[0]
