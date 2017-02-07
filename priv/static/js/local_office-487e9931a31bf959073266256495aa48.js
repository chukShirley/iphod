(function() {
  'use strict';

  var globals = typeof window === 'undefined' ? global : window;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};
  var aliases = {};
  var has = ({}).hasOwnProperty;

  var expRe = /^\.\.?(\/|$)/;
  var expand = function(root, name) {
    var results = [], part;
    var parts = (expRe.test(name) ? root + '/' + name : name).split('/');
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function expanded(name) {
      var absolute = expand(dirname(path), name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var hot = null;
    hot = hmr && hmr.createHot(name);
    var module = {id: name, exports: {}, hot: hot};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var expandAlias = function(name) {
    return aliases[name] ? expandAlias(aliases[name]) : name;
  };

  var _resolve = function(name, dep) {
    return expandAlias(expand(dirname(name), dep));
  };

  var require = function(name, loaderPath) {
    if (loaderPath == null) loaderPath = '/';
    var path = expandAlias(name);

    if (has.call(cache, path)) return cache[path].exports;
    if (has.call(modules, path)) return initModule(path, modules[path]);

    throw new Error("Cannot find module '" + name + "' from '" + loaderPath + "'");
  };

  require.alias = function(from, to) {
    aliases[to] = from;
  };

  var extRe = /\.[^.\/]+$/;
  var indexRe = /\/index(\.[^\/]+)?$/;
  var addExtensions = function(bundle) {
    if (extRe.test(bundle)) {
      var alias = bundle.replace(extRe, '');
      if (!has.call(aliases, alias) || aliases[alias].replace(extRe, '') === alias + '/index') {
        aliases[alias] = bundle;
      }
    }

    if (indexRe.test(bundle)) {
      var iAlias = bundle.replace(indexRe, '');
      if (!has.call(aliases, iAlias)) {
        aliases[iAlias] = bundle;
      }
    }
  };

  require.register = require.define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has.call(bundle, key)) {
          require.register(key, bundle[key]);
        }
      }
    } else {
      modules[bundle] = fn;
      delete cache[bundle];
      addExtensions(bundle);
    }
  };

  require.list = function() {
    var list = [];
    for (var item in modules) {
      if (has.call(modules, item)) {
        list.push(item);
      }
    }
    return list;
  };

  var hmr = globals._hmr && new globals._hmr(_resolve, require, modules, cache);
  require._cache = cache;
  require.hmr = hmr && hmr.wrap;
  require.brunch = true;
  globals.require = require;
})();

(function() {
var global = window;
var __makeRelativeRequire = function(require, mappings, pref) {
  var none = {};
  var tryReq = function(name, pref) {
    var val;
    try {
      val = require(pref + '/node_modules/' + name);
      return val;
    } catch (e) {
      if (e.toString().indexOf('Cannot find module') === -1) {
        throw e;
      }

      if (pref.indexOf('node_modules') !== -1) {
        var s = pref.split('/');
        var i = s.lastIndexOf('node_modules');
        var newPref = s.slice(0, i).join('/');
        return tryReq(name, newPref);
      }
    }
    return none;
  };
  return function(name) {
    if (name in mappings) name = mappings[name];
    if (!name) return;
    if (name[0] !== '.' && pref) {
      var val = tryReq(name, pref);
      if (val !== none) return val;
    }
    return require(name);
  }
};
require.register("web/static/js/local_office.js", function(exports, require, module) {
"use strict";

// local_office.js
// used by web/templates/layout/local_office.html.eex
// get local time and localStorage
// and passes on to :office in Iphod.PrayerController

var now = new Date(),
    tz = now.toString().split("GMT")[1].split(" (")[0] // timezone, i.e. -0700
,
    am = now.toString().split(" ")[4] < "12",
    vers = get_version("ps") + "/" + get_version("ot"),
    till_midday = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 11, 30) - now,
    till_evening = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 15) - now,
    till_midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 24) - now;

if (till_midday > 0) {
  window.location.href = "/office/mp/" + vers;
} else if (till_evening > 0) {
  window.location.href = "/office/midday";
} else {
  window.location.href = "/office/ep/" + vers;
}

// LOCAL STORAGE ------------------------
// copied from app.js
// someone needs to do some refactoring here
// just saying

function storageAvailable(of_type) {
  try {
    var storage = window[of_type],
        x = '__storage_test__';
    storage.setItem(x, x);
    storage.removeItem(x);
    return true;
  } catch (e) {
    return false;
  }
}

function get_init(arg, arg2) {
  var s = window.localStorage,
      t = s.getItem(arg);
  if (t == null) {
    s.setItem(arg, arg2);
    t = arg2;
  }
  return t;
}
function init_config_model() {
  var m = { ot: "ESV",
    ps: "Coverdale",
    nt: "ESV",
    gs: "ESV",
    fnotes: "True",
    vers: ["ESV"],
    current: "ESV"
  };
  if (storageAvailable('localStorage')) {
    m = { ot: get_init("iphod_ot", "ESV"),
      ps: get_init("iphod_ps", "Coverdale"),
      nt: get_init("iphod_nt", "ESV"),
      gs: get_init("iphod_gs", "ESV"),
      fnotes: get_init("iphod_fnotes", "True"),
      vers: get_versions("iphod_vers", ["ESV"]),
      current: get_init("iphod_current", "ESV")
    };
  }
  return m;
}

function get_versions(arg1, arg2) {
  var versions = get_init(arg1, arg2),
      version_list = versions.split(",");
  return version_list;
}

function get_version(arg) {
  var m = { ot: "ESV",
    ps: "Coverdale",
    nt: "ESV",
    gs: "ESV"
  };
  return get_init("iphod_" + arg, m[arg]);
}
});

;require.register("___globals___", function(exports, require, module) {
  
});})();require('___globals___');

require('web/static/js/local_office');
//# sourceMappingURL=local_office.js.map