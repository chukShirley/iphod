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
import "./menu"
import socket from "./socket"
let channel = socket.channel("iphod")

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("next_sunday", data => {
  elmApp.ports.nextSunday.send(data)
})

channel.on('new_text', data => {
  elmApp.ports.newText.send(data);
})

// Hook up Elm

var elmDiv = document.getElementById('elm-container')
  , config_model = {
        ot: "ESV"
      , ps: "Coverdale"
      , nt: "ESV"
      , gs: "ESV"
      , fnotes: true
    }
  , email_model = {
        addr: ""
      , msg: ""
      , subj: ""
      , show: false
    }
  , sunday_model = {
        ofType: ""
      , date: ""
      , season: ""
      , week: ""
      , title: ""
      , ot: []
      , ps: []
      , nt: []
      , gs: []
      , show: false
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
  }
  , elmApp = Elm.embed(Elm.Iphod, elmDiv, initialState)


elmApp.ports.requestMoveDay.subscribe(function(request) {
  channel.push("request_move_day", request)
});

elmApp.ports.requestText.subscribe(function(request) {
  if ( $("#" + request[0]).text().length == 0 ) {channel.push("request_text", request)}
})

elmApp.ports.requestNamedDay.subscribe(function(request) {
  channel.push("request_named_day", request)
})

elmApp.ports.requestAllText.subscribe(function(request) {
  channel.push("request_all_text", request)
})
