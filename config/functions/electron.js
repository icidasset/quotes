const { join, resolve } = require('path');
const packager = require('electron-packager');


module.exports = function electron(_, destination, options) {
  const root = resolve(__dirname, '../../');
  const srcDir = join(root, options.dir);
  const desDir = join(root, destination);

  return new Promise((resolve, reject) => {
    packager({ dir: srcDir, out: desDir }, (err, appPaths) => {
      if (err) reject(err);
      else resolve([]);
    });
  })
};
