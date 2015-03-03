/* global __dirname, require */

var gulp = require("gulp"),

    compile_handlebars = require("gulp-compile-handlebars"),
    concat = require("gulp-concat"),
    declare = require("gulp-declare"),
    file = require("gulp-file"),
    foreach = require("gulp-foreach"),
    gulp_handlebars = require("gulp-handlebars"),
    rename = require("gulp-rename"),
    sass = require("gulp-sass"),
    wrap = require("gulp-wrap"),

    to5ify = require("6to5ify"),
    browserify = require("browserify"),
    bourbon = require("node-bourbon"),
    del = require("del"),
    fs = require("fs"),
    handlebars = require("handlebars"),
    handlebars_helpers = require("./handlebars_helpers"),
    markdown = require("markdown").markdown,
    merge = require("merge-stream"),
    transform = require("vinyl-transform"),
    underscore = require("underscore")._,
    walkdir = require("walkdir"),
    YAML = require("yamljs"),

    gulpsmith = require("gulpsmith"),
    m_layouts = require("metalsmith-layouts"),

    _is_building = false;


var paths = {
  data: "data",
  assets_static: ["assets/images", "assets/fonts"],
  assets_stylesheets_application: "assets/stylesheets/application.scss",
  assets_stylesheets_all: "assets/stylesheets/**/*.scss",
  assets_javascripts_application: "assets/javascripts/application.js",
  assets_javascripts_all: "assets/javascripts/**/*.js",
  templates_all: "templates/**/*.hbs",
  templates_pages: "templates/pages/**/*.hbs",
  layouts: "layouts/**/*.html"
};



//
//  Helpers
//
function swallow_error(error) {
  console.log(error.toString());
  this.emit("end");
}


function basename(path) {
  var s = path.split("/");
  return s[s.length - 1].replace(/\.\w+/, "");
}


function traverse(obj, path_array) {
  var pointer = obj;

  for (var i=0, j=path_array.length; i<j; ++i) {
    pointer[path_array[i]] = pointer[path_array[i]] || { _flags: {} };
    pointer = pointer[path_array[i]];
  }

  return pointer;
}


function page_path(file) {
  var path = file.path.replace(file.cwd + "/templates/pages/", "")
    .replace(/(^\/|\/$)+/g, "")
    .split("/");

  path[path.length - 1] = basename(path[path.length - 1]);
  path = path.join("/");

  return path;
}


function page_data(locale, page_path) {
  var d = data_object[locale].pages;

  page_path.split("/").forEach(function(s) {
    d = d[s];
  });

  return d;
}



//
//  Site config
//
var CONFIG = YAML.load(__dirname + "/config.yml");
var BUILD_DIR = CONFIG.build_directory;



//
//  Parse data
//
var data_paths = fs.existsSync(paths.data) ? walkdir.sync(paths.data) : [];
var data_object = {};


data_paths.forEach(function(p) {
  var match_yaml = p.match(/\.yml$/);
  var match_md = p.match(/\.md$/);
  var relative_path, base, split, obj_pointer, parent;

  relative_path = p.replace(__dirname + "/data/", "").replace(/\.\w+$/, "");
  split = relative_path.split("/");
  base = split[split.length - 1];

  if (match_yaml || match_md) {
    obj_pointer = traverse(data_object, split);
    parent = split.length > 1 ? traverse(data_object, split.slice(0, split.length - 1)) : null;

    if (parent) {
      parent._children = parent._children || [];
      if (!underscore.contains(parent._children, base)) parent._children.push(base);
    }

    if (match_yaml) {
      underscore.extend(obj_pointer, YAML.load(p));
      obj_pointer._flags.is_yaml = true;
    } else if (match_md) {
      obj_pointer.parsed_markdown = markdown.toHTML(fs.readFileSync(p).toString());
      obj_pointer._flags.is_markdown = true;
    }
  } else if (fs.lstatSync(p).isDirectory()) {
    obj_pointer = traverse(data_object, split);
    obj_pointer._flags.is_directory = true;
  }
});


data_object._locales = Object.keys(data_object).filter(function(k) {
  var d = data_object[k];
  if (!d._flags.is_markdown && !d._flags.is_yaml) {
    d._locale = k;
    return true;
  }
});


// data manipulations
require("./data_manipulations").forEach(function(manipulation_fn) {
  manipulation_fn.call(data_object);
});



//
//  Copy images & fonts
//
gulp.task("copy_static_assets", ["clean"], function() {
  var merge_args = [];

  _is_building = true;

  paths.assets_static.forEach(function(s) {
    var stream = gulp
      .src(s + "/**/*", { base: s })
      .pipe(gulp.dest(BUILD_DIR + "/" + s));

    merge_args.push(stream);
  });

  return merge.apply(merge, merge_args);
});



