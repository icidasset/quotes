(function() {

"use strict";


var state_manager = {
  route: null,
  route_params: {},
  route_page_key: null,

  last_quotes_fetch: null
};


App.StateManager = state_manager;
App.StateManagerNotifier = new ObserveNotifier(state_manager);


}());
