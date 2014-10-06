(function() {

"use strict";


// object_observer.open(function(added, removed, changed, get_old_value_fn) {
//   Object.keys(added).forEach(function(property) {});
//   Object.keys(removed).forEach(function(property) {});
//   Object.keys(changed).forEach(function(property) {});
// });



var ObserveNotifier = function(obj) {
  this.obj = obj;
  this.object_observer = new ObjectObserver(this.obj);
  this.object_observer_callbacks = {};

  this.path_observers = {};
  this.path_observer_counter = 1;
};



ObserveNotifier.prototype.on = function(key, callback) {
  var split = key.split(":");
  var operator = split[0];
  var path = split.slice(1, split.length).join(":");
  var obno_instance = this;

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

      observer = new PathObserver(this.obj, path);
      observer.open(callback);

      obj = {
        id: obno_instance.path_observer_counter,
        key: key,
        operator: operator,
        path: path,
        observer: observer,
        callback: callback
      };

      obno_instance.path_observers[key] = obno_instance.path_observers[key] || [];
      obno_instance.path_observers[key].push(obj);
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
  obno_instance.path_observer_counter++;
};



ObserveNotifier.prototype.off = function(key, callback) {
  var obj = obno_instance.path_observers[key];
  if (!obj) return;

  for (var i=0, j=obj.length; i<j; ++i) {
    if (obj[i].callback === callback || !callback) {
      obj[i].observer.close();
      obj[i].observer = null;
      obj[i] = null;
    }
  }
};



//
//  Export
//
window.ObserveNotifier = ObserveNotifier;


}());
