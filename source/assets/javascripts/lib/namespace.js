(function() {

"use strict";


window.App = {

  Modules: [],


  module: function(id, definition) {
    this.Modules.push([id, definition]);
  },


  initialize_modules: function() {
    _.each(this.Modules, function(m) {
      skate(m[0], m[1]);
    });
  }

};


}());
