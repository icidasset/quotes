var gulp = require("gulp"),

    merge = require("merge-stream"),

    // lib
    CONFIG = require("../config"),
    PATHS = require("../paths"),

    data_service = require("../data_service");


gulp.task("clone_assets", ["build_step_1"], function(clb) {
  var data_object = data_service.get_data();
  var streams = [];

  data_object._locales.forEach(function(l) {
    if (l !== CONFIG.locales.default) {
      var stream = gulp
        .src(CONFIG.build_directory + "/assets/**/*", { base: CONFIG.build_directory })
        .pipe(gulp.dest(CONFIG.build_directory + "/" + l));

      streams.push(stream);
    }
  });

  if (streams.length === 0) {
    return clb();
  } else {
    return merge.apply(merge, streams);
  }
});
