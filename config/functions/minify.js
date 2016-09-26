const { extend } = require('../utils');
const compile = require('google-closure-compiler-js').compile;


module.exports = function minify(files) {
  return files.map(f => {
    const out = compile({
      jsCode: [{ src: f.content }],
      assumeFunctionWrapper: true,
      languageIn: 'ECMASCRIPT5'
    });

    return extend(f, {
      content: out.compiledCode,
    });
  });
};
