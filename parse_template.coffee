# 透視図法テンプレート
window.parseTemplate =
  params:
    center:
      x: 800 / 2
      y: 600 / 2
    offset:
      x: 0
      y: 0
  draw: ->
    template.selectAll "*"
      .remove()
    for i in [0..72]
      degree = i * 5
      radian = degree * Math.PI / 180
      sin = Math.sin(radian)
      cos = Math.cos(radian)
      centerx = this.params.center.x + this.params.offset.x
      centery = this.params.center.y + this.params.offset.y
      drawline centerx, centery, centerx + cos * 1000, centery + sin * 1000
  change: (deltax, deltay) ->
    this.params.offset.x = deltax * 4
    this.params.offset.y = deltay * 4
    this.draw()

