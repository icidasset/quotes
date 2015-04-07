var gulp = require("gulp"),
    gulp_sass = require("gulp-sass"),

    node_bourbon = require("node-bourbon"),

    // lib
    CONFIG = require("../config"),
    HELPERS = require("../helpers"),
    PATHS = require("../paths");


gulp.task("build_css", function() {
  return gulp.src(PATHS.assets_stylesheets_application)
    .pipe(gulp_sass({
      includePaths: node_bourbon.includePaths,
      outputStyle: "nested"
    }))
    .on("error", HELPERS.swallow_error)
    .pipe(gulp.dest(CONFIG.build_directory + "/assets/stylesheets"));
});
