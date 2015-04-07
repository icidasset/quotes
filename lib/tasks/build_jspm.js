var gulp = require("gulp"),
    gulp_shell = require("gulp-shell");


gulp.task("build_jspm", gulp_shell.task([
  "./node_modules/.bin/jspm bundle-sfx assets/javascripts/application build/assets/javascripts/application.js --skip-source-maps --minify"
]));
