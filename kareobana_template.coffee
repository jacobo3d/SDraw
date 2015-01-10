#
# 枯尾花テンプレート
#
window.kareobanaTemplate =
  draw: ->
    template.selectAll "*"
      .remove()
    for x in [0..drawWidth / 80]
      for y in [0..drawHeight / 80]
        p2 = {x: x * 80, y: y * 80}
        p1 = {x: rand(drawWidth), y: rand(drawHeight)}
        while dist(p1,p2) < 50 || dist(p1,p2) > 150
          p1 = {x: rand(drawWidth), y: rand(drawHeight)}
        p3 = {x: rand(drawWidth), y: rand(drawHeight)}
        while dist(p3,p2) < 50 || dist(p3,p2) > 150 || dist(p1,p3) < 50 || dist(p1,p3) > 150
          p3 = {x: rand(drawWidth), y: rand(drawHeight)}
        drawpoints = [p1, p2, p3]
        template.append 'path'
          .attr
            stroke:         '#d0d0d0'
            'stroke-width': 3
            fill:           "none"
            d:              line drawpoints
  change: (deltax, deltay) ->
    this.draw()
