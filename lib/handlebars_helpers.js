(function(root) {

if (typeof define === "function" && define.amd) {
  define([], factory);
} else if (typeof exports === "object") {
  module.exports = factory();
} else {
  root.HandlebarsHelpers = factory();
}



function path_to_root_prefix(current_route) {
  if (!current_route || current_route.length === 0) {
    return "";
  } else {
    var split = current_route.split("/");
    var path_prefix = "";

    for (var i=0, j=split.length; i<j; ++i) {
      if (split[i] !== "") path_prefix += "../";
    }

    return path_prefix;
  }
}


function remove_double_slashes(str) {
  return str.replace(/\/{2,}/g, "/");
}


function get_route(route, context) {
  return route == null || typeof route !== "string" ? context._route : route;
}



function factory() { return {


  //
  //  Path helpers
  //
  relative_path: function(path, current_route) {
    current_route = get_route(current_route, this);
    return remove_double_slashes(path_to_root_prefix(current_route) + path);
  },


  asset_path: function(path_from_assets_directory, current_route) {
    var p;

    current_route = get_route(current_route, this);
    p = path_to_root_prefix(current_route) + "assets/" + path_from_assets_directory;
    p = remove_double_slashes(p);

    return p;
  },


  //
  //  Block helpers
  //
  ifEqual: function(lvalue, rvalue, options) {
    if (arguments.length < 3)
      throw new Error("Handlebars helper 'ifEqual' needs 2 parameters");
    if (lvalue != rvalue) {
      return options.inverse(this);
    } else {
      return options.fn(this);
    }
  },


  ifStartsWith: function(check, val, options) {
    if (arguments.length < 3)
      throw new Error("Handlebars helper 'ifStartsWith' needs 2 parameters");
    if (val.match(new RegExp("^" + check))) {
      return options.fn(this);
    } else {
      return options.inverse(this);
    }
  }


};}
}(this));
