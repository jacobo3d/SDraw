# 透視図法テンプレート
window.parseTemplate =
  draw: ->
    template.selectAll "polyline"
      .remove()
    template.selectAll "path"
      .remove()
    for i in [-20..20]
      drawline 10, 300, browserWidth(), 300 + i * 50

