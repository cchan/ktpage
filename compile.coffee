traverse = require 'traverse'

# http://code-maven.com/handlebars-conditionals
Handlebars.registerHelper 'if_eq', (a, b, opts) ->
  if a == b then opts.fn this
  else opts.inverse this

hbsCache = {}
hbsFetchOne = (url) ->
  return Promise.resolve $.get url
    .then (data) -> Handlebars.compile data
hbsFetch = (type) ->
  if hbsCache[type]? then hbsCache[type]
  else
    hbsCache[type] = Promise.resolve [
      hbsFetchOne("src/views/#{type}.hbs"),
      hbsFetchOne("src/styles/#{type}.sass"),
      hbsFetchOne("src/scripts/#{type}.js")
    ]

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

window.compileYAML = (yaml) ->
  if typeof yaml != 'string' then throw new TypeError 'No YAML string provided to compileYAML'
  
  # Read the content from the YAML file (could be from any other source, like a database)
  # and process it into a JavaScript object.
  content = jsyaml.safeLoad yaml
  unless content.template.type then console.error 'no template.type specified in YAML'
  
  # Traverse the entire content object and compile Markdown for all multiline strings.
  traverse(content).forEach (x) -> marked(x) if typeof x is "string" and x.includes '\n'
  
  # Add processed contacts ready for templating
  content.__templater = {}
  content.__templater.contact = processContacts content.contact
  
  hbsFetch content.template.type
  .spread (htmlhbs, sasshbs, jshbs) ->
    new Promise (resolve, reject) ->
      sass.compile sasshbs(content), {indentedSyntax: true}, (sassresult) -> # Use the read Sass, compile and populate it as a Handlebars template, and render it as CSS
        if sassresult.status isnt 0 then reject sassresult.formatted
        else resolve [htmlhbs, sassresult.text, jshbs]
  .spread (htmlhbs, css, jshbs) ->
    content.__templater.css = css
    content.__templater.js = jshbs content
    htmlhbs content
