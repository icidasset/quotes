(function() {

"use strict";


App.DataStore = {

  // this property will store all the data
  _data: null,


  setup: function() {
    var data_json = document.querySelector("#initial-data").innerHTML;
    var data_parsed = JSON.parse(data_json);

    // set
    this._data = data_parsed;

    // other
    this.manipulate();
  },


  fetch: function(path) {
    var path_array = path.split(".");
    var result = this._data;

    for (var i=0, j=path_array.length; i<j; ++i) {
      var key = path_array[i];
      if (result) result = result[key];
      else break;
    }

    return result;
  },


  manipulate: function() {
    _.each(this.manipulations, function(m) {
      // m = manipulation function
      m(App.DataStore._data);
    });
  },


  //
  //  Manipulations
  //
  manipulations: []

};


}());
