// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".


// LOCAL STORAGE ------------------------

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

function save_version(abbr) {
  var s = window.localStorage
    , t = s.getItem("iphod_vers");
  if (t == null) { 
    t = [];
  }
  else {
    t = t.split(",");
  };
  if (t.indexOf(abbr) >= 0) {return true;};
  t.push(abbr);
  t = t.toString();
  s.setItem("iphod_vers", t);
  return true
}

function unsave_version(abbr) {
  var s = window.localStorage
    , t = s.getItem("iphod_vers");
  if (t == null) return true;
  t = t.split(",");
  t = t.filter(remove_abbr, abbr);
  t = t.toString();
  s.setItem("iphod_vers", t);
  return true;
}
function remove_abbr(v, i, ary){
  return v != this;
}


// SOCKETS ------------------------

import "./menu"
import socket from "./socket"

let path = window.location.pathname

// mobile landing page

console.log("PATH: ", path)

if ( path.match(/mindex/)) {

  console.log("MOBILE INDEX")
  var elmHeaderDiv = document.getElementById('header-elm-container')
    , elmHeaderApp = Elm.Header.embed(elmHeaderDiv)

}

// landing page, calendar

if ( path == "/" || path.match(/calendar/) || path.match(/mindex/)) {
  
  let channel = socket.channel("iphod:readings")
  channel.join()
    .receive("ok", resp => { 
      console.log("Joined Iphod successfully", resp);
      elmHeaderApp.ports.portConfig.send(init_config_model());
    })
    .receive("error", resp => { console.log("Unable to join Iphod", resp) })
    
  channel.push("init_calendar", "");

if ( path.match(/mindex/)) {

  console.log("MOBILE INDEX")
  var elmHeaderDiv = document.getElementById('header-elm-container')
    , elmHeaderApp = Elm.Header.embed(elmHeaderDiv)

}
  
  
  // header
  
  elmHeaderApp.ports.sendEmail.subscribe(function(email) {
    channel.push("request_send_email", email)
  })
  
  elmHeaderApp.ports.saveConfig.subscribe(function(config) {
    // {ot: "ESV", ps: "BCP", nt: "ESV", gs: "ESV", fnotes: "fnotes"}
    if ( storageAvailable('localStorage') ) {
      let s = window.localStorage;
      s.setItem("iphod_ot", config.ot)
      s.setItem("iphod_ps", config.ps)
      s.setItem("iphod_nt", config.nt)
      s.setItem("iphod_gs", config.gs)
      s.setItem("iphod_fnotes", config.fnotes)
      s.setItem("iphod_vers", config.vers.join(","))
      s.setItem("iphod_current", config.current)
    }
  })

  // mindex

    var elmMindexDiv = document.getElementById('m-elm-container')
    , elmMindexApp = Elm.MIndex.embed(elmMindexDiv)

  
  // calendar 
  
  function rollup() {
    $(".calendar-week").hide();
    $("#rollup").text("Roll Down");
  }
  function rolldown() {
    $(".calendar-week").show();
    $("#rollup").text("Roll Up");   
  }
  
  $("#rollup").click( function() {
    $(".calendar-week").is(":visible") ? rollup() : rolldown()
  });

  $(".prayer-button").click(function() {
    let prayer_type = $(this).attr("data-prayer")
      , ps = get_init("iphod_ps", "Coverdale")
      , ver = get_init("iphod_current", "ESV");
    console.log("PRAYER BUTTON: ", prayer_type, ver)
    window.location = "/" + prayer_type + "/" + ps + "/" + ver
  })
  
  channel.on('eu_today', data => {
    data.config = init_config_model();
    elmCalApp.ports.portEU.send(data);
    rollup();
  })
    
  channel.on('mp_today', data => {
    data.config = init_config_model();
    elmCalApp.ports.portMP.send(data)
    rollup();
  })
    
  channel.on('ep_today', data => {
    data.config = init_config_model();
    elmCalApp.ports.portEP.send(data)
    rollup();
  })
  
  channel.on('update_lesson', data => {
    data.config = init_config_model();
    elmCalApp.ports.portLesson.send(data.lesson);
  })
  
  $(".reading_button").click( function() {
    let date = $(this).attr("data-date")
      , of_type = $(this).attr("data-type");
    channel.push("get_text", [of_type, date]);
  });
  
  var elmCalDiv = document.getElementById('cal-elm-container')
    , elmCalApp = Elm.Calendar.embed(elmCalDiv)
  
  elmCalApp.ports.requestReading.subscribe(function(request) {
    channel.push("get_lesson", request)
  })
}


// translations
if ( path.match(/versions/) ) {
  let trans_channel = socket.channel("versions")
  trans_channel.join()
    .receive("ok", resp => { 
      // console.log("Joined Versions successfully", resp);
    })
    .receive("error", resp => { console.log("Unable to join Iphod", resp) })
  
  var elmTransDiv = document.getElementById("elm-versions")
    , elmTransApp = Elm.Translations.embed(elmTransDiv)
  
  trans_channel.on("all_versions", data => {
    var saved_vers = init_config_model().vers;
    data.list.forEach(function(ver){
      if (saved_vers.includes(ver.abbr)) {ver.selected = true;}
    })
    data.list.sort(function(a,b) {
      if (a.selected && !b.selected) {return -1};
      if (!a.selected && b.selected) {return 1};
      if (a.abbr < b.abbr) {return -1};
      if (a.abbr > b.abbr) {return 1};
      return 0;
    })
    elmTransApp.ports.allVersions.send(data.list);
  });
  
  elmTransApp.ports.updateVersions.subscribe(function(version){
    if (version.selected) { save_version(version.abbr) }
    else { unsave_version(version.abbr) }
  })
}

