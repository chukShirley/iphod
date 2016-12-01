// local_office.js
// used by web/templates/layout/local_office.html.eex
// get local time and localStorage
// and passes on to :office in Iphod.PrayerController

var now = new Date()
  , tz = now.toString().split("GMT")[1].split(" (")[0] // timezone, i.e. -0700
  , am = now.toString().split(" ")[4] < "12"
  , vers = get_version("ps") + "/" + get_version("ot");
console.log("VERSIONS: ", vers)
if (am) { window.location.href = "office/mp/" + vers }
if (!am) { window.location.href = "office/ep/" + vers }

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
  }
  catch(e) { return false;}
}

function get_init(arg, arg2) {
  var s = window.localStorage
    , t = s.getItem(arg)
  if (t == null) { 
        s.setItem(arg, arg2);
        t = arg2;
      }
  return t;
}
function init_config_model() {
  var m = { ot: "ESV"
    , ps: "Coverdale"
    , nt: "ESV"
    , gs: "ESV"
    , fnotes: "True"
    , vers: ["ESV"]
    , current: "ESV"
    }
  if ( storageAvailable('localStorage') ) {
    m = { ot: get_init("iphod_ot", "ESV")
        , ps: get_init("iphod_ps", "Coverdale")
        , nt: get_init("iphod_nt", "ESV")
        , gs: get_init("iphod_gs", "ESV")
        , fnotes: get_init("iphod_fnotes", "True")
        , vers: get_versions("iphod_vers", ["ESV"])
        , current: get_init("iphod_current", "ESV")
        }
  }
  return m;
}

function get_versions(arg1, arg2) {
  var versions = get_init(arg1, arg2)
    , version_list = versions.split(",");
  return version_list;
}

function get_version(arg) {
  var m = { ot: "ESV"
  , ps: "Coverdale"
  , nt: "ESV"
  , gs: "ESV"
  }
  return get_init("iphod_" + arg, m[arg])
}
