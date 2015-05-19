import "es6-promise";
import "fetch";
import "object.observe";
import "skatejs";

import "./lib/environment";
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

}, function() {
  console.error("Could not load data.");

});


document.addEventListener("DOMContentLoaded", function() {
  document.querySelector("html").classList.add("has-js");
});
