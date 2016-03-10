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
  elmApp.ports.nextSunday.send(data)
})

channel.on('nextSundayReadings', data => {
  elmApp.ports.nextSundayReadings.send(data)
})

// Hook up Elm

var elmDiv = document.getElementById('elm-container')
  , lect_model = {
        date: ""
      , season: ""
      , week: ""
      , title: ""
      , ot: []
      , ps: []
      , nt: []
      , gs: []
      , ot_text: ""
      , nt_text: ""
      , ps_text: ""
      , gs_text: ""
    }
  , initialState = {
      nextSunday: {
        sunday: lect_model,
        nextFeastDay: lect_model,
        today: ""
      }
    }
  , elmApp = Elm.embed(Elm.Iphod, elmDiv, initialState)

elmApp.ports.requestNextSunday.subscribe(function(this_day) {
  channel.push("request_next_sunday", this_day)
});

elmApp.ports.requestLastSunday.subscribe(function(this_day) {
  channel.push("request_last_sunday", this_day)
});
