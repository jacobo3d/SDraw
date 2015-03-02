#
# 枯尾花テンプレート4
#
window.kareobanaTemplate4 =
  draw: ->
    template.selectAll "*"
      .remove()
    for i in [0..200]
      p1 = [rand(drawWidth), rand(drawHeight)]
      p2 = [rand(drawWidth), rand(drawHeight)]
      while dist(p1,p2) < 20 || dist(p1,p2) > 30
        p2 = [rand(drawWidth), rand(drawHeight)]
      template.append 'path'
        .attr
          stroke:         '#d0d0d0'
          'stroke-width': 3
          fill:           "none"
          d:              line [p1, p2]
  change: (deltax, deltay) ->
    this.draw()
