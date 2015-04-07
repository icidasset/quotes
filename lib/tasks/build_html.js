var gulp = require("gulp"),
    gulp_compile_handlebars = require("gulp-compile-handlebars"),
    gulp_minify_html = require("gulp-minify-html"),
    gulp_rename = require("gulp-rename"),

    gulpsmith = require("gulpsmith"),
    merge = require("merge-stream"),
    metalsmith_layouts = require("metalsmith-layouts"),
    underscore = require("underscore")._,

    // lib
    CONFIG = require("../config"),
    HELPERS = require("../helpers"),
    PATHS = require("../paths"),

    data_service = require("../data_service"),
    handlebars_helpers = require("../handlebars_helpers");


gulp.task("build_html", ["build_json"], function() {
  var data_object = data_service.get_data();
  var streams = data_object._locales.map(function(locale) {
    return build_html_files(data_object, locale, CONFIG.locales.default);
  });

  return merge.apply(merge, underscore.flatten(streams))
    .pipe(gulp.dest(CONFIG.build_directory));
});


function build_html_files(data_object, locale, default_locale) {
  var streams = [];

  var handlebars_compile_options = {
    batch: ["templates/partials"],
    helpers: handlebars_helpers
  };

  var data_base_object = {
    data_as_json: JSON.stringify(data_object[locale])
  };

  underscore.extend(data_base_object, {
    _all: data_object[locale]
  });

  underscore.each(data_object[locale]._routing_table, function(v, k) {
    var d = HELPERS.page_data(data_object, locale, v.page_path);
    var dd = underscore.extend({}, data_base_object, d);
    var prefix = (locale == default_locale ? "" : locale + "/");
    var route = data_base_object._all._routing_table[v.page_path].route;
    var t = "./templates/pages/" + v.template_path + ".hbs";
    var stream;

    stream = gulp.src(t)
      .pipe(gulp_compile_handlebars(
        dd,
        handlebars_compile_options
      ))
      .pipe(
        gulpsmith()
          .metadata(dd)
          .use(metalsmith_layouts({
            "engine": "handlebars",
            "default": "application.hbs"
          }))
      )
      .pipe(gulp_minify_html({ empty: true, cdata: true, quotes: true }))
      .pipe(gulp_rename(prefix + route + "/index.html"));

    streams.push(stream);
  });

  return streams;
}
