const { clone, copy, metadata, read, rename, templates, write } = require('static-base-contrib');
const { exec, runWithMessageAndLimiter } = require('static-base-preset');
const { resolve } = require('path');
const css = require('./functions/css');
const electron = require('./functions/electron');
const elm = require('./functions/elm');
const minify = require('./functions/minify');
const Mustache = require('mustache');


/**
 * More functions
 */

// keep the cssmodules in memory so that it is always available
// to the html sequence.
let cssmodules;

const storecssmodules = files => {
  cssmodules = JSON.stringify(files[0].cssmodules);
  return [...files];
};

// template renderer
const render = (template, data) => Mustache.render(template, data);



/**
 * Sequences
 */
const elmSequence = attr => runWithMessageAndLimiter
  ('Building Elm')
  (attr.priv.changedPath, `${attr.priv.sourceDirectory}/**/*.elm`)
  (
    [elm, `${attr.priv.buildDirectory}/application.js`]
  )
  (`${attr.priv.sourceDirectory}/Main.elm`, attr.priv.root);


const minifyElmSequence = attr => runWithMessageAndLimiter
  ('Minifying compiled Elm code')
  (attr.priv.changedPath)
  (
    read,
    minify,
    [write, attr.priv.buildDirectory]
  )
  (`${attr.priv.buildDirectory}/application.js`, attr.priv.root);


const cssSequence = attr => runWithMessageAndLimiter
  ('Building CSS')
  (attr.priv.changedPath)
  (
    read,
    css,
    [write, attr.priv.buildDirectory],
    storecssmodules
  )
  (`${attr.priv.sourceDirectory}/**/*.pcss`, attr.priv.root);


const htmlSequence = attr => runWithMessageAndLimiter
  ('Building HTML')
  (attr.priv.changedPath, `${attr.priv.sourceDirectory}/**/*.{pcss,mustache}`)
  (
    read,
    [rename, 'Main.mustache', 'index.html'],
    [clone, 'index.html', '200.html'],
    [metadata, { cssmodules }],
    [templates, render],
    [write, attr.priv.buildDirectory]
  )
  (`${attr.priv.sourceDirectory}/Main.mustache`, attr.priv.root);


const favIconsSequence = attr => runWithMessageAndLimiter
  ('Copying favicons')
  (attr.priv.changedPath)
  (
    [copy, attr.priv.buildDirectory]
  )
  (`./favicons/**/*.*`, attr.priv.root);


// Electron

const electronSetupSequence = attr => runWithMessageAndLimiter
  ('Setting up Electron')
  (attr.priv.changedPath)
  (
    [read],
    [rename, 'index.js', 'electron.js'],
    [write, attr.priv.buildDirectory]
  )
  (`./electron/**/*`, attr.priv.root);


const electronPackage = attr => runWithMessageAndLimiter
  ('Build Electron packages')
  (attr.priv.changedPath)
  (
    [electron, './build-electron', { dir: attr.priv.buildDirectory }]
  )
  ();


const emptySequence = _ => Promise.resolve([]);



/**
 * Exec
 */
exec([
  elmSequence,
  process.argv.includes('--minify') ? minifyElmSequence : emptySequence,

  cssSequence,
  htmlSequence,
  favIconsSequence,

  electronSetupSequence,
  process.argv.includes('--pack') ? electronPackage : emptySequence,

], {
  rootDirectory: resolve(__dirname, '../'),
  buildDirectory: './build',
  sourceDirectory: './app',

}).catch(
  error => console.error(error.stack || error.toString())

);
