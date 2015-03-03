import "./vendor/md5";

import "./lib/environment";
import "./lib/helpers";
import "./lib/state";
import "./lib/storage";

import "./components/navigation";
import "./components/page-container";
import "./components/random-quote";
import "./components/settings";

import data_promise from "./lib/data";
import setup_routes from "./lib/routes";


data_promise.then(function(data) {
  App.data = data;

  // setup routes
  setup_routes();

  // renew quotes collection
  App.storage.fetch_quotes();

}, function() {
  console.error("Could not load data.");

});


document.addEventListener("DOMContentLoaded", function() {
  document.querySelector("html").classList.add("has-js");
});
