#
# Math functions
#
window.rand = (n) -> Math.round Math.random() * n
window.hypot = (x, y) -> Math.sqrt(x * x + y * y)
window.dist = (p1, p2) ->
  hypot p1[0]-p2[0], p1[1]-p2[1]
