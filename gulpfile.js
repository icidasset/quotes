var gulp = require("gulp"),
    gulp_shell = require("gulp-shell"),

    // lib
    PATHS = require("./lib/paths");


require("fs").readdirSync("./lib/tasks").forEach(function(filename) {
  if (filename.match(/\.js$/)) require("./lib/tasks/" + filename.replace(".js", ""));
});


gulp.task("clean", gulp_shell.task([
  "rm -rf ./build"
]));


gulp.task("pre-build", [
  "install_jspm"
]);


gulp.task("build_step_1", [
  "build_css",
  "build_html_and_json",
  "build_js",
  "build_jspm",

  "copy_static_assets"
]);


gulp.task("build", [
  "clone_assets"
]);


gulp.task("watch", ["build"], function() {
  gulp.watch(PATHS.data + "/**/*", ["build_html_and_json"]);
  gulp.watch(PATHS.assets_static, ["copy_static_assets"]);
  gulp.watch(PATHS.assets_stylesheets_all, ["build_css"]);
  gulp.watch(PATHS.assets_javascripts_all, ["build_jspm"]);
  gulp.watch(PATHS.layouts, ["build_html", "build_js"]);
  gulp.watch(PATHS.templates_all, ["build_html", "build_js"]);
});


gulp.task("default", ["watch"]);
