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
import "phoenix_html";
import $ from 'jquery';
import {LitYear} from "./lityear"
var moment = require('moment')
  , markdown = require('markdown').markdown
  , path = window.location.pathname
  , path_parts = path.split("/").filter( function(el) {return el.length > 0})
  , page = (path_parts.length > 0) ? path_parts[0] : 'office'
  , isOffice = ["mp", "morningPrayer", "midday", "ep", "eveningPrayer"].indexOf(page) >= 0
  , preferenceList = undefined // set in initElmHeader
  , preferenceObj = undefined // set in initElmHeader
  , now = new moment()
  , date_today = now.format("dddd MMMM D, YYYY")
  , date_today_short = now.format("ddd MMM DD, YYYY")
  , tz = now.format("ZZ")
  , am = now.format("A")
  ;

//  , isOffice = !!(path == "/" || path.match(/office|midday|^\/mp\/|morningPrayer|mp_cutrad|mp_cusimp|晨禱傳統|晨禱簡化|^\/ep\/|eveningPrayer|ep_cutrad|ep_cusimp|晚報傳統祈禱|晚祷简化/))
if (page == "office") { 
  // redirect to correct office based on local time
  var mid = new moment().local().hour(11).minute(30).second(0)
    , ep = new moment().local().hour(15).minute(0).second(0)
    , versions = "/" + preferences.ps + "/" + preferences.ot
    ;
  if ( now.isBefore(mid)) { window.location.replace("/mp" + versions) }
  else if ( now.isBefore(ep) ) { window.location.replace("/midday")}
  else { window.location.replace("/ep" + versions)}
}

var x = new moment();
console.log("LAST SUNDAY", LitYear.dateLastSunday(x));

// PouchDB ..................................
var PouchDB = require('pouchdb')
  , localDB = new PouchDB('preferences')
  , db = new PouchDB('iphod') // to be synced with main couchDB
  , remoteCouch = 'http://127.0.0.1:5984/iphod'
  , dbOpts = {live: true, retry: true}
  , default_prefs = {
      _id: 'preferences'
    , ot: 'ESV'
    , ps: 'BCP'
    , nt: 'ESV'
    , gs: 'ESV'
    , fnotes: "True"
    , vers: ["ESV"]
    , current: "ESV"
    };

function sync() {
  // syncDom.setAttribute('data-sync-state', 'syncing');
  db.replicate.to(remoteCouch, dbOpts, syncError);
  db.replicate.from(remoteCouch, dbOpts, syncError);
}

function syncError() {console.log("SYNC ERROR")};

sync();


function get_preferences(do_this_too) {
  localDB.get('preferences').then(function(resp){
    return do_this_too(resp)
  }).catch(function(err){
    console.log("GET PREFERENCE ERR: ", err)
    return do_this_too(initialize_translations());
  });
}

function initialize_translations() {
  localDB.put( default_prefs ).then(function (resp) {
    return resp
  }).catch(function (err) {
    return prefs;
  });
}

function save_preferences(prefs) {
  prefs._id = "preferences";
  localDB.put(prefs).then(function(resp) {
    preferenceObj = {ot: prefs.ot, ps: prefs.ps, nt: prefs.nt, gs: prefs.gs};
    preferenceList = [prefs.ot, prefs.ps, prefs.nt, prefs.gs];
    return resp;
  }).catch(function(err){
    return prefs;
  })
}

function getPreferenceObj() {
  get_preferences(function(resp) {
    return {ot: resp.ot, ps: resp.ps, nt: resp.nt, gs: resp.gs}
  })
}

function getPreferenceList() {
  get_preferences(function(resp) {
    return [resp.ot, resp.ps, resp.nt, resp.gs]
  })
}

function preference_for(key) { return preferenceObj[key] }


function initElmHeader() { 
  get_preferences(function(resp) {
    preferenceList = [resp.ot, resp.ps, resp.nt, resp.gs];
    preferenceObj = resp
    console.log("PREF OBJ: ", preferenceObj)
    elmHeaderApp.ports.portConfig.send(preferenceObj); 
  })
}


