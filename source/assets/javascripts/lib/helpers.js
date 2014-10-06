(function() {

"use strict";


App.Helpers = {


  //
  //  Templating
  //
  get_template: function(template_name) {
    var el = document.getElementById("template-" + template_name);
    return el ? el.innerHTML : "";
  },



  //
  //  Other
  //
  random_number: function(min, max) {
    return Math.floor(Math.random() * (max - min)) + min;
  }


};


}());
