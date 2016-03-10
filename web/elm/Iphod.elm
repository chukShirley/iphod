module Iphod where

import Debug

import StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Regex
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects, Never)
import Task exposing (Task)
import String exposing (join)
import Helper exposing (onClickLimited, hideAble)

esvKey = "10b28dac7c57fd96"

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingActions]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias Readings =
  { date:   String
  , season: String
  , week:   String
  , title:  String
  , ot:     List String
  , ps:     List String
  , nt:     List String
  , gs:     List String
  , ot_text: String
  , nt_text: String
  , ps_text: String
  , gs_text: String
  }


initReadings: Readings
initReadings =
  { date    = ""
  , season  = ""
  , week    = ""
  , title   = ""
  , ot      = []
  , ps      = []
  , nt      = []
  , gs      = []
  , ot_text = ""
  , nt_text = ""
  , ps_text = ""
  , gs_text = ""
  }

type alias Model =
  { sunday: Readings
  , nextFeastDay: Readings
  , today: String
  }

initModel: Model
initModel =
  { sunday = initReadings
  , nextFeastDay = initReadings
  , today = ""
  }

init: (Model, Effects Action)
init =
  (initModel, Effects.none)


-- SIGNALS


incomingActions: Signal Action
incomingActions =
  Signal.map SetReadings nextSunday

nextSundayFrom: Signal.Mailbox String
nextSundayFrom =
  Signal.mailbox ""

lastSundayFrom: Signal.Mailbox String
lastSundayFrom =
  Signal.mailbox ""


-- PORTS

port requestNextSunday: Signal String
port requestNextSunday = 
  nextSundayFrom.signal

port requestLastSunday: Signal String
port requestLastSunday = 
  lastSundayFrom.signal

port nextSunday: Signal Model


-- UPDATE

type Action
  = NoOp
  | SetReadings Model
  | RequestEsvText (List String)
  | NewEsvText (Maybe String)

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)
    SetReadings readings -> (readings, Effects.none)
    RequestEsvText vss ->
      (model, getEsvText vss)
    NewEsvText maybeResp ->
      let
        foo = Debug.log "ESV TEXT" maybeResp
      in
        (model, Effects.none)

getEsvText: List String -> Effects Action
getEsvText vss =
  let
    url = esvUrl (List.head vss |> Maybe.withDefault "")
  in
    Http.getString url
    |> Task.toMaybe
    |> Task.map NewEsvText
    |> Effects.task

esvUrl: String -> String
esvUrl vss =
  Http.url "http://www.esvapi.org/v2/rest/passageQuery"
      [ ("key", esvKey)
      , ("passage", vss)
      , ("include-headings", "false")
      ]

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div 
    []
    [ ul 
      []
      [ li [] [text ("From: " ++ model.today)]
      , li [] [text (model.sunday.title ++ " - " ++ model.sunday.date)]
      , li [] [text ("Next Feast Day: " ++ model.nextFeastDay.title ++ " - " ++ model.nextFeastDay.date)]
      , li [] (basicNav address model)
      , li 
          []
          [ ul [] (theseReadings address model.sunday) ]
      , li 
          []
          [ ul [] (theseReadings address model.nextFeastDay) ]
      ]
    ]

basicNav: Signal.Address Action -> Model -> List Html
basicNav address model =
      [ button [buttonStyle, onClick lastSundayFrom.address model.sunday.date] [text "last Sunday"]
      , button [buttonStyle, onClick nextSundayFrom.address model.sunday.date] [text "next Sunday"]
      , button [inactiveButtonStyle] [text "Daily Office"]
      , button [inactiveButtonStyle] [text "Morning Psalms"]
      , button [inactiveButtonStyle] [text "Evening Psalms"]
      , br [] []
      ]

theseReadings: Signal.Address Action -> Readings -> List Html
theseReadings address readings =
  [ li [] [text readings.title]
  , li [onClick address (RequestEsvText readings.ot) ] [text ("OT: " ++ (readingList readings.ot))]
  , li [onClick address (RequestEsvText readings.ps) ] [text ("PS: " ++ (readingList readings.ps))]
  , li [onClick address (RequestEsvText readings.nt) ] [text ("NT: " ++ (readingList readings.nt))]
  , li [onClick address (RequestEsvText readings.gs) ] [text ("GS: " ++ (readingList readings.gs))]
  ]

readingList: List String -> String
readingList listOfStrings =
  String.join " " listOfStrings

-- STYLE

buttonStyle: Attribute
buttonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "0px 2px")
    , ("line-height", "0.8")
    , ("display", "inline-block")
    ]
inactiveButtonStyle: Attribute
inactiveButtonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "0px 2px")
    , ("line-height", "0.8")
    , ("display", "inline-block")
    , ("color", "lightgrey")
    ]
