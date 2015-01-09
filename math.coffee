#
# Math functions
#
window.rand = (n) -> Math.round Math.random() * n
window.hypot = (x, y) -> Math.sqrt(x * x + y * y)
window.dist = (p1, p2) ->
  hypot p1.x-p2.x, p1.y-p2.y
