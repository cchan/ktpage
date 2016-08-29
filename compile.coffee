traverse = require 'traverse'

window.compileYAML = (yaml, cb) ->
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
  traverse(content).forEach (x) ->
    if typeof x is "string" and x.includes '\n'
      marked(x)
  
  $.get 'src/template.hbs', (data) ->
    # Read the HTML template and compile it as a Handlebars template
    html = Handlebars.compile data
    
    $.get 'src/themes/' + content.theme + '.sass', (data) ->
      # Read the Sass styles and compile it as a Handlebars template
      sasstemplate = Handlebars.compile data
      # Render it as CSS
      sass.compile sasstemplate(content), {indentedSyntax: true}, ({text: css}) ->
        $.get 'src/themes/' + content.theme + '.js', (data) ->
          content.__templater.js = data
          content.__templater.css = css
          cb html content
  return
