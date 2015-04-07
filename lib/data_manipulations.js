var underscore = require("underscore")._;


module.exports = [

  //
  //  Routing table
  //
  function() {
    var data = this;

    var traverse = function(obj, table, path_prefix, route_prefix) {
      underscore.each(obj._children, function(child_obj) {
        var child_obj_route = (child_obj.settings.route !== undefined ?
          child_obj.settings.route.replace(/(^\/|\/$)+/g, "") :
          null
        );

        if (child_obj_route === null) {
          child_obj_route = child_obj._base;
        }

        var path = path_prefix + child_obj._base;
        var route = route_prefix + (path == "index" ? "" : child_obj_route);
        var template = (child_obj.template || (obj.settings.children ?
          obj.settings.children.template :
          null
        )) || path;

        table[path] = {
          page_path: path,
          template_path: template,
          route: route
        };

        child_obj._path = path;
        child_obj._template = template;
        child_obj._route = route;

        if (child_obj._children) {
          var child_route_prefix = (
            child_obj.settings.children &&
            child_obj.settings.children.route_prefix ?
              child_obj.settings.children.route_prefix :
              route + "/"
          );

          traverse(
            child_obj,
            table,
            path + "/",
            child_route_prefix
          );
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
      underscore.each(obj._children, function(child_obj) {
        if (child_obj.settings.nav_index != null) {
          collection.push({
            idx: child_obj.settings.nav_index,
            route: child_obj._route,
            path: child_obj._path,
            title: child_obj.title,
            icon: child_obj.settings.icon
          });
        }

        if (child_obj._children) {
          traverse(child_obj, collection);
        }
      });
    };

    underscore.each(data._locales, function(l) {
      data[l].collections = data[l].collections || {};
      data[l].collections.navigation_items = [];

      traverse(
        data[l].pages,
        data[l].collections.navigation_items
      );

      // sort
      data[l].collections.navigation_items = underscore.sortBy(
        data[l].collections.navigation_items,
        function(n) { return n.idx; }
      );
    });
  }

];
