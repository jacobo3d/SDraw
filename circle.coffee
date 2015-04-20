circlepath = (points) ->
  startx = points[0][0]
  starty = points[0][1]
  endx = points[1][0]
  endy = points[1][1]
  rx = points[2][0] - startx
  ry = points[3][1] - starty
  "M #{startx},#{starty} A #{rx},#{ry} 0 1,1 #{endx},#{endy} A #{rx},#{ry} 0 1,1 #{startx},#{starty} z"

circlerecog = (points, nstrokes, cands) ->    
  x = points.map (e) -> e[0]
  y = points.map (e) -> e[1]
  maxx = Math.max x...
  minx = Math.min x...
  maxy = Math.max y...
  miny = Math.min y...
  
      
  if nstrokes == 1 && maxx-minx > 50 && maxy-miny > 50 && dist(strokes[0][0], strokes[0][1]) < 40
    rx = (maxx - minx) / 2
    ry = (maxy - miny) / 2
    startx = minx - minx
    starty = 0 # miny + ry - miny
    endx = maxx - minx
    endy = 0 # ry # starty - miny

    points = [[startx, starty], [endx, endy], [startx+rx, starty-ry], [startx+rx, starty+ry]]
    cline = 
      strokes: [[[10, 10], [10, 80]], [[10, 10], [10, 80]]] # 嘘
      snappoints: [[0, 0], [maxx-minx, 0], [rx, 0]]
      type: 'path'
      attr:
        #      始点    半径 rot l swee 終点
        # d: "M #{startx},#{starty} A #{rx},#{ry} 0 1,1 #{endx},#{endy} A #{rx},#{ry} 0 1,1 #{startx},#{starty} z",
        d: circlepath points
        stroke: '#000000'
        fill: 'none'
        'stroke-width': 5
        points: JSON.stringify points
        # points: JSON.stringify [[startx, starty], [endx, endy], [startx+rx, starty-ry], [startx+rx, starty+ry]]
        name: 'circle'
    cands.push [cline, 0]
