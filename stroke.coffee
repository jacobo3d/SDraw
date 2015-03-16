#
# 文字認識テスト
#
canvas = $('#canvas')

canvas.attr 'width', '500px'
canvas.attr 'height', '500px'

context = canvas[0].getContext('2d')

drawing = false

points = []
verocity = []
v2 = []

# vcanvas = $('#vcanvas')
# # vcanvas.attr 'width', '1000px'
# # vcanvas.attr 'height', '200px'
# vcanvas.css 'backgrond-color', '#ff0'
# vcontext = vcanvas[0].getContext('2d')

canvasX = canvas.offset()["left"]
canvasY = canvas.offset()["top"]
  
hypot = (x, y) ->
  Math.sqrt(x * x + y * y)
dist = (p1, p2) ->
  hypot p1[0]-p2[0], p1[1]-p2[1]

mousepos = (e) ->
  [x, y] =
    if 'touchstart' == e.type || 'touchmove' == e.type
      [e.originalEvent.changedTouches[0].pageX, e.originalEvent.changedTouches[0].pageY]
    else
      [e.pageX, e.pageY]

drawinterval = null
drawcount = 0
drawpoints = []
      
canvas.on 'touchstart mousedown', (e) ->
  e.preventDefault()
  [x, y] = mousepos e
  drawing = true
  points = [[x - canvasX, y - canvasY, e.timeStamp]]
  verocity = [0.0]
  v2 = [0.0]

  # drawinterval = setInterval vdraw, 100  # 速度を描く
  drawcount = 1
  drawpoints = [[x-canvasX, y-canvasY]]

canvas.on 'touchmove mousemove', (e) ->
  return unless drawing
  e.preventDefault()
  draw e  

draw = (e) ->
  [x, y] = mousepos e
  points.push [x - canvasX, y - canvasY, e.timeStamp]
  len = points.length
  cur = points[len-1]  # 最新の点
  pre = points[len-2]  # ひとつ前の点
  d = dist cur, pre
  v = d * 100.0 / (cur[2] - pre[2])
  $('#text').text v
  verocity.push v # verocity[] に速度をどんどんpushしていく
  # verocity = [10, 20, 100, 10, 3, 40, 90, ...] 正の値ばかりのはず
  len = verocity.length
  v2[len-2] = verocity[len-1] - verocity[len-2] # 2階差分
  
  context.lineJoin = "round"
  context.lineCap = "round"
  context.strokeStyle =
    if v2[len-2] > 0
      'rgb(255, 255, 0)'
    else
      'rgb(0, 0, 255)'
  context.lineWidth = 10
  context.beginPath()
  context.moveTo pre[0], pre[1]
  context.lineTo cur[0], cur[1]
  context.stroke()
  context.closePath()

canvas.on 'touchend mouseup', (e) ->
  e.preventDefault()
  draw e
  drawing = false

  # ここでストローク解析する
  i = 0
  ind = 0
  slow = true
  while true
    p0 = ipoint(i * 100)
    p1 = ipoint((i+1) * 100)
    d = dist p0, p1
    if d > 20
      slow = false
    if d < 30 && !slow
      context.fillStyle = "rgb(255,255,255)"
      context.fillRect p0[0]-7, p0[1]-7, 14, 14
      slow = true
    break if p1[2] < 0
    i += 1

ipoint = (t) ->  # ペンタッチからt時間後の位置を補間(interpolation)計算する
  torig = points[0][2]
  plen = points.length
  return [points[0][0], points[0][1], 0] if t == 0 || plen == 1
  return [points[plen-1][0], points[plen-1][1], -1] if points[plen-1][2] - torig < t
  ind = 0
  while true
    break if points[ind][2] - torig >= t
    ind += 1
  p1 = points[ind-1]
  p2 = points[ind]
  x = (p1[0] * ((p2[2]-torig) - t) + p2[0] * (t - (p1[2]-torig))) / (p2[2] - p1[2])
  y = (p1[1] * ((p2[2]-torig) - t) + p2[1] * (t - (p1[2]-torig))) / (p2[2] - p1[2])
  [x, y, ind]
  
#plog = -> # 100msごとに呼ばれる
#  drawpoints.push ipoint(drawcount * 100)
#  drawcount += 1

vdraw = -> # 100msごとに呼ばれる
  drawcount += 1
  plen = points.length
  return if points.length < 2
  vcontext.lineJoin = "round"
  vcontext.lineCap = "round"
  vcontext.strokeStyle = 'rgv(0, 0, 0)'
  vcontext.lineWidth = 2
  v = [0]
  for i in [0..drawcount-1]
    p0 = ipoint(i * 100)
    p1 = ipoint((i+1) * 100)
    d = dist p0, p1
    v.push d
  vcontext.fillStyle = '#fff'
  vcontext.fillRect 0, 0, 1000, 300
  
  vcontext.beginPath()
  for i in [0 .. v.length-2]
    vcontext.moveTo i*10, (200-v[i])
    vcontext.lineTo (i+1)*10, (200-v[i+1])
    vcontext.stroke()
  vcontext.closePath()
