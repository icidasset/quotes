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



function factory() { return {


  //
  //  Path helpers
  //
  relative_path: function(path, current_route) {
    current_route = current_route || this._route;
    return (path_to_root_prefix(current_route) + path).replace(/\/{2,}/g, "/");
  },


  asset_path: function(path_from_assets_directory) {
    var p;

    p = path_to_root_prefix(this._route) + "assets/" + path_from_assets_directory;
    p = p.replace(/\/{2,}/g, "/");

    return p;
  },


  //
  //  Block helpers
  //
  ifEqual: function(lvalue, rvalue, options) {
    if (arguments.length < 3)
      throw new Error("Handlebars Helper ifEqual needs 2 parameters");
    if (lvalue != rvalue) {
      return options.inverse(this);
    } else {
      return options.fn(this);
    }
  },


  //
  //  Other
  //
  html_class: function() {
    return this._flex ? "l-flex" : "";
  }


};}
}(this));
