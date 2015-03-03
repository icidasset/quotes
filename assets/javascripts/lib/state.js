import ObserveNotifier from "../vendor/observe-notifier";


var initial_state = JSON.parse(
  document.getElementById("initial-state").innerHTML
);


var state = _.extend({}, initial_state, {
  route: null,
  route_params: {},
  route_page_path: null,

  last_quotes_fetch: null
});


App.state = state;
App.stateNotifier = new ObserveNotifier(state);
