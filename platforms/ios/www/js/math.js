var mt;

mt = null;

window.srand = function(n) {};

window.rand = function(n) {
  return Math.floor(Math.random() * n);
};

window.hypot = function(x, y) {
  return Math.sqrt(x * x + y * y);
};

window.dist = function(p1, p2) {
  return Math.hypot(p1[0] - p2[0], p1[1] - p2[1]);
};

window.flatten = function(a) {
  return a.reduce(function(l, r) {
    return l.concat(r);
  });
};
