var YAML = require("yamljs");


module.exports = YAML.load(
  __dirname.replace(/\/lib\/?$/i, "") + "/config.yml"
);
