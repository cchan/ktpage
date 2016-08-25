const Handlebars = require('handlebars');
const YAML = require('yamljs');
const traverse = require('traverse');
const marked = require('marked');
const fs = require('fs');

//Read the template and compile it as a Handlebars template.
var template = Handlebars.compile(fs.readFileSync('template.hbs').toString());

//Read the content from the YAML file (could be from any other source, like a database)
//and process it into a JavaScript object.
var content = YAML.load('content.yml');

//Traverse the entire content object and compile Markdown for all multiline strings.
traverse(content).forEach(function(x){
  if(typeof x == "string" && x.includes('\n'))
    return marked(x);
});

//Write the resulting output to index.html.
fs.writeFile('index.html', template(content));
