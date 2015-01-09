# 方眼紙テンプレート
window.meshTemplate =
  draw: ->
    template.selectAll "polyline"
      .remove()
    template.selectAll "path"
      .remove()
    for i in [0..20]
      drawline i * 40, 0, i * 40, browserHeight()
    for i in [0..20]
      drawline 0, i * 40, browserWidth(), i * 40
