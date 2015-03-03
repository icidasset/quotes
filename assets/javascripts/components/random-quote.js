skate("io-random-quote", {

  created: function(el) {
    el.render = _.bind(el.render, el);
    el.last_quotes_fetch_change = _.bind(el.last_quotes_fetch_change, el);

    el.bind_events();
    el.render();
  },


  detached: function(el) {
    el.unbind_events();
  },


  events: {
    "click .random-quote__nav-button": function(el, event) {
      el.render();
    },

    "click .random-quote__quote-author": function(el, event) {
      el.quote_author_click_handler(event);
    }
  },


  prototype: {

    bind_events: function() {
      App.stateNotifier.on("change:last_quotes_fetch", this.last_quotes_fetch_change);
    },


    unbind_events: function() {
      App.stateNotifier.off("change:last_quotes_fetch", this.last_quotes_fetch_change);
    },


    render: function() {
      var quote = App.storage.get_random_quote();
      var status;

      if (quote) {
        status = {
          total_quotes: App.storage.get_quotes().length,
          quotes_seen: App.storage.get_previous_random_quotes().length
        };

        this.no_quote = false;
        this.innerHTML = App.templates.partials["random-quote"](
          _.extend({ status: status }, quote)
        );

      } else if (!App.storage.get_quotes_url()) {
        this.no_quote = true;
        this.innerHTML = '<p>No quotes collection has been setup yet.</p>';

      } else {
        this.no_quote = true;
        this.innerHTML = '<p>No quotes found.</p>';

      }
    },


    last_quotes_fetch_change: function() {
      if (this.no_quote) this.render();
    },


    quote_author_click_handler: function(event) {
      // TODO
      var query = "Bob Dylan";
      var wiki_url = "http://en.wikipedia.org/w/api.php?action=query&prop=extracts&exchars=1000&format=json&titles=" + encodeURIComponent(query);
      var url = "https://jsonp.nodejitsu.com/?url=" + encodeURIComponent(wiki_url);
    }

  }

});