//
//  Stylesheets
//
gulp.task("build_application_stylesheet", ["copy_static_assets"], function() {
  return gulp.src(paths.assets_stylesheets_application)
    .pipe(sass({
      includePaths: require("node-bourbon").includePaths,
      outputStyle: "nested"
    }))
    .on("error", swallow_error)
    .pipe(gulp.dest(BUILD_DIR + "/assets/stylesheets"));
});



//
//  Javascripts
//
gulp.task("build_application_javascript", ["build_application_stylesheet"], function() {
  var browserified = transform(function(filename) {
    var b = browserify(filename);
    b.transform(to5ify);
    return b.bundle();
  });

  // handlebars
  var handlebars_stream = gulp.src([
    "node_modules/handlebars/dist/handlebars.js",
    "handlebars_helpers.js"
  ]).pipe(concat("handlebars.js"));

  // templates
  var templates_stream = gulp.src(paths.templates_all)
    .pipe(gulp_handlebars({ handlebars: handlebars }))
    .pipe(wrap("Handlebars.template(<%= contents %>)"))
    .pipe(declare({
      namespace: CONFIG.javascript.app_variable_name,
      noRedeclare: true,
      processName: declare.processNameByPath
    }))
    .pipe(concat("templates.js"));

  // vendor
  var vendor_stream = gulp.src(CONFIG.javascript.vendor_paths)
    .pipe(concat("vendor.js"));

  // main javascript
  var js_stream = gulp.src(paths.assets_javascripts_application)
    .pipe(browserified)
    .on("error", swallow_error);

  // build
  return merge(handlebars_stream, templates_stream, vendor_stream, js_stream)
    .pipe(concat("application.js"))
    .pipe(gulp.dest(BUILD_DIR + "/assets/javascripts"));
});



//
//  HTML
//
gulp.task("build_html_files", ["build_application_javascript"], function() {
  var streams = data_object._locales.map(function(locale) {
    return build_html_files(locale, CONFIG.locales.default);
  });

  return merge.apply(merge, streams)
    .pipe(gulp.dest(BUILD_DIR));
});


function build_html_files(locale, default_locale) {
  var handlebars_compile_options = {
    batch: ["templates/partials"],
    helpers: handlebars_helpers
  };

  var data_base_object = (CONFIG.data.in_html ?
    { data_as_json: JSON.stringify(data_object[locale]) } :
    {}
  );

  underscore.extend(data_base_object, {
    _all: data_object[locale]
  });

  return gulp.src(paths.templates_pages)
    // compile handlebars templates
    .pipe(foreach(function(stream, file) {
      var p = page_path(file);
      var d = page_data(locale, p);

      return stream.pipe(compile_handlebars(
        underscore.extend({}, data_base_object, d),
        handlebars_compile_options
      ));
    }))
    // build templates + move to new path
    .pipe(foreach(function(stream, file) {
      var p = page_path(file);
      var d = page_data(locale, p);
      var prefix = (locale == default_locale ? "" : locale + "/");
      var route = data_base_object._all._routing_table[p].route;

      return stream.pipe(
        gulpsmith()
          .metadata(underscore.extend({}, data_base_object, d))
          .use(m_layouts({
            "engine": "handlebars",
            "default": "application.hbs"
          }))
      ).pipe(rename(prefix + route + "/index.html"));
    }));
}



//
//  Data.json
//
gulp.task("build_data_json_files", ["build_html_files"], function() {
  var file_streams = [];

  data_object._locales.forEach(function(locale) {
    file_streams.push(file(
      locale + ".json",
      JSON.stringify(data_object[locale]),
      { src: true }
    ));
  });

  return merge.apply(merge, file_streams)
    .pipe(gulp.dest(BUILD_DIR + "/data"));
});



//
//  Clone assets
//
gulp.task("clone_assets", ["build_data_json_files"], function(clb) {
  var streams = [];

  data_object._locales.forEach(function(l) {
    if (l !== CONFIG.locales.default) {
      var stream = gulp
        .src(BUILD_DIR + "/assets/**/*", { base: BUILD_DIR })
        .pipe(gulp.dest(BUILD_DIR + "/" + l));

      streams.push(stream);
    }
  });

  if (streams.length === 0) {
    return clb();
  } else {
    return merge.apply(merge, streams);
  }
});



//
//  Other tasks
//
gulp.task("clean", function(clb) {
  del([BUILD_DIR + "/**"], { force: true }, clb);
});


gulp.task("build", [
  "clone_assets"
], function(clb) {
  setTimeout(function() {
    _is_building = false;
  }, 1000);
  clb();
});


gulp.task("watch", ["build"], function() {
  gulp.watch(underscore.flatten([
    paths.data,
    paths.layouts,
    paths.templates_all,
    paths.assets_stylesheets_all,
    paths.assets_javascripts_all
  ]), function(event) {
    if (!_is_building) gulp.run("build");
  });
});


gulp.task("default", ["watch"]);
