(function() {

"use strict";


App.module("io-settings", {

  template: function(el) {
    el.innerHTML = Mustache.render(
      App.Helpers.get_template("modules-settings"),
      {}
    );
  },


  created: function(el) {
    el.instance = new Settings(el);
  },


  events: {
    "submit form": function(el, event) {
      el.instance.submit_form_handler(event);
    }
  }

});



function Settings(el) {
  this.el = el;
  this.set_inital_form_values();
}


//
//  Event handlers
//
Settings.prototype.submit_form_handler = function(event) {
  var form = event.target;
  var url = form.querySelector("[name=\"url\"]").value.toString().trim();

  // prevent default
  event.preventDefault();

  // set & fetch
  App.Storage.set_quotes_url(url);
  App.Storage.set_previous_random_quotes([]);
  App.Storage.fetch_quotes();
};


//
//  Other
//
Settings.prototype.set_inital_form_values = function() {
  var form = this.el.querySelector("form");
  form.querySelector("[name=\"url\"]").value = App.Storage.get_quotes_url();
};


}());
