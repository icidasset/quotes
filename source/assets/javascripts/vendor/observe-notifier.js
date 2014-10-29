(function() {

"use strict";


var ObserveNotifier = function(obj) {
  this.obj = obj;

  this.path_observers = {};
  this.path_observer_counter = 1;
};



ObserveNotifier.prototype.on = function(key, callback) {
  var split = key.split(":");
  var operator = split[0];
  var path = split.slice(1, split.length).join(":");

  // check
  if (!callback) {
    console.error("StateManager — ObserveNotifier (on) — No callback given");
    return;
  }

  // two kinds of 'change'
  if (operator == "change") {
    if (path.length) {
      operator = operator + "_with_path";
    } else {
      operator = operator + "_without_path";
    }
  }

  // switch
  switch (operator) {
    case "change_with_path":
      var observer, obj;

      observer = function(changes) {
        for (var k=0, l=changes.length; k<l; ++k) {
          var change = changes[k];
          if (change.type == "update") {
            callback(change.name, change.oldValue);
          }
        }
      };

      Object.observe(this.obj, observer);

      obj = {
        id: this.path_observer_counter,
        key: key,
        operator: operator,
        path: path,
        observer: observer,
        callback: callback
      };

      this.path_observers[key] = this.path_observers[key] || [];
      this.path_observers[key].push(obj);
      break;

    case "change_without_path":
      // TODO
      break;

    case "add":
      // TODO
      break;

    case "remove":
      // TODO
      break;

    default:
      return;
  }

  // increase counter
  this.path_observer_counter++;
};



ObserveNotifier.prototype.off = function(key, callback) {
  var obj = this.path_observers[key];
  if (!obj) return;

  for (var i=0, j=obj.length; i<j; ++i) {
    if (obj[i].callback === callback || !callback) {
      Object.unobserve(this.obj, obj[i].observer);
      obj[i] = null;
    }
  }
};



//
//  Export
//
window.ObserveNotifier = ObserveNotifier;


}());
