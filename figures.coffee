# -*- coding: utf-8 -*-
#
# こういう図形の端点(strokesのポイント)にスナップするようにすればいいのだと思う。
#

data = []

#
# バッテン
#
data.push
  strokes: [
    [[0,  0], [80, 80]]
    [[80, 0], [0, 80]]
  ]
  snappoints: [
    [10, 10], [80, 80], [80, 10], [10, 80]
  ]
  type: 'path'
  attr:
    d: "M10,10L80,80M80,10L10,80"
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 3

#
# 座標 (L字)
#
data.push
  strokes: [
    [[0, 0], [0, 80]]
    [[0, 80], [80, 80]]
  ]
  snappoints: [
    [0, 0], [0, 80], [80, 80]
  ]
  type: 'path'
  attr:
    d: "M10,10L10,80L80,80",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 3
    
#
# AND
#
# http://yamatyuu.net/computer/html/svg/arc.html
#
# <path d="M x1 y1 a r r start f1 f2 dx,dy"/>
# 円弧開始点:(x1,y1) r:半径 start:円弧開始角度(度) f1:[0の時180度以内の円弧、1の時180度以上の円弧]
# f2:[0の時反時計回り 1の時時計回り] dx=x2-x1,dy=y2-y1
#
data.push
  strokes: [
    [[0,  0], [80, 80]]
    [[80, 0], [0, 80]]
  ]
  snappoints: [
    [40, 0], [40, 80]
  ]
  type: 'path'
  attr:
    # d: "M 40,0 a 40 40 -90 0 1 0,80"
    #d: "M40,0a40,40,-90,0,1,0,80M0,0L40,0M0,80L40,80M0,0L0,80"
    d: "M40,10a30,30,-90,0,1,0,60 M10,10L40,10M10,70L40,70M10,10L10,70"
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
#
# JSON出力
#
console.log JSON.stringify data
