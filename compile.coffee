traverse = require 'traverse'

window.compileYAML = (yaml) ->
  # Read the content from the YAML file (could be from any other source, like a database)
  # and process it into a JavaScript object.
  content = jsyaml.safeLoad yaml
  content.__templater = {}

  unless content.theme then console.error 'no theme specified in YAML'

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

  content.__templater.contact = processContacts content.contact

  # Traverse the entire content object and compile Markdown for all multiline strings.
  traverse(content).forEach (x) -> marked(x) if typeof x is "string" and x.includes '\n'

  htmlpromise =
  Promise.resolve $.get 'src/template.hbs'
  .then (data) -> Handlebars.compile data    # Read the HTML template and compile it as a Handlebars template
  .catch (err) -> console.error 'HTML template loading error:', err.stack || err

  sasspromise =
  Promise.resolve $.get 'src/themes/' + content.theme + '.sass'
  .then (data) ->
    new Promise (resolve, reject) ->
      sass.compile Handlebars.compile(data)(content), {indentedSyntax: true}, (sassresult) -> # Use the read Sass, compile and populate it as a Handlebars template, and render it as CSS
        if sassresult.status isnt 0 then reject sassresult.formatted
        else resolve sassresult.text
  .catch (err) -> console.error 'Sass loading error:', err.stack || err

  jspromise =
  Promise.resolve $.get 'src/themes/' + content.theme + '.js'
  .catch (err) -> console.error 'JavaScript loading error:', err.stack || err

  return Promise.all [htmlpromise, sasspromise, jspromise]
  .spread (htmltemplate, css, js) ->
    content.__templater.css = css
    content.__templater.js = js
    htmltemplate content
