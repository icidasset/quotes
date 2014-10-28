(function() {

"use strict";


App.module("io-navigation", {

  template: function(el) {
    el.innerHTML = Mustache.render(
      App.Helpers.get_template("modules-navigation"),
      App.DataStore.fetch("base")
    );
  },


  created: function(el) {
    el.instance = new Navigation(el);
  }

});



function Navigation(el) {
  _.bindAll(this, "set_active_item");

  // element
  this.el = el;

  // events
  App.StateManagerNotifier.on(
    "change:route_page_key",
    this.set_active_item
  );

  // initial
  this.set_active_item();
}


Navigation.prototype.set_active_item = function() {
  var active_page_key = App.StateManager.route_page_key;
  var klass = "is-active";
  var previous, next;

  // remove previous active class
  previous = this.el.querySelector(".menu ." + klass);
  if (previous) previous.classList.remove(klass);

  // add new
  next = this.el.querySelector(".menu [key=\"" + active_page_key + "\"]");
  if (next) next.classList.add(klass);
};


}());
