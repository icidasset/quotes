//= require vendor/director
//= require vendor/gator
//= require vendor/md5
//= require vendor/mustache
//= require vendor/object-keys-polyfill
//= require vendor/object-observe-polyfill
//= require vendor/observe-notifier
//= require vendor/reqwest
//= require vendor/skate
//= require vendor/underscore

//= require lib/namespace
//= require lib/helpers

//= require lib/storage
//= require lib/data-store
//= require lib/state-manager
//= require lib/router

//= require_tree ./modules

//= require_self

(function() {
  document.addEventListener("DOMContentLoaded", function(e) {
    document.body.parentNode.className += "has-js";

    App.DataStore.setup();
    App.Router.setup();

    // intialize modules
    App.initialize_modules();

    // renew quotes collection
    App.Storage.fetch_quotes();
  });

}());
