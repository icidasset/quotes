skate("io-settings", {

  template: function(el) {
    el.innerHTML = App.templates.partials.settings();
  },


  created: function(el) {
    var form = el.querySelector("form");
    form.querySelector("[name=\"url\"]").value = App.storage.get_quotes_url();
  },


  events: {
    "submit form": function(el, event) {
      el.submit_form_handler(event);
    }
  },


  prototype: {

    submit_form_handler: function(event) {
      var form = event.target;
      var url = form.querySelector("[name=\"url\"]").value.toString().trim();

      // prevent default
      event.preventDefault();

      // set & fetch
      App.storage.set_quotes_url(url);
      App.storage.set_previous_random_quotes([]);
      App.storage.fetch_quotes();
    }

  }

});
