// Generated by CoffeeScript 1.7.1
window.func1 = function() {
  return alert("func1");
};

window.hypot = function() {
  return alert("math.hypot");
};

window.rand = function(n) {
  return Math.round(Math.random() * n);
};

window.hypot = function(x, y) {
  return Math.sqrt(x * x + y * y);
};

window.dist = function(p1, p2) {
  return hypot(p1[0] - p2[0], p1[1] - p2[1]);
};
