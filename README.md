# ktpage

Content comes from `content/clive.yml`. HTML markup happens in `src/template.hbs`.
Themes are in `src/themes`. Output goes to `dist/index.html`.

## How to use the templater

You need [NodeJS](https://nodejs.org) installed and in `PATH` first.

    git clone https://github.com/cchan/ktpage
    cd ktpage
    npm install
    node compile.js

## How this is going to work:

1. The user gives us some basic information, either in YAML or as something more accessible.
2. We compile that into a template and hand it to the user.
3. The user can
