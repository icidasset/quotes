(function() {

"use strict";


skate("io-navigation", {


  template: function(el) {
    el.innerHTML = Mustache.render(
      App.Helpers.get_template("modules-navigation"),
      App.DataStore.fetch("base")
    );
  }


});


}());
