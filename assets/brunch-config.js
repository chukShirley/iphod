exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"

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
      //     "web/static/vendor/js/jquery-3.2.1.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: 'css/app.css'
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "static",
      "css",
      "js",
      "vendor",
      "elm",
      "elm/Iphod"
    ],

    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    elmBrunch: {
      // saying "elmFolder: 'elm'", sort of does a cd elm for what follows
      // thus the executablePath needs to back up with '..'
      elmFolder: 'elm',
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
      executablePath: '../node_modules/elm/binwrappers',
      // executablePath: '/usr/local/bin',
      outputFolder: '../vendor/js',
      // outputFile: 'bundle.js',
      makeParameters: ['--warn']
    },
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    sass: {
      options: {
        includePaths: [
          "node_modules/bootstrap-sass/assets/stylesheets",
          "node_modules/font-awesome/scss",
          "node_modules/toastr"
        ], // tell sass-brunch where to look for files to @import
      },
      precision: 8 // minimum precision required by bootstrap-sass
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
      // "js/local_office.js": ["js/local_office"]
    }
  },

  npm: {
    enabled: true,
    globals: {
      $: 'jquery',
      jQuery: 'jquery'
    }
  }
};