// end of PouchDB......................

// $(".day_options").menu();
// $(".td-bottom").show();

// console.log("APP.JS CSRF TOKEN: ", $("#csrf_token").val())

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
$(".alt_readings-select").click( function() {
  var show_this = "#" + $(this).data("ref");
  $(".this_alt_reading").hide();
  $(show_this).show();
})

$(document).on('input', 'textarea', function () {
  $(this).outerHeight('1em').outerHeight(this.scrollHeight); // 38 or '1em' -min-height
});

$("button.more-options").click( function() {
  $("ul#header-options").toggleClass("responsive");
})

$("input[name='footnote_show']").click(function() {
  $(this).val() == "show" ? $('.footnote, .footnotes').show() : $('.footnote, .footnotes').hide();
})

$("input[name='vss_show']").click(function() {
  $(this).val() == "show" ? $('.verse-num, .chapter-num').show() : $('.verse-num, .chapter-num').hide();
})


// HELPERS ------------------------


// SOCKETS ------------------------

import "./menu"
import socket from "./socket"

if ( page == "stations") {
  var elmStationsDiv = document.getElementById('stations-elm-container')
    , elmStationsApp = Elm.Stations.embed(elmStationsDiv)
    , stationsChannel = socket.channel("stations")

  stationsChannel.join()
    .receive("ok", resp => {
    })
    .receive("error", resp => {
      console.log("Unabld to join Stations", resp)
    })

  elmStationsApp.ports.requestStation.subscribe(function(request) {
      stationsChannel.push("get_station", request)
    })

  stationsChannel.on("single_station", resp => {
    elmStationsApp.ports.portStation.send(resp)
  })

}


// HEADER ++++++++++++++++++++++++++++++++++++++++++++++++++++++++

var elmHeaderDiv = document.getElementById('header-elm-container')
  , elmHeaderApp = Elm.Header.embed(elmHeaderDiv)
  , channel = socket.channel("iphod:readings")

channel.join()
  .receive("ok", resp => {
    // elmHeaderApp.ports.portConfig.send(init_config_model());
  })
  .receive("error", resp => { console.log("Unable to join Iphod", resp) })

elmHeaderApp.ports.portCSRFToken.send($("#csrf_token").val())

initElmHeader();

// elmHeaderApp.ports.portConfig.send(init_config_model());

elmHeaderApp.ports.sendEmail.subscribe( function(email) {
  channel.push("request_send_email", email)
})

elmHeaderApp.ports.saveLogin.subscribe( function(user) {
  // console.log("APP JS: ", user)
  let ls = window.localStorage
  ls.setItem("user", user.username)
  ls.setItem("token", user.token)
})

elmHeaderApp.ports.currentUser.subscribe( function() {
  let ls = window.localStorage
  channel.push("request_user", [ls.getItem("user"), ls.getItem("token")])
})

channel.on("current_user", data => {
  // console.log("CURRENT USER: ", data)
  elmHeaderApp.ports.portUser.send(data)
})

