const Handlebars = require('handlebars');
const YAML = require('yamljs');
const fs = require('fs');

var template = Handlebars.compile(fs.readFileSync('template.hbs').toString());
var content = YAML.load('content.yml');

fs.writeFile('index.html', template(content));
