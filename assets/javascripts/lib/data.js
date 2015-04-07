import {state} from "../lib/state";


var locale = document.querySelector("html").getAttribute("language");
var data_url = HandlebarsHelpers.relative_path("data/" + locale + ".json", state.initial_route);
var use_data_from_html = false;
var promise;


if (use_data_from_html) {
  promise = new Promise(function(resolve, reject) {
    resolve(JSON.parse(document.getElementById("initial-data").innerHTML));
  });

} else {
  promise = fetch(data_url).then(function(response) {
    return response.json();
  });

}


export default promise;
