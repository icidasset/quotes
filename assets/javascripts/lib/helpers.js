export default {

  traverse_object: function(path, obj, split_by) {
    var split = path.split(split_by || "/");
    var pointer = obj;

    for (var i=0, j=split.length; i<j; ++i) {
      pointer = pointer[split[i]];
    }

    return pointer;
  },


  get_template: function(path) {
    return this.traverse_object(path, App.templates);
  },


  get_parents: function(el) {
    var parents = [];
    var p = el.parentNode;

    while (p !== null) {
      var o = p;
      parents.push(o);
      p = o.parentNode;
    }

    return parents;
  },
  

  random_number: function(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
  }

};
