#
# 文字認識
#
$ ->
  $.getJSON "kanji/kanji.json", (data) ->
    window.kanjidata = data
  $.getJSON "data/figures.json", (data) ->
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
      snappoints: [[0, 0], [strokewidth, 0]]
      type: 'path'
      attr:
        d: "M10,40L#{strokewidth},40",
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 5
        name: 'lines'
        points: JSON.stringify [[0, 0], [strokewidth, 0]]
    cands.push [hline, 0]

    register =
      strokes: [
        [[0, 40], [15, 40]]
        [[15, 40], [20, 20]]
        [[20, 20], [30, 60]]
        [[30, 60], [40, 20]]
        [[40, 20], [50, 60]]
        [[50, 60], [60, 20]]
        [[60, 20], [70, 60]]
        [[70, 60], [75, 40]]
        [[75, 40], [90, 40]]
      ]
      snappoints: [
        [0, 40], [90, 40]
      ]
      type: 'path'
      attr:
        d: "M0,40L15,40L20,20L30,60L40,20L50,60L60,20L70,60L75,40L90,40"
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 2
        name: 'polyline'
        points: JSON.stringify [
          [0, 40],
          [(15 * strokewidth) / 90, 40]
          [(20 * strokewidth) / 90, 20]
          [(30 * strokewidth) / 90, 60]
          [(40 * strokewidth) / 90, 20]
          [(50 * strokewidth) / 90, 60]
          [(60 * strokewidth) / 90, 20]
          [(70 * strokewidth) / 90, 60]
          [(75 * strokewidth) / 90, 40]
          [(90 * strokewidth) / 90, 40]
        ]
    cands.push [register, 1]

  # 縦一直線
  if nstrokes == 1 && strokeheight > 100 && strokewidth/strokeheight < 0.1
    vline =
      strokes: [[[10, 10], [10, 80]], [[10, 10], [10, 80]]]
      snappoints: [[0, 0], [0, strokeheight]]
      type: 'path'
      attr:
        d: "M40,10L40,#{strokeheight}",
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 2
        name: 'lines'
        points: JSON.stringify [[0, 0], [0, strokeheight]]
    cands.push [vline, 0]

    register =
      strokes: [
        [[40, 0], [40, 15]]
        [[40, 15], [60, 20]]
        [[60, 20], [20, 30]]
        [[20, 30], [60, 40]]
        [[60, 40], [20, 50]]
        [[20, 50], [60, 60]]
        [[60, 60], [20, 70]]
        [[20, 70], [40, 75]]
        [[40, 75], [40, 90]]
      ]
      snappoints: [
        [40, 0], [40, strokeheight]
      ]
      type: 'path'
      attr:
        d: "M40,0L40,15L60,20L20,30L60,40L20,50L60,60L20,70L40,75L40,90"
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 2
        name: 'polyline'
        points: JSON.stringify [
          [40, (strokeheight * 0) / 90]
          [40, (strokeheight * 15) / 90]
          [60, (strokeheight * 20) / 90]
          [20, (strokeheight * 30) / 90]
          [60, (strokeheight * 40) / 90]
          [20, (strokeheight * 50) / 90]
          [60, (strokeheight * 60) / 90]
          [20, (strokeheight * 70) / 90]
          [40, (strokeheight * 75) / 90]
          [40, (strokeheight * 90) / 90]
        ]
    cands.push [register, 1]

  # 円の認識
  circlerecog points, nstrokes, cands

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
