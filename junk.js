// Generated by CoffeeScript 1.7.1
var func,
  __slice = [].slice;

func = function() {
  var data, strokedata, _i, _len, _results;
  strokedata = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  _results = [];
  for (_i = 0, _len = strokedata.length; _i < _len; _i++) {
    data = strokedata[_i];
    _results.push(console.log(data));
  }
  return _results;
};

func(10, 20, 30);
