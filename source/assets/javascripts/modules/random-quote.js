(function() {

"use strict";


skate("io-random-quote", {


  ready: function(el) {
    this.el = el;

    // bind
    _.bindAll(this, "last_quotes_fetch_change", "render");

    // events
    App.StateManagerNotifier.on("change:last_quotes_fetch", this.last_quotes_fetch_change);

    // initial render
    this.render();
  },


  last_quotes_fetch_change: function() {
    if (this.el.no_quote) this.render();
  },


  render: function() {
    var quote = App.Storage.get_random_quote();

    // TODO - make templates of these
    if (quote) {
      this.el.innerHTML = [
        '<blockquote><p>', quote.quote, '<span class="end-quote-mark"></span></p></blockquote>',
        '<p>By ', quote.author, '</p>'
      ].join("");

    } else if (!App.Storage.get_quotes_url()) {
      this.el.no_quote = true;
      this.el.innerHTML = '<p>No quotes collection has been setup yet.</p>';

    } else {
      this.el.no_quote = true;
      this.el.innerHTML = '<p>No quotes found.</p>';

    }
  }


});


}());
