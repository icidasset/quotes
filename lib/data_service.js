var front_matter = require("front-matter"),
    fs = require("fs"),
    marked = require("marked"),
    walkdir = require("walkdir"),
    underscore = require("underscore")._,
    yaml = require("yamljs"),

    // lib
    HELPERS = require("./helpers"),
    PATHS = require("./paths"),

    data_manipulations = require("./data_manipulations");


marked.setOptions({
  renderer: new marked.Renderer(),
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: false,
  smartLists: true,
  smartypants: true,
  highlight: false
});


module.exports = {

  scan_data: function() {
    var data_paths = fs.existsSync(PATHS.data) ? walkdir.sync(PATHS.data) : [];
    var data_object = {};
    var pwd = __dirname.replace(/\/lib\/?$/, "") + "/data/";

    // read data
    data_paths.forEach(function(p) {
      var match_yaml = p.match(/\.yml$/);
      var match_md = p.match(/\.md$/);
      var relative_path, base, split, obj_pointer, parent, file_contents, fm;

      relative_path = p.replace(pwd, "").replace(/\.\w+$/, "");
      split = relative_path.split("/");
      base = split[split.length - 1];

      if (match_yaml || match_md) {
        obj_pointer = HELPERS.traverse(data_object, split);
        obj_pointer._base = base;
        obj_pointer.settings = obj_pointer.settings || {};

        parent = (split.length > 1 ?
          HELPERS.traverse(data_object, split.slice(0, split.length - 1)) :
          null
        );

        if (parent) {
          parent._children = parent._children || [];
          if (!underscore.findWhere(parent._children, { _base: base })) {
            parent._children.push(obj_pointer);
          }
        }

        if (match_yaml) {
          underscore.extend(obj_pointer, yaml.load(p));
          obj_pointer._flags.is_yaml = true;
        } else if (match_md) {
          file_contents = fs.readFileSync(p).toString();
          fm = front_matter(file_contents);

          underscore.extend(obj_pointer, fm.attributes);
          obj_pointer.parsed_markdown = marked(fm.body);
          obj_pointer._flags.is_markdown = true;
        }

      } else if (fs.lstatSync(p).isDirectory()) {
        obj_pointer = HELPERS.traverse(data_object, split);
        obj_pointer.settings = obj_pointer.settings || {};
        obj_pointer._flags.is_directory = true;

      }
    });


    // locales
    data_object._locales = Object.keys(data_object).filter(function(k) {
      var d = data_object[k];
      if (!d._flags.is_markdown && !d._flags.is_yaml) {
        d._locale = k;
        return true;
      }
    });


    // data manipulations
    data_manipulations.forEach(function(manipulation_fn) {
      manipulation_fn.call(data_object);
    });

    // set
    this.data_object = data_object;
  },


  get_data: function(refresh) {
    if (!this.data_object || refresh) this.scan_data();
    return this.data_object;
  }

};
