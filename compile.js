const Handlebars = require('handlebars');
const YAML = require('yamljs');
const traverse = require('traverse');
const marked = require('marked');
const fs = require('fs');
const mkdirp = require('mkdirp');
const cp = require('glob-copy');

//Read the template and compile it as a Handlebars template.
var template = Handlebars.compile(fs.readFileSync('src/template.hbs').toString());

//Read the content from the YAML file (could be from any other source, like a database)
//and process it into a JavaScript object.
var content = YAML.load('content/clive.yml');

//Traverse the entire content object and compile Markdown for all multiline strings.
traverse(content).forEach(function(x){
  if(typeof x == "string" && x.includes('\n'))
    return marked(x);
});

//Write the resulting output to index.html, and copy over the style files.
mkdirp('dist');
fs.writeFile('dist/index.html', template(content));
cp('./src/themes/*', './dist');
