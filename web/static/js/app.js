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

import socket from "./socket"
let channel = socket.channel("iphod")

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("next_sunday", data => {
//  $(".esv_text").text("");
  elmApp.ports.nextSunday.send(data)
})

//channel.on('nextSundayReadings', data => {
//  elmApp.ports.nextSundayReadings.send(data)
//})

channel.on('esv_text', data => {
  elmApp.ports.newSundayText.send(data);
// document.getElementById(data.reading).innerHTML = data.body;
})

// Hook up Elm

var elmDiv = document.getElementById('elm-container')
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
    }
  , daily_reading = {
        date: ""
      , season: ""
      , week: ""
      , day: ""
      , title: ""
      , morning1: []
      , morning2: []
      , evening1: []
      , evening2: []
      , show: false
      , justToday: false
    }
  , initialState = {
      nextSunday: {
          today:      ""
        , sunday:     sunday_model
        , redLetter:  sunday_model
        , daily:      daily_reading
      }
    , newSundayText:   { 
        model:    ""
      , section:  ""
      , id:       ""
      , body:     ""
      }
  }
  , elmApp = Elm.embed(Elm.Iphod, elmDiv, initialState)

elmApp.ports.requestNextSunday.subscribe(function(this_day) {
  channel.push("request_next_sunday", this_day)
});

elmApp.ports.requestLastSunday.subscribe(function(this_day) {
  channel.push("request_last_sunday", this_day)
});

elmApp.ports.requestText.subscribe(function(request) {
  if ( $("#" + request[0]).text().length == 0 ) {channel.push("request_text", request)}
  
})
