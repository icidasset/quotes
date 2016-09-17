const { spawn } = require('child_process');


module.exports = function elm(files, outputPath, options) {
  const opts = options || {};
  const promises = files.map(f => {
    return new Promise((resolve, reject) => {
      let args;

      args = [`${f.wd}/${f.path}`, `--output`, outputPath, `--yes`];
      // TODO: args = opts.minify ? args.concat(['--minify']) : args;

      const s = spawn(
        `elm-make`, args, { cwd: f.root, stdio: "inherit" }
      );

      s.on('error', reject);
      s.on('close', _ => resolve(f));
    });
  });

  return Promise.all(promises);
};
