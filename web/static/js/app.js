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

// CALENDAR BUTTONS

$("#rollup").click( function() {
  if ( $(".calendar-week").is(":visible") ) {
    $(".calendar-week").hide();
    $("#rollup").text("Roll Down");
  }
  else {
    $(".calendar-week").show();
    $("#rollup").text("Roll Up");   
  }
});


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

// SOCKETS ------------------------

import "./menu"
import socket from "./socket"


// if (window.location.pathname == "/") {

  let channel = socket.channel("iphod:readings")
  channel.join()
    .receive("ok", resp => { console.log("Joined Iphod successfully", resp) })
    .receive("error", resp => { console.log("Unable to join Iphod", resp) })
  
  channel.push("request_today", "");
  channel.push("init_calendar", "");
//  channel.on("next_sunday", data => {
//      var z = data,
//          icm = init_config_model();
//      z.config = icm;
//      z.daily.config = icm;
//      z.sunday.config = icm;
//      z.redLetter.config = icm;
//      z.eveningPrayer.config = icm;
//      z.morningPrayer.config = icm;
//    
//      elmApp.ports.nextSunday.send(z);
//  })

// $(".reading_button").click( function() {
//   let date = $(this).attr("data-date")
//     , of_type = $(this).attr("data-type");
//   channel.push("get_text", [of_type, date]);
// });
 

// Hook up Elm

// header

channel.on("init_email", data => {
  data.about = false;
  console.log("INIT_EMAIL: ", data)
  elmHeaderApp.ports.newEmail.send(data)
})

var elmHeaderDiv = document.getElementById('header-elm-container')
  , email_model = {
      from: ""
    , topic: ""
    , text: ""
  }
  , config_model = {
      ot: ""
    , ps: ""
    , nt: ""
    , gs: ""
    , fnotes: ""
    , vers: []
    , current: "ESV"
  }
  , initialHeaderState = {
    newHeader: {
      email: email_model
    , config: config_model
    }
    , newEmail: email_model
  }
  , elmHeaderApp = Elm.embed(Elm.Header, elmHeaderDiv, initialHeaderState)

elmHeaderApp.ports.sendEmail.subscribe(function(email) {
  console.log("SEND EMAIL: ", email)
  channel.push("request_send_email", email)
})


// calendar 

  channel.on('eu_today', data => {
    data.config = init_config_model();
    elmCalApp.ports.newEU.send(data)
  })
  
  channel.on('mp_today', data => {
    data.config = init_config_model();
    elmCalApp.ports.newMP.send(data)
  })
  
  channel.on('ep_today', data => {
    data.config = init_config_model();
    elmCalApp.ports.newEP.send(data)
  })

  elmCalApp.ports.newEU.subscribe( function(data) {
    console.log("NEW EU", data)
  })
  

  var elmCalDiv = document.getElementById('cal-elm-container')
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
    , sunday_model = {
          show: false
        , config: config_model
        , ofType: ""
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
      }
    , mp_model = {
        show:   false
      , config: config_model
      , colors: []
      , date:   ""
      , day:    ""
      , season: ""
      , title:  ""
      , week:   ""
      , mp1:    []
      , mp2:    []
      , mpp:    []
    }
    , ep_model = {
        show:   false
      , config: config_model
      , colors: []
      , date:   ""
      , day:    ""
      , season: ""
      , title:  ""
      , week:   ""
      , ep1:    []
      , ep2:    []
      , epp:    []
    }
    , initialCalState = {
        newCalendar: {
            eu: sunday_model
          , mp: mp_model
          , ep: ep_model
        }
      , newEU: sunday_model
      , newMP: mp_model
      , newEP: ep_model
    }
    , elmCalApp = Elm.embed(Elm.Calendar, elmCalDiv, initialCalState)



// index - I think

//  var elmDiv = document.getElementById('elm-container')
//    , config_model = {
//        ot: ""
//      , ps: ""
//      , nt: ""
//      , gs: ""
//      , fnotes: ""
//      , vers: []
//      , current: "ESV"
//    }
//    , sunday_collect_model = {
//        instruction: "String"
//      , title: ""
//      , collects: []
//      , show: false
//    }
//    , email_model = {
//          from: ""
//        , topic: ""
//        , text: ""
//        , show: false
//      }
//    , sunday_model = {
//          ofType: ""
//        , date: ""
//        , season: ""
//        , week: ""
//        , title: ""
//        , colors: []
//        , collect: sunday_collect_model
//        , ot: []
//        , ps: []
//        , nt: []
//        , gs: []
//        , show: false
//        , config: config_model
//      }
//    , daily_reading = {
//          date: ""
//        , season: ""
//        , week: ""
//        , day: ""
//        , title: ""
//        , mp1: []
//        , mp2: []
//        , mpp: []
//        , ep1: []
//        , ep2: []
//        , epp: []
//        , show: false
//        , justToday: false
//        , config: config_model
//      }
//    , initialState = {
//        nextSunday: {
//            today:         ""
//          , sunday:        sunday_model
//          , redLetter:     sunday_model
//          , daily:         daily_reading
//          , morningPrayer: daily_reading
//          , eveningPrayer: daily_reading
//          , email:         email_model
//          , config:        config_model
//          , about:         false
//        }
//      , newText:   { 
//          model:    ""
//        , section:  ""
//        , id:       ""
//        , body:     ""
//        , version:  ""
//        }
//      , newEmail: email_model
//    }
//    , elmApp = Elm.embed(Elm.Iphod, elmDiv, initialState)
  
  
//  elmApp.ports.requestMoveDate.subscribe(function(request) {
//    channel.push("request_move_date", request)
//  });
//  
//  elmApp.ports.requestMoveDay.subscribe(function(request) {
//    channel.push("request_move_day", request)
//  });
//  
//  elmApp.ports.requestText.subscribe(function(request) {
//    var model = {};
//    request.forEach( function(tuple) {
//      model[tuple[0]] = tuple[1];
//    })
//  if ( $("#" + request[0]).text().length == 0 ) {channel.push("request_text", model)}
//  })
//  
//  elmApp.ports.requestNamedDay.subscribe(function(request) {
//    channel.push("request_named_day", request)
//  })
//  
//  elmApp.ports.requestAllText.subscribe(function(request) {
//    channel.push("request_all_text", request)
//  })
//  
//  elmApp.ports.sendEmail.subscribe(function(email) {
//    channel.push("request_send_email", email)
//  })
//  
//  elmApp.ports.savingConfig.subscribe(function(config) {
//    // {ot: "ESV", ps: "BCP", nt: "ESV", gs: "ESV", fnotes: "fnotes"}
//    if ( storageAvailable('localStorage') ) {
//      let s = window.localStorage
//      s.setItem("iphod_ot", config.ot)
//      s.setItem("iphod_ps", config.ps)
//      s.setItem("iphod_nt", config.nt)
//      s.setItem("iphod_gs", config.ot)
//      s.setItem("iphod_fnotes", config.fnotes)
//    }
//  })
// }


