(function() {

"use strict";


skate("io-random-quote", {


  ready: function(el) {
    this.el = el;

    // bind
    _.bindAll(this, "render");

    // events
    App.StateManagerNotifier.on("change:last_quotes_fetch", this.render);

    // initial render
    this.render();
  },


  render: function() {
    var quotes = App.Storage.get_quotes();
    var random_idx = App.Helpers.random_number(1, quotes.length) - 1;
    var quote = quotes[random_idx];

    // TODO - make templates of these
    if (quote) {
      this.el.innerHTML = [
        '<blockquote><p>', quote.quote, '<span class="end-quote-mark"></span></p></blockquote>',
        '<p>By ', quote.author, '</p>'
      ].join("");

    } else if (!App.Storage.get_quotes_url()) {
      this.el.innerHTML = '<p>No quotes collection has been setup yet.</p>';

    } else {
      this.el.innerHTML = '<p>No quotes found.</p>';

    }
  }


});


}());
