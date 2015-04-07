import _ from "underscore";


//
//  Handlebars
//
_.each(HandlebarsHelpers, function(v, k) {
  Handlebars.registerHelper(k, v);
});
