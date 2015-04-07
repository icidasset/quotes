module.exports.swallow_error = function(error) {
  console.log(error.toString());
  this.emit("end");
};


module.exports.basename = function(path) {
  var s = path.split("/");
  return s[s.length - 1].replace(/\.\w+/, "");
};


module.exports.traverse = function(obj, path_array) {
  var pointer = obj;

  for (var i=0, j=path_array.length; i<j; ++i) {
    pointer[path_array[i]] = pointer[path_array[i]] || { _flags: {} };
    pointer = pointer[path_array[i]];
  }

  return pointer;
};


module.exports.page_data = function(data_object, locale, page_path) {
  var d = data_object[locale].pages;

  page_path.split("/").forEach(function(s) {
    d = d[s];
  });

  return d;
};
