var gulp = require("gulp"),
    gulp_shell = require("gulp-shell");


gulp.task("install_jspm", gulp_shell.task([
  "./node_modules/.bin/jspm install"
]));
