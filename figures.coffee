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
    name: 'polyline'
    points: JSON.stringify [[10, 10], [10, 80], [80, 80]]
    
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
    name: 'polygon'
    points: JSON.stringify [[10, 10], [10, 80], [80, 80], [80, 10]]
    
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
    name: 'polygon'
    points: JSON.stringify [[10, 10], [10, 80], [160, 80], [160, 10]]
    
#
# 矩形波 square wave
#
data.push
  strokes: [
    [[10, 60], [40, 60]]
    [[40, 60], [40, 10]]
    [[40, 10], [70, 10]]
    [[70, 10], [70, 60]]
  ]
  snappoints: [
    [10, 60], [40, 60], [40, 10], [70, 10], [70, 60]
  ]
  type: 'path'
  attr:
    d: "M10,60L40,60L40,10L70,10L70,60",
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 5
    name: 'polyline'
    points: JSON.stringify [[10, 60], [40, 60], [40, 10], [70, 10], [70, 60]]
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
# 抵抗
#
data.push
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
    points: JSON.stringify [[0, 40], [15, 40], [20, 20], [30, 60], [40, 20], [50, 60], [60, 20], [70, 60], [75, 40],[90, 40]]
    
data.push
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
    [40, 0], [40, 90]
  ]
  type: 'path'
  attr:
    d: "M40,0L40,15L60,20L20,30L60,40L20,50L60,60L20,70L40,75L40,90"
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 2

#
# トランジスタ 
#
data.push
  strokes: [
    [[35, 18], [35, 62]]
    [[46, 18], [46, 62]]
    [[15, 40], [35, 40]]
    [[46, 18], [65, 18]]
    [[65, 18], [65, 5]]
    [[46, 62], [65, 62]]
    [[65, 62], [65, 75]]
  ]
  snappoints: [
    [15, 40], [65, 5], [65, 75]
  ]
  type: 'path'
  attr:
    d: "M35,18L35,62M46,18L46,62M15,40L35,40M46,18L65,18L65,5M46,62L65,62L65,75"
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 2
    
#
# グランド
#
data.push
  strokes: [
    [[0, 40], [70, 40]]
    [[0, 40], [15, 55]]
    [[15, 40], [30, 55]]
    [[30, 40], [45, 55]]
    [[45, 40], [60, 55]]
    [[60, 40], [75, 55]]
  ]
  snappoints: [
    [35, 40]
  ]
  type: 'path'
  attr:
    d: "M0,40L70,40M0,40L15,55M15,40L30,55M30,40L45,55M45,40L60,55M60,40L75,55"
    stroke: '#000000'
    fill: 'none'
    'stroke-width': 2
    
#
# JSON出力
#
console.log JSON.stringify data