elmHeaderApp.ports.saveConfig.subscribe( function(config) {
  if (isOffice) {
    if ( config.ps != get_version("ps") ) {
      channel.push("get_prayer_reading", ["psalms", config.ps, $("#psalms").data("psalms")])
    }
    if ( config.ot != get_version("ot") ) { // taking OT ver as version for all
      channel.push("get_alt_reading", ["reading1", config.ot, $("#reading1").data("reading1")] )
      channel.push("get_alt_reading", ["reading2", config.ot, $("#reading2").data("reading2")] )
    }
  }
  else { // is Calendar
    if ( $("#eu .readings_table").is(":visible") ) {
      channel.push("get_text", ["EU", $("#readings").data("reading_date"), [config.ps, config.ot, config.nt, config.gs]])
    }
    if ( $("#mp .readings_table").is(":visible") ) {
      channel.push("get_text", ["MP", $("#readings").data("reading_date"), [config.ps, config.ot, config.nt, config.gs]])
    }
    if ( $("#ep .readings_table").is(":visible") ) {
      channel.push("get_text", ["EP", $("#readings").data("reading_date"), [config.ps, config.ot, config.nt, config.gs]])
    }
  }
  if ( storageAvailable('localStorage') ) {
    let s = window.localStorage
      , new_url = false
      , vl = version_list();
      ;
    // if ot, ps, nt, or gs change, we should load a new url if office
    if (isOffice) {
      new_url = !(vl[0] == config.ps && vl[1] == config.ot && vl[2] == config.nt && vl[3] == config.gs)
    }
    s.setItem("iphod_ot", config.ot)
    s.setItem("iphod_ps", config.ps)
    s.setItem("iphod_nt", config.nt)
    s.setItem("iphod_gs", config.gs)
    s.setItem("iphod_fnotes", config.fnotes)
    s.setItem("iphod_vers", config.vers.join(","))
    s.setItem("iphod_current", config.current)
    if (new_url) { window.location.replace("/" + page) }
  }
})


if (isOffice) {
// ALT READINGS...
  channel.on('single_lesson', data => {
    let resp = data.resp[0],
        target = "#" + resp.section;
    $(target).next().replaceWith(resp.body)
  })

  channel.on('alt_lesson', data => {
    let resp = data.resp[0]
    $("#" + resp.id).replaceWith(resp.body)
  })

  $(".alt_reading").change( function(){
    let vss = $(this).val();
    $(this).val("");
    // vss, version, service, section
    channel.push("get_single_reading", [vss, "ESV", $(this).data("reading_target"), "mp"])
  })

  $(".get-reflection").click( function() {
    console.log("REFL ID: ", $(this).data('id'))
    $('div.reflection-markdown').toggle();
    if ( $('div.reflection-markdown').text().length == 0) {
      channel.push('get_text', ['Reflection', $(this).data('id')]);
    }
  })

  channel.on('reflection_today', data => {
    $('div.reflection-markdown').append(markdown.toHTML(data.markdown))
  })

}


// landing page, calendar

