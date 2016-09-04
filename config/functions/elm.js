const { spawn } = require('child_process');


module.exports = function elm(files, outputPath) {
  const promises = files.map(f => {
    return new Promise((resolve, reject) => {
      const s = spawn(
        `elm-make`,
        [`${f.wd}/${f.path}`, `--output`, outputPath, `--yes`],
        { cwd: f.root, stdio: "inherit" }
      );

      s.on('error', reject);
      s.on('close', _ => resolve(f));
    });
  });

  return Promise.all(promises);
};
