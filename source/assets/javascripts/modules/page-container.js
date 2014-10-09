(function() {

"use strict";


skate("io-page-container", {


  ready: function(el) {
    this.el = el;

    // bind
    _.bindAll(this, "render");

    // events
    App.StateManagerNotifier.on("change:route", this.render);

    // initial render
    this.render();
  },


  render: function() {
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
  }


});


}());
