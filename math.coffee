#
# Math functions
#

# Mersenne Twisterを使ってシードつき乱数を利用
#
mt = null

# Merenneめっちゃ遅い?
window.srand = (n) ->
  # mt = new MersenneTwister(n % 100)

window.rand = (n) ->
  Math.floor Math.random() * n
  # window.srand Number(new Date()) unless mt
  # mt.random()

# window.rand = (n) -> Math.round Math.random() * n

window.hypot = (x, y) -> Math.sqrt(x * x + y * y)
window.dist = (p1, p2) -> Math.hypot p1[0]-p2[0], p1[1]-p2[1]
