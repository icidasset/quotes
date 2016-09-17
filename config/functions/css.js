const { basename, join, resolve } = require('path');
const { extend } = require('../utils');
const { forkDefinition } = require('static-base-contrib/utils');
const postcss = require('postcss');



const process = (files) => files.map(f => {
  var cssmodules;

  return postcss([
    require('postcss-functions')({
      functions: {

        // 12px: grid
        // 16px: default font-size
        grid(number) {
          const sizeInRem = parseFloat(number) * (12 / 16);
          // e.g. 1 = 1 column of 12px
          return sizeInRem.toString() + 'rem';
        },

        rem(pixels) {
          const sizeInRem = parseFloat(pixels.replace(/px$/, '')) / 16;
          return sizeInRem.toString() + 'rem';
        },

      },
    }),

    require('postcss-property-lookup'),
    require('postcss-cssnext')({
      features: {
        rem: false,
      },
    }),

    require('postcss-modules')({
      getJSON: (_, obj) => cssmodules = obj
    }),
  ])
  .process(f.content, { from: f.entirePath })
  .then(result => extend(f, { content: result.css, cssmodules }));
});



module.exports = function css(files) {

  // process all css files & gather css-modules info
  return Promise.all(
    process(files)

  // bundle all css files into one css file & store the css-modules info
  ).then(files => {
    const def = forkDefinition('application.css', files[0]);
    const content = files.reduce((acc, f) => `${acc}\n${f.content}`, ``);
    const cssmodules = files.reduce(
      (f_acc, f) => {
        const f_cssmodules = Object.keys(f.cssmodules).reduce(
          (c_acc, c) => extend(c_acc, { [`${f.basename}.${c}`]: f.cssmodules[c] }),
          {}
        );

        return extend(f_acc, f_cssmodules);
      },
      {}
    );

    return [extend(def, { content, cssmodules })];

  });

};
