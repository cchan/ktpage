# ktpage

Content comes from `content/clive.yml`. HTML markup happens in `src/template.hbs`.
Themes are in `src/themes`. Output goes to `dist/index.html`.

## How to use the templater

Go to [cchan.github.io/ktpage](https://cchan.github.io/ktpage)!

To run locally, you need [git](https://git-scm.com/) and [NodeJS](https://nodejs.org) installed and in `PATH` first.

    git clone https://github.com/cchan/ktpage
    cd ktpage
    npm install
    npm start

## How this is going to work:

1. The user gives us some basic starter information, either in YAML or as something more accessible like a webform.
(the theme and color customization also happens in YAML.) This is on the left panel of their screen.
2. We compile that in (reasonably) real time and hand the finished HTML result to the user, and also update the live website.
3. Later on, add the feature that advanced students may edit the generated HTML directly.
