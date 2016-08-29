# ktpage

Content comes from `content/clive.yml`. HTML markup happens in `src/template.hbs`.
Themes are in `src/themes`. Output goes to `dist/index.html`.

## How to use the templater

You need [NodeJS](https://nodejs.org) installed and in `PATH` first.

    git clone https://github.com/cchan/ktpage
    cd ktpage
    npm install
    ./start

## How this is going to work:

1. The user gives us some basic starter information, either in YAML or as something more accessible.
2. The user chooses the theme and customizes some colors, also in YAML.
3. We compile that into a starter template and hand it to the user.
4. The user can edit the YAML or the template in any way they like in the left panel of their screen.
5. These edits will be (reasonably) instantly reflected on the right panel of their screen and on the live website.
