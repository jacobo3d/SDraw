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
    'stroke-width': 5

#
# 座標 (L字)
#
data.push
  strokes: [
    [[0, 0], [0, 80]]
    [[0, 80], [80, 80]]
  ]
  snappoints: [
    [10, 10], [10, 80], [80, 80]
  ]
  type: 'path'
  attr:
    d: "M10,10L10,80L80,80",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
#
# 横線
#
data.push
  strokes: [
    [[0, 0], [80, 0]]
    [[0, 0], [80, 0]]
  ]
  snappoints: [
    [10, 40], [80, 40]
  ]
  type: 'path'
  attr:
    d: "M10,40L80,40",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
#
# 縦線
#
data.push
  strokes: [
    [[10, 10], [10, 80]]
    [[10, 10], [10, 80]]
  ]
  snappoints: [
    [40, 10], [40, 80]
  ]
  type: 'path'
  attr:
    d: "M40,10L40,80",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
#
# 矩形
#
data.push
  strokes: [
    [[10, 10], [10, 80]]
    [[10, 80], [80, 80]]
    [[80, 80], [80, 10]]
    [[80, 10], [10, 10]]
  ]
  snappoints: [
    [10, 10], [10, 80], [80, 80], [80, 10]
  ]
  type: 'path'
  attr:
    d: "M10,10L10,80L80,80L80,10Z",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
data.push
  strokes: [
    [[10, 10], [10, 80]]
    [[10, 80], [160, 80]]
    [[160, 80], [160, 10]]
    [[160, 10], [10, 10]]
  ]
  snappoints: [
    [10, 10], [10, 80], [160, 80], [160, 10]
  ]
  type: 'path'
  attr:
    d: "M10,10L10,80L160,80L160,10Z",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
#
# AND論理
#
# http://yamatyuu.net/computer/html/svg/arc.html
#
# <path d="M x1 y1 a r r start f1 f2 dx,dy"/>
# 円弧開始点:(x1,y1) r:半径 start:円弧開始角度(度) f1:[0の時180度以内の円弧、1の時180度以上の円弧]
# f2:[0の時反時計回り 1の時時計回り] dx=x2-x1,dy=y2-y1
#
data.push
  strokes: [  # バッテン
    [[0,  0], [80, 80]]
    [[80, 0], [0, 80]]
  ]
  snappoints: [
    [10, 25], [10, 55], [70, 40]
  ]
  type: 'path'
  attr:
    d: "M40,10a30,30,-90,0,1,0,60 M10,10L40,10M10,70L40,70M10,10L10,70"
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    
#
# JSON出力
#
console.log JSON.stringify data
