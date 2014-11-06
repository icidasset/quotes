(function() {

"use strict";


// alternative: https://github.com/visionmedia/page.js


var router = new Router({
  "/":                          function() { defer.call(this, "index"); },
  "/quote(/)":                  function() { defer.call(this, "quote"); },
  "/set-quote-collection(/)":   function() { defer.call(this, "set-quote-collection"); }
});



function defer(page_key) {
  App.StateManager.route = window.location.pathname;
  App.StateManager.route_params = this.params;
  App.StateManager.route_page_key = page_key;
}



router.configure({
  html5history: true
});



router.setup = function() {
  // TODO: setup dynamic routes
  router.init();

  setup_router_triggers();
};



function setup_router_triggers() {
  Gator(document).on("click", "[href]", href_click_handler);
}



function href_click_handler(e) {
  var href = e.target.getAttribute("href");

  // reroute only internal links
  if (href.indexOf("http") !== 0) {
    e.preventDefault();

    router.setRoute("/" + href);
  }
}



window.App.Router = router;


}());