if ( page == "calendar" || page == "mindex") {
  // elmHeaderApp.ports.portConfig.send(preferenceObj);
  history.pushState(path, "Legereme", "/calendar");

// BUILD ELM CALENDAR MODEL HERE
  var d = LitYear.firstCalendarSunday(now)
    , endOfCalendar = LitYear.lastCalendarSaturday(now)
    , promisesKept = []
    ;

  while( d.isSameOrBefore(endOfCalendar) ) {
    var thisDay = d.format("dddd MMMM D, YYYY")
      , season = LitYear.getEUkey(d)
      , p1 = db.get(season.key).then(resp => {
            resp.show = false;
            return resp;
          }).catch(function(err){
            console.log("COULD NOT FIND EU KEY: ", err)
          })
      , p2 = db.get(LitYear.getMPEPkey(d).key).then(resp => {
            resp.show = false;
            return resp;
          }).catch(function(err){
            console.log("COULD NOT FIND MPEP KEY: ", err)
          })
      ;
    promisesKept.push( Promise.all([p1, p2, thisDay, season]).then(values => {
      var [eu, mpep, date, season] = values
        , day = { eu: eu
                , daily: mpep
                , date: date
                , season: season.season
                , week: season.week
                , colors: eu.colors
                }
        ;
      return day
      }) // end of Promise.all
    ); // end of promsesKept.push
    d = d.add(1, "day")
  }
  Promise.all(promisesKept).then(values => {
    var month = {weeks: []};
    for( var i=0, j=7; i < values.length; i+=7, j+=7) {
      month.weeks.push( {days: values.slice(i,j)} );
    }
    console.log("MONTH: ", month);
    elmCalApp.ports.portMonth.send(month);
  })

  // mindex
  if ( page == "mindex" ) {
    var elmMindexDiv = document.getElementById('m-elm-container')
    , elmMindexApp = Elm.MIndex.embed(elmMindexDiv)
    , elmMPanelDiv = document.getElementById('m-reading-container')
    , elmMPanelApp = Elm.MPanel.embed(elmMPanelDiv)
    $("#reflection-today-button").click( function() {
      channel.push("get_text", ["Reflection", date_today_short, version_list()])
    });

    $("#next-sunday-button").click( function() {
      channel.push("get_text", ["NextSunday", date_today_short, version_list() ] )
    })

    $("#m-reading-container").click( function() {
      $("#reading-panel").effect("drop", "fast");
    });


    channel.on('reflection_today', data => {
      elmMindexApp.ports.portReflection.send(data);
      rollup();
    })

    channel.on('eu_today', data => {
      data.config = preferenceObj;
      elmMindexApp.ports.portEU.send(data);
      rollup();
    })

    channel.on('mp_today', data => {
      data.config = preferenceObj;
      elmMindexApp.ports.portMP.send(data)
      rollup();
    })

    channel.on('ep_today', data => {
      data.config = preferenceObj;
      elmMindexApp.ports.portEP.send(data)
      rollup();
    })

    channel.on('lf_today', data => {
      window.open(data.leaflet);
    })

    channel.on("single_lesson", data => {
      let resp = data.resp[0];
      resp.show_fn = true;
      resp.show_vn = true;
      elmMindexApp.ports.portLesson.send([resp])
    })

    channel.on('update_lesson', data => {
      data.config = preferenceObj;
      elmMindexApp.ports.portLesson.send(data.lesson);
    })

    elmMindexApp.ports.requestReading.subscribe(function(request) {
      let request_list = [request.section, request.version, request.ref]
      channel.push("get_lesson", request_list)
      // request.push( version_list() )
      // channel.push("get_lesson", request)
    })


    // calendar

    // mobile calendar
    $(".td_link").click( function() {
      var r = $(this).find("readings").data()
        , readings =
            { date: $(this).attr("value")
            , title: r.title
            //, collect: r.collect
            , collect: {instruction: "", title: "", collects: [], show: true} // required place holder
            , mp1: r.mp1.split(",")
            , mp2: r.mp2.split(",")
            , mpp: r.mpp.split(",")
            , ep1: r.ep1.split(",")
            , ep2: r.ep2.split(",")
            , epp: r.epp.split(",")
            , ot: r.ot.split(",")
            , ps: r.ps.split(",")
            , nt: r.nt.split(",")
            , gs: r.gs.split(",")
            , show: true
            , sectionUpdate: { section : "", version : "", ref : "" }
            }
      elmMPanelApp.ports.portReadings.send(readings);
      $("#reading-panel").effect("slide", "fast")
    })

    elmMPanelApp.ports.requestService.subscribe( function(request) {
      request.push( version_list() );
      channel.push("get_text", request )
    })

    elmMPanelApp.ports.requestReflection.subscribe( function(date) {
      var ref = ["Reflection", date];
      ref.push( version_list() )
      channel.push("get_text", ref);
    })

    elmMPanelApp.ports.requestReading.subscribe(function(request) {
      request.push( version_list() )
      channel.push("get_lesson", [request[0], request[2], request[1]])
    })

  } // end of mindex


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

  function showchat(){
    $("#chat-container").show();
    $(".toggle-chat").text("Hide Chat");
    $("#reading-container").css("width", "59%")
  }

  function hidechat(){
    $("#chat-container").hide();
    $(".toggle-chat").text("Show Chat");
    $("#reading-container").css("width", "99%")
  }

  $(".toggle-chat").click( function() {
    $("#chat-container").is(":visible") ? hidechat() : showchat()
  })

  $(".prayer-button").click(function() {
    let prayer_type = $(this).attr("data-prayer")
      , ps = get_init("iphod_ps", "Coverdale")
      , ver = get_init("iphod_current", "ESV");
    window.location = "/" + prayer_type + "/" + ps + "/" + ver
  })

  $("#reflection-today-button").click( function() {
    channel.push("get_text", ["Reflection", date_today_short, version_list() ])
  });

  $("#next-sunday-button").click( function() {
    channel.push("get_text", ["NextSunday", date_today_short, version_list() ] )
  })

  channel.on('latest_chats', data => {
    elmHeaderApp.ports.portInitShout.send( data)
  })

if ( page == "calendar" ) {
  channel.on('alt_lesson', data => {
    // let resp = data.resp[0]

    elmCalApp.ports.portLesson.send(data.resp);
  })

  channel.on('single_lesson', data => {
    let resp = data.resp[0];
    resp.show_fn = true;
    resp.show_vn = true;
    elmCalApp.ports.portLesson.send([resp]);
  })

  channel.on('reflection_today', data => {
    elmCalApp.ports.portReflection.send(data);
    rollup();
  })

  channel.on('eu_today', data => {
    data.config = preferenceObj;
    $("#readings")
      .data("psalms",       readingList(data.ps) )
      .data("psalms_ver",   data.ps[0].version)
      .data("reading1",     readingList(data.ot) )
      .data("reading1_ver", data.ot[0].version)
      .data("reading2",     readingList(data.nt) )
      .data("reading2_ver", data.nt[0].version)
      .data("reading3",     readingList(data.gs) )
      .data("reading3_ver", data.gs[0].version)
      .data("reading_date", data.date)
    elmCalApp.ports.portEU.send(data);
    rollup();
  })

  channel.on('mp_today', data => {
    data.config = preferenceObj;
    $("#readings")
      .data("psalms",       readingList(data.mpp) )
      .data("psalms_ver",   data.mpp[0].version)
      .data("reading1",     readingList(data.mp1) )
      .data("reading1_ver", data.mp1[0].version)
      .data("reading2",     readingList(data.mp2) )
      .data("reading2_ver", data.mp2[0].version)
      .data("reading3",     "")
      .data("reading3_ver", "")
      .data("reading_date", data.date)
    elmCalApp.ports.portMP.send(data)
    rollup();
  })

  function readingList(readings) {
    return readings.map( function(a) {return a.read}).join(", ")
  }

  channel.on('ep_today', data => {
    data.config = preferenceObj;
    $("#readings")
      .data("psalms",       readingList(data.epp) )
      .data("psalms_ver",   data.epp[0].version)
      .data("reading1",     readingList(data.ep1) )
      .data("reading1_ver", data.ep1[0].version)
      .data("reading2",     readingList(data.ep2) )
      .data("reading2_ver", data.ep2[0].version)
      .data("reading3",     "")
      .data("reading3_ver", "")
      .data("reading_date", data.date)
    elmCalApp.ports.portEP.send(data)
    rollup();
  })

  channel.on('lf_today', data => {
    window.open(data.leaflet);
  })

  channel.on('update_lesson', data => {
    data.config = preferenceObj;
    elmCalApp.ports.portLesson.send(data.lesson);
  })

  $(".leaflet").click( function() {
    window.open($(this).attr("data-leafletUrl"));
  });

  $(".reflection").click( function() {
    var reflID = $(this).attr("data-reflID").toString();
    if (reflID > 0) { channel.push("get_text", ["Reflection", reflID]) }
  })

  $(".reading_menu").click( function() {
    var date = $(this).attr("data-date")
      , of_type = $(this).attr("data-type");
    if (date == null) { date = date_today; };
    var request = [of_type, date, version_list()];
    channel.push("get_text", request);
  });

  var elmCalDiv = document.getElementById('cal-elm-container')
    , elmCalApp = Elm.Iphod.embed(elmCalDiv)

  if ( !!$("#these_readings").data("service") ) {
    // where the problem was
    var this_service = $("#these_readings").data("service")
      , this_date = $("#these_readings").data("date")
      , request = [this_service, this_date];

    request.push( version_list() );
    channel.push("get_text", request);
    $(window).scrollTop(0);
  }

  elmCalApp.ports.requestReading.subscribe(function(request) {
    let request_list = [request.section, request.version, request.ref]
    channel.push("get_lesson", request_list)
  })

  elmCalApp.ports.requestAltReading.subscribe(function(request) {
    var [section, ver, vss] = request;
    ver = get_version(section)
    channel.push("get_alt_reading", [section, ver, vss])
  })

  elmCalApp.ports.requestScrollTop.subscribe(function(request) {
    // if needs be, request to be used to scroll to a location from top
    // use `setTimeout` to give page a chance to load
    setTimeout("$(window).scrollTop(0)", 15);
  })
}

}

