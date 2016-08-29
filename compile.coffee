P           = require('bluebird') # Promise
Handlebars  = require('handlebars')
YAML        = require('yamljs')
traverse    = require('traverse')
marked      = require('marked')
fs          = P.promisifyAll(require('fs'))
mkdirp      = P.promisify(require('mkdirp'))
cp          = P.promisify(require('glob-copy'))
Sass        = require('sass.js')

contentfile = process.argv[2] || throw new Error 'No YAML content file provided'

contactTypes =
  email:    prefix: 'mailto:',                  fa: 'envelope'
  twitter:  prefix: 'https://twitter.com/',     fa: 'twitter'
  github:   prefix: 'https://github.com/',      fa: 'github'
  facebook: prefix: 'https://facebook.com/',    fa: 'facebook'
  linkedin: prefix: 'https://linkedin.com/in/', fa: 'linkedin'

processContacts = (contact) ->
  for own type, id of contact
    if contactTypes.hasOwnProperty type
      link:
        if 0 is id.search /https?\:\/\// then id                # If they gave the url, use that
        else contactTypes[type].prefix + encodeURIComponent(id) # Otherwise, figure out the url
      fa: contactTypes[type]?.fa || console.error "can't find fontawesome lookup for " + type
    else if id.link? and id.fa? then {link: id.link, fa: id.fa}
    else console.error "incomplete contact spec for `" + type + "`: need `link` and `fa` properties"

# Write the resulting output to index.html, and copy over the files.
mkdirp './dist'
.then ->
  # Read the content from the YAML file (could be from any other source, like a database)
  # and process it into a JavaScript object.
  content = YAML.load './content/' + contentfile + '.yml'
  
  content.contact = processContacts content.contact
  
  if content.theme? then theme = content.theme else return Promise.reject 'no theme specified in YAML'
  
  # Traverse the entire content object and compile Markdown for all multiline strings.
  traverse(content).forEach (x) ->
    if typeof x is "string" and x.includes '\n'
      marked(x)
  
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
        new Promise (resolve, reject) ->
          Sass.compile template(content), {indentedSyntax: true}, (result) ->
            if result.status is 0 then resolve result.text
            else reject result
      
      # and output it to file
      .then (css) -> fs.writeFile './dist/' + theme + '.css', css
  
  js:
    cp './src/themes/' + theme + '.js', './dist'

.then (tasks) ->
  for own key, promise of tasks
    promise = promise.then -> {task: key, resolved: true}
      .error (e) -> {task: key, resolved: false, err: e}
      .catch (e) -> {task: key, resolved: false, err: e}
.all()
.then (all) ->
  console.log "Error in task '" + resolution.task + "':", resolution.err.stack || resolution.err for resolution in all when not resolution.resolved
  console.log "Resolved."
.catch (e) ->
  console.log "General error:"
  console.log e.stack || e
