(function() {

"use strict";


App.Storage = {

  //
  //  Setters
  //
  set: function() {
    localStorage.setItem.apply(localStorage, arguments);
  },


  set_quotes: function(quotes) {
    this.set("quotes", JSON.stringify(quotes));
  },


  set_quotes_url: function(url) {
    this.set("quotes_url", url);
  },


  //
  //  Getters
  //
  get: function() {
    return localStorage.getItem.apply(localStorage, arguments);
  },


  get_quotes: function() {
    return JSON.parse(this.get("quotes") || "[]");
  },


  get_quotes_url: function() {
    var u = this.get("quotes_url");

    if (u) u = u.trim();
    else u = "";

    return (u.length === 0 ? null : u);
  },


  //
  //  Other
  //
  fetch_quotes: function() {
    var quotes_url = this.get_quotes_url();

    if (!quotes_url) {
      App.Storage.set_quotes([]);
      App.Storage.send_fetched_signal();

    } else {
      return reqwest({
        url: quotes_url,
        crossOrigin: true,
        success: function(response) {
          App.Storage.set_quotes(response);
          App.Storage.send_fetched_signal();
        }
      })

    }
  },


  send_fetched_signal: function() {
    App.StateManager.last_quotes_fetch = +(new Date());
  }

};


}());