if ( page == "communiontosick" ) {
  let communiontosick_channel = socket.channel("iphod:readings")
  communiontosick_channel.join()
    .receive("ok", resp => {
      // console.log("Joined Versions successfully", resp);
    })
    .receive("error", resp => { console.log("Unable to join Iphod", resp) })

  $(".psalm-button").click( function() {
    let psalm = "psalm " + $(this).data("psalm")
      , section = "ps"
      , version = get_version(section);
    communiontosick_channel.push("get_alt_reading", [section, version, psalm]);
  })

  communiontosick_channel.on("alt_lesson", data => {
    let psalm = data.resp[0].body
    $("#sick-communion-psalm").html(psalm)
  })
}


// translations
if ( page == "versions" ) {
  let trans_channel = socket.channel("versions")
  trans_channel.join()
    .receive("ok", resp => {
      // console.log("Joined Versions successfully", resp);
    })
    .receive("error", resp => { console.log("Unable to join Iphod", resp) })

  var elmTransDiv = document.getElementById("elm-versions")
    , elmTransApp = Elm.Translations.embed(elmTransDiv)

  trans_channel.on("all_versions", data => {
    var saved_vers = preferenceObj.vers;
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

// resources
if ( ["resources", "humor", "inserts"].indexOf(page) >= 0 ) {
  let resc_channel = socket.channel("resources")
  resc_channel.join()
    .receive("ok", resp => {
      // console.log("Joined Resources successfully");
    })
    .receive("error", resp => { console.log("Unable to join Resources", resp) });

  let elmRescDiv = document.getElementById("resources-container")
    , elmRescApp = Elm.Resources.embed(elmRescDiv);

  resc_channel.push(page, "");

  resc_channel.on("all_resources", data => {
    elmRescApp.ports.allResources.send(data.list)
  });

  $("#insult_me").click( function() {
    resc_channel.push("insult", "");
  })

  resc_channel.on("give_offence", data => {
    $("#insult").text(data.insult)
  })


}

// reflections
if ( page == "reflections" && (path_parts[1] == "new" || path_parts[2] == "edit") ) {
  var elmReflDiv = document.getElementById("reflection-elm-container")
    , elmReflApp = Elm.NewReflection.embed(elmReflDiv)
    , refl_channel = socket.channel("reflection")
  refl_channel.join()
    .receive("ok", resp => {
      let refl = {
          id:     $("reflection").data("recno")
        , date:   $("reflection").data("date")
        , author: $("reflection").data("author")
        , text:   $("reflection").data("text")
        , published: $("reflection").data("published")
      }
      // refl_channel.push("reset", $("reflection").data('recno') )
      elmReflApp.ports.portReflection.send(refl);
    })
    .receive("error", resp => {console.log("Failed to join reflection")})

  elmReflApp.ports.portSubmit.subscribe(function(d) {
    refl_channel.push("submit", [d.id, d.date, d.text, d.author, d.published])
  });

  elmReflApp.ports.portReset.subscribe(function(data) {
    refl_channel.push("reset", data.id)
  });

  elmReflApp.ports.portBack.subscribe(function(data) {
    window.location = "/reflections"
  });

  refl_channel.on("reflection", data => {
    console.log("REFLECTION: ", data)
    elmReflApp.ports.portReflection.send(data)
  })

  refl_channel.on("submitted", data => {
    console.log("SUBMITTED: ", data)
  })
} // END OF reflections