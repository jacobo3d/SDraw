#
# ストローク分割
#

splitstroke = (points)->
  return [] if !points || points.length == 0
  splitstrokes = []
  pre = points[0]
  t = 0 # tミリセカンド時の位置
  slow = true
  while true
    p0 = ipoint(points, t)
    p1 = ipoint(points, t+100)
    d = dist p0, p1
    if d > 10
      slow = false
    else
      if d < 30 && !slow
        splitstrokes.push [pre, p0]
        pre = p0
        slow = true
    if p1[2] < 0
      #if splitstrokes.length == 0 # インチキ
      #  splitstrokes = [[points[0], p0]]
      break
    t += 100
  if splitstrokes.length == 0 # インチキ
    splitstrokes = [[points[0], p0]]
  splitstrokes

ipoint = (points, t) ->  # ペンタッチからt時間後の位置を補間(interpolation)計算する
  torig = points[0][2]
  plen = points.length
  return [points[0][0], points[0][1], 0] if t == 0 || plen < 2
  return [points[plen-1][0], points[plen-1][1], -1] if points[plen-1][2] - torig < t
  ind = 0
  alert "ZZZZZZ" unless points[ind]
  while points[ind]
    break if points[ind][2] - torig >= t
    ind += 1
  p1 = points[ind-1]
  p2 = points[ind]
  x = (p1[0] * ((p2[2]-torig) - t) + p2[0] * (t - (p1[2]-torig))) / (p2[2] - p1[2])
  y = (p1[1] * ((p2[2]-torig) - t) + p2[1] * (t - (p1[2]-torig))) / (p2[2] - p1[2])
  [x, y, ind]
