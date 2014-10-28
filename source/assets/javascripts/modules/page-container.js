(function() {

"use strict";


App.module("io-page-container", {

  created: function(el) {
    el.instance = new PagesContainer(el);
  }

});



function PagesContainer(el) {
  _.bindAll(this, "render");

  // element
  this.el = el;

  // events
  App.StateManagerNotifier.on("change:route", this.render);

  // initial render
  this.render();
}


PagesContainer.prototype.render = function() {
  var page_key = App.StateManager.route_page_key;
  var page_data = App.DataStore.fetch("pages." + page_key) || {};

  if (page_data.flex) {
    document.querySelector("html").classList.add("l-flex");
  } else {
    document.querySelector("html").classList.remove("l-flex");
  }

  this.el.innerHTML = Mustache.render(
    App.Helpers.get_template("pages-" + page_key),
    page_data
  );
};


}());
