# 方眼紙テンプレート
window.meshTemplate =
  params:
    meshsize: 40
    offset:
      x: 0
      y: 0
  draw: ->
    template.selectAll "polyline"
      .remove()
    template.selectAll "path"
      .remove()
    xsize = this.params.meshsize + this.params.offset.x
    if xsize > 1
      for i in [0.. drawWidth / (this.params.meshsize + this.params.offset.x)]
        drawline i * (this.params.meshsize + this.params.offset.x), 0,
          i * (this.params.meshsize + this.params.offset.x), drawHeight
    ysize = this.params.meshsize + this.params.offset.y
    if ysize > 1
      for i in [0.. drawHeight / (this.params.meshsize + this.params.offset.y)]
        drawline 0, i * (this.params.meshsize + this.params.offset.y),
          drawWidth, i * (this.params.meshsize + this.params.offset.y)
  change: (deltax, deltay) ->
    this.params.offset.x = deltax
    this.params.offset.y = deltay
    this.draw()
