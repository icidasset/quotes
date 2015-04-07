var gulp = require("gulp"),
    gulp_concat = require("gulp-concat"),
    gulp_declare = require("gulp-declare"),
    gulp_handlebars = require("gulp-handlebars"),
    gulp_wrap = require("gulp-wrap"),

    handlebars = require("handlebars"),
    merge = require("merge-stream"),

    // lib
    CONFIG = require("../config"),
    HELPERS = require("../helpers"),
    PATHS = require("../paths");


gulp.task("build_js", function() {
  var streams = [], s;

  // --- handlebars
  s = gulp.src([
    "node_modules/handlebars/dist/handlebars.js",
    "lib/handlebars_helpers.js"
  ]).pipe(gulp_concat("handlebars.js"));

  streams.push(s);

  // --- templates
  s = gulp.src(PATHS.templates_all)
    .pipe(gulp_handlebars({ handlebars: handlebars }))
    .pipe(gulp_wrap("Handlebars.template(<%= contents %>)"))
    .pipe(gulp_declare({
      namespace: CONFIG.javascript.app_variable_name,
      noRedeclare: true,
      processName: gulp_declare.processNameByPath
    }))
    .pipe(gulp_concat("templates.js"));

  streams.push(s);

  // --- jspm config
  s = gulp.src("./lib/jspm_config.js");

  streams.push(s);

  // build
  return merge.apply(merge, streams)
    .pipe(gulp.dest(CONFIG.build_directory + "/assets/javascripts"));
});
