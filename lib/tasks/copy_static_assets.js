var gulp = require("gulp"),

    merge = require("merge-stream"),

    // lib
    CONFIG = require("../config"),
    PATHS = require("../paths");


gulp.task("copy_static_assets", function() {
  var merge_args = [];

  PATHS.assets_static.forEach(function(s) {
    var stream = gulp
      .src(s + "/**/*", { base: s })
      .pipe(gulp.dest(CONFIG.build_directory + "/" + s));

    merge_args.push(stream);
  });

  return merge.apply(merge, merge_args);
});
