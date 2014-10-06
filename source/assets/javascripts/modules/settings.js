(function() {

"use strict";


skate("io-settings", {


  template: function(el) {
    el.innerHTML = Mustache.render(
      App.Helpers.get_template("modules-settings"),
      {}
    );
  },


  events: {
    "submit form": submit_form_handler
  },


  ready: function(el) {
    var form = el.querySelector("form");

    set_inital_form_values(form);
  }


});



//
//  Event handlers
//
function submit_form_handler(form, e) {
  var url = form.querySelector("[name=\"url\"]").value.toString().trim();

  // prevent default
  e.preventDefault();

  // set & fetch
  App.Storage.set_quotes_url(url);
  App.Storage.fetch_quotes();
}



//
//  Other
//
function set_inital_form_values(form) {
  form.querySelector("[name=\"url\"]").value = App.Storage.get_quotes_url();
}


}());
