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
# JSON出力
#
console.log JSON.stringify data
