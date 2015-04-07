import _ from "underscore";
import md5 from "../vendor/md5";
import helpers from "./helpers";
import {state} from "./state";


App.storage = {

  default_quotes_url: "http://keymaps.herokuapp.com/api/public/MS9xdW90ZXM=",


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


  set_previous_random_quotes: function(quotes) {
    this.set("previous_random_quotes", JSON.stringify(quotes));
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

    return (u.length === 0 ? null : u) || this.default_quotes_url;
  },


  get_previous_random_quotes: function() {
    return JSON.parse(
      this.get("previous_random_quotes") || "[]"
    );
  },


  get_random_quote: function() {
    var quotes = this.get_quotes();
    var map = _.map(quotes, function(q) { return [md5(q.quote + q.author), q]; });

    var all_hashes = _.map(map, function(m) { return m[0]; });
    var previous_hashes = this.get_previous_random_quotes();
    var next_hashes = _.difference(all_hashes, previous_hashes);

    if (next_hashes.length === 0) {
      next_hashes = all_hashes;
      previous_hashes = [];
    }

    var random_idx = helpers.random_number(1, next_hashes.length) - 1;
    var random = next_hashes[random_idx];

    if (random) {
      previous_hashes.push(random);
      App.storage.set_previous_random_quotes(previous_hashes);

      return _.find(map, function(m) {
        return (m[0] === random);
      })[1];
    }
  },


  //
  //  Other
  //
  fetch_quotes: function() {
    var quotes_url = this.get_quotes_url();

    if (!quotes_url) {
      App.storage.set_quotes([]);
      App.storage.send_fetched_signal();

    } else {
      return fetch(quotes_url).then(function(response) {
        return response.json();
      }).then(function(json) {
        App.storage.set_quotes(json);
        App.storage.send_fetched_signal();
      }).catch(function(err) {
        console.error("Could not fetch quotes. — error: " + err.message);
      });

    }
  },


  send_fetched_signal: function() {
    state.last_quotes_fetch = +(new Date());
  }

};
