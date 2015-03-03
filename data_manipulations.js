var underscore = require("underscore")._;


module.exports = [

  //
  //  Routing table
  //
  function() {
    var data = this;

    var traverse = function(obj, table, path_prefix, route_prefix) {
      underscore.each(obj._children, function(c) {
        var child_obj = obj[c];
        var child_obj_route = (child_obj.route ? child_obj.route.replace(/(^\/|\/$)+/g, "") : null);
        var path = path_prefix + c;
        var route = route_prefix + (path == "index" ? "" : (child_obj_route || c));

        table[path] = {
          page_path: path,
          route: route
        };

        child_obj._path = path;
        child_obj._route = route;

        if (child_obj._children) {
          traverse(child_obj, table, path + "/", route + "/");
        }
      });
    };

    underscore.each(data._locales, function(l) {
      data[l]._routing_table = {};
      traverse(data[l].pages, data[l]._routing_table, "", "");
    });
  },


  //
  //  Navigation items
  //
  function() {
    var data = this;

    var traverse = function(obj, collection) {
      underscore.each(obj._children, function(c) {
        var child_obj = obj[c];

        if (child_obj._nav_index) {
          collection.push({
            idx: child_obj._nav_index,
            route: child_obj._route,
            path: child_obj._path,
            title: child_obj.title
          });
        }

        if (child_obj._children) {
          traverse(child_obj, collection);
        }
      });
    };

    underscore.each(data._locales, function(l) {
      data[l]._navigation_items = [];
      traverse(data[l].pages, data[l]._navigation_items);

      // sort
      data[l]._navigation_items = underscore.sortBy(data[l]._navigation_items, function(n) {
        return n.idx;
      });
    });
  }

];
