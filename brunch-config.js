exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: { "js/app.js": /^(?!local_office)/,
                'js/local_office.js': /web\/static\/js\/local_office.?/
              }

      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: { 'css/app.css': /^web\/static\/css\/(?!x).?/,
                'css/readable.css': /^web\/static\/css\/xreadable.?/
            }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "deps/phoenix/web/static",
      "deps/phoenix_html/web/static",
      "web/static",
      "test/static",
      "web/elm/Iphod.elm",
      "web/elm/Translations.elm",
      "web/elm/Resources.elm",
      "web/elm/Header.elm",
      "web/elm/MIndex.elm",
      "web/elm/MPanel.elm",
      "web/elm/Stations.elm",
      "web/elm/NewReflection.elm",
      "web/elm/Iphod/Sunday.elm",
      "web/elm/Iphod/Models.elm",
      "web/elm/Iphod/Login.elm"

    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    elmBrunch: {
      elmFolder: 'web/elm',
      mainModules: [
        'Iphod.elm', 
        'Translations.elm', 
        'Resources.elm',
        'Header.elm',
        'MIndex.elm',
        'MPanel.elm',
        'NewReflection.elm',
        'Stations.elm'
      ],
      outputFolder: '../static/vendor'
    },
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    sass: {
      mode: "native" // This is the important part!
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"],
      "js/local_office.js": ["web/static/js/local_office"]
    }
  },

  npm: {
    enabled: true
  }
};
