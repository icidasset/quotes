var gulp = require("gulp"),
    gulp_file = require("gulp-file"),

    merge = require("merge-stream"),

    // lib
    CONFIG = require("../config"),

    data_service = require("../data_service");


gulp.task("build_json", function() {
  var data_object = data_service.get_data();
  var file_streams = [];

  data_service.scan_data();

  data_object._locales.forEach(function(locale) {
    file_streams.push(gulp_file(
      locale + ".json",
      JSON.stringify(data_object[locale]),
      { src: true }
    ));
  });

  return merge.apply(merge, file_streams)
    .pipe(gulp.dest(CONFIG.build_directory + "/data"));
});
