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
    , fnotes: "fnotes"
    , vers: ["ESV"]
    , current: "ESV"
    }
  if ( storageAvailable('localStorage') ) {
    m = { ot: get_init("iphod_ot", "ESV")
        , ps: get_init("iphod_ps", "Coverdale")
        , nt: get_init("iphod_nt", "ESV")
        , gs: get_init("iphod_gs", "ESV")
        , fnotes: get_init("iphod_fnotes", "fnotes")
        , vers: get_versions("iphod_vers", "ESV")
        , current: "ESV"
        }
  }
  return m;
}

function get_versions(arg1, arg2) {
  let versions = get_init(arg1, arg2);
  return versions.split(",");
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

$(".reading_button").click( function() {
  let date = $(this).attr("data-date")
    , of_type = $(this).attr("data-type");
  channel_c.push("get_text", [of_type, date]);
});
 
// SOCKETS ------------------------

import "./menu"
import socket from "./socket"

if (window.location.pathname == "/versions") {
  let channel_v = socket.channel("versions");
  channel_v.join()
    .receive("ok", resp => { console.log("Joined Versions successfully", resp) })
    .receive("error", resp => { console.log("Unable to join Versions", resp) })
  
  var elmDiv = document.getElementById('elm-container')
    , initialState = {
        allVersions: []
    } 
    , elmApp = Elm.embed(Elm.Translations, elmDiv, initialState);
  
//  channel_v.on("version", data => {
//    elmApp.ports.thisVersion.send(data);
//  })

  channel_v.on("all_versions", data => {
    let list = data.list
      , in_use = get_versions("iphod_vers", "ESV");
    list.forEach(function(ver) {
      if (in_use.indexOf(ver.abbr) > -1) { ver.selected = true }
    });
    elmApp.ports.allVersions.send(list);
  })

  channel_v.push("request_list", "");

  elmApp.ports.requestSaveVersion.subscribe(function(request) {
    let   cmnd = request[0]
        , ver  = request[1];
    if (cmnd == "save") {
      save_version(ver.abbr);
    } 
    else {
      unsave_version(ver.abbr);
    }
  });

}

if (window.location.pathname == "/calendar") {
  var channel_c = socket.channel("calendar");
  channel_c.join()
    .receive("ok",    resp => {console.log("Joined Calendar successfully", resp)})
    .receive("error", resp => {console.log("Unable to join Calendar", resp)})

  var elmDiv = document.getElementById('elm-container')
    , initialState = {
        thisMonth: {
          calendar: [],
          month:    "",
          year:     ""
        }
    }
    , elmApp = Elm.embed(Elm.Calendar, elmDiv, initialState)

  channel_c.on("this_month", data => {
    var z = data.calendar,
        icm = init_config_model();
    z.forEach( function(week){
      week.days.forEach( function(day){
        day.daily.config = icm;
        day.daily.show = false;
        day.daily.justToday = false;
        day.sunday.config = icm;
        day.sunday.show = false;
        day.sunday.ofType = "sunday"
      })
    })
    elmApp.ports.thisMonth.send( data )
  })

  channel_c.push("request_calendar", "")

  elmApp.ports.requestMoveMonth.subscribe(function(request) {
    console.log("MOVE MONTH: ", request)
    // channel_c.push("request_move_month", request)
  })
}


if (window.location.pathname == "/") {

  let channel = socket.channel("iphod:readings")
  channel.join()
    .receive("ok", resp => { console.log("Joined Iphod successfully", resp) })
    .receive("error", resp => { console.log("Unable to join Iphod", resp) })
  
  channel.push("request_today", "");
  channel.on("next_sunday", data => {
      var z = data,
          icm = init_config_model();
      z.config = icm;
      z.daily.config = icm;
      z.sunday.config = icm;
      z.redLetter.config = icm;
      z.eveningPrayer.config = icm;
      z.morningPrayer.config = icm;
    
      elmApp.ports.nextSunday.send(z);
  })
  
  channel.on('new_text', data => {
    elmApp.ports.newText.send(data);
  })
  
  channel.on('new_email', data => {
    elmApp.ports.newEmail.send(data);
  })


  // Hook up Elm
  
  
  var elmDiv = document.getElementById('elm-container')
    , config_model = {
        ot: ""
      , ps: ""
      , nt: ""
      , gs: ""
      , fnotes: ""
      , vers: []
      , current: "ESV"
    }
    , sunday_collect_model = {
        instruction: "String"
      , title: ""
      , collects: []
      , show: false
    }
    , email_model = {
          from: ""
        , topic: ""
        , text: ""
        , show: false
      }
    , sunday_model = {
          ofType: ""
        , date: ""
        , season: ""
        , week: ""
        , title: ""
        , colors: []
        , collect: sunday_collect_model
        , ot: []
        , ps: []
        , nt: []
        , gs: []
        , show: false
        , config: config_model
      }
    , daily_reading = {
          date: ""
        , season: ""
        , week: ""
        , day: ""
        , title: ""
        , mp1: []
        , mp2: []
        , mpp: []
        , ep1: []
        , ep2: []
        , epp: []
        , show: false
        , justToday: false
        , config: config_model
      }
    , initialState = {
        nextSunday: {
            today:         ""
          , sunday:        sunday_model
          , redLetter:     sunday_model
          , daily:         daily_reading
          , morningPrayer: daily_reading
          , eveningPrayer: daily_reading
          , email:         email_model
          , config:        config_model
          , about:         false
        }
      , newText:   { 
          model:    ""
        , section:  ""
        , id:       ""
        , body:     ""
        , version:  ""
        }
      , newEmail: email_model
    }
    , elmApp = Elm.embed(Elm.Iphod, elmDiv, initialState)
  
  
  
  elmApp.ports.requestMoveDate.subscribe(function(request) {
    channel.push("request_move_date", request)
  });
  
  elmApp.ports.requestMoveDay.subscribe(function(request) {
    channel.push("request_move_day", request)
  });
  
  elmApp.ports.requestText.subscribe(function(request) {
    var model = {};
    request.forEach( function(tuple) {
      model[tuple[0]] = tuple[1];
    })
  if ( $("#" + request[0]).text().length == 0 ) {channel.push("request_text", model)}
  })
  
  elmApp.ports.requestNamedDay.subscribe(function(request) {
    channel.push("request_named_day", request)
  })
  
  elmApp.ports.requestAllText.subscribe(function(request) {
    channel.push("request_all_text", request)
  })
  
  elmApp.ports.sendEmail.subscribe(function(email) {
    channel.push("request_send_email", email)
  })
  
  elmApp.ports.savingConfig.subscribe(function(config) {
    // {ot: "ESV", ps: "BCP", nt: "ESV", gs: "ESV", fnotes: "fnotes"}
    if ( storageAvailable('localStorage') ) {
      let s = window.localStorage
      s.setItem("iphod_ot", config.ot)
      s.setItem("iphod_ps", config.ps)
      s.setItem("iphod_nt", config.nt)
      s.setItem("iphod_gs", config.ot)
      s.setItem("iphod_fnotes", config.fnotes)
    }
  })
}


