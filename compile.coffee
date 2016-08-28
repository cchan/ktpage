P = require('bluebird'); # Promise
Handlebars = require('handlebars');
YAML = require('yamljs');
traverse = require('traverse');
marked = require('marked');
fs = P.promisifyAll(require('fs'));
mkdirp = P.promisify(require('mkdirp'));
cp = P.promisify(require('glob-copy'));
sassRender = P.promisify(require('node-sass').render);

contentfile = 'clive'
theme = 'splash1'

# Write the resulting output to index.html, and copy over the files.
mkdirp('./dist')
.catch (x) ->
  console.error "Failure in dir creation:"
  console.error x
.then ->
  # Read the content from the YAML file (could be from any other source, like a database)
  # and process it into a JavaScript object.
  content = YAML.load './content/' + contentfile + '.yml'
  
  # Traverse the entire content object and compile Markdown for all multiline strings.
  traverse(content).forEach (x) ->
    if typeof x is "string" and x.includes '\n'
      marked(x)
  
  tasks =
    html:
      fs.readFileAsync './src/template.hbs'
        .then (file) ->
          # Read the HTML template and compile it as a Handlebars template
          template = Handlebars.compile file.toString()
          # And write it to the file
          fs.writeFile './dist/index.html', template(content)
    
    sass:
      fs.readFileAsync './src/themes/' + theme + '.sass'
        .then (file) ->
          # Read the Sass styles and compile it as a Handlebars template
          template = Handlebars.compile file.toString()
          # Render it as CSS
          sassRender
            data: template(content)
            indentedSyntax: true
        # and output it to file
        .then (css) -> fs.writeFile './dist/' + theme + '.css', css.css
    
    js:
      cp './src/themes/' + theme + '.js', './dist'

  for own key, promise of tasks
      promise.error (err) ->
        console.error 'Error in task ' + key + ':'
        console.error err.stack
      .catch (err) ->
        console.error 'Non-Error failure in task ' + key + ':'
        console.error err
