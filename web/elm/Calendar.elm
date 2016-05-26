module Calendar exposing (..) -- where
import Debug

-- import StartApp
import Html exposing (..)
import Html.App as Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json exposing ((:=))
-- import Effects exposing (Effects, Never)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown

import Iphod.Helper exposing (hideable)
-- import Iphod.Email as Email
-- import Iphod.Email exposing(sendContactMe)
-- import Iphod.Config as Config
import Iphod.Models as Models
import Iphod.Sunday as Sunday
import Iphod.MPReading as MPReading
import Iphod.EPReading as EPReading

app =
  Html.program
    { init = init
    , update = update
    , view = view
    , inputs =  [ incomingActions, incomingEU, incomingMP, incomingEP ]
    }

-- MAIN

main: Html
main = app.html

-- MODEL

type alias Model =
  { eu: Models.Sunday
  , mp: Models.DailyMP
  , ep: Models.DailyEP
  }

initModel: Model
initModel =
  { eu = Models.sundayInit
  , mp = Models.initDailyMP
  , ep = Models.initDailyEP
  }

init:   (Model, Cmd Msg)
init =  (initModel, Cmd.none)


-- SIGNALS

-- incomingActions: Signal Msg
-- incomingActions =
--   Signal.map InitCalendar newCalendar
-- 
-- incomingEU: Signal Msg
-- incomingEU =
--   Signal.map UpdateEU newEU
-- 
-- incomingMP: Signal Msg
-- incomingMP =
--   Signal.map UpdateMP newMP
-- 
-- incomingEP: Signal Msg
-- incomingEP =
--   Signal.map UpdateEP newEP

-- PORTS

-- port newCalendar: Signal Model
port newCalendar: (Model -> msg) -> InitCalendar msg

-- port newEU: Signal Models.Sunday
port newEU: (Models.Sunday -> msg) -> UpdateEU msg

-- port newMP: Signal Models.DailyMP
port newMP: (Models.DailyMP -> msg) -> UpdateMP msg

-- port newEP: Signal Models.DailyEP
port newEP: (Models.DailyEP -> msg) -> UpdateEP msg

-- UPDATE

type Msg
  = NoOp
  | InitCalendar Model
  | UpdateEU Models.Sunday
  | UpdateMP Models.DailyMP
  | UpdateEP Models.DailyEP
  | ModEU Sunday.Model Sunday.Action
  | ModMP MPReading.Model MPReading.Action
  | ModEP EPReading.Model EPReading.Action

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    InitCalendar newCalendar -> (newCalendar, Cmd.none)

    UpdateEU eu -> 
      let
        newModel = {model | eu = eu}
      in
        (newModel, Cmd.none)

    UpdateMP mp -> 
      let
        newModel = {model | mp = mp}
      in
        (newModel, Cmd.none)

    UpdateEP ep -> 
      let
        newModel = {model | ep = ep}
      in
        (newModel, Cmd.none)

    ModEU reading readingAction ->
      let
        foo = Debug.log "MODEU" (readingAction, reading)
        newModel = {model | eu = Sunday.update readingAction reading}
      in 
        (newModel, Cmd.none)

    ModMP reading readingAction ->
      let
        newModel = {model | mp = MPReading.update readingAction reading}
      in 
        (newModel, Cmd.none)

    ModEP reading readingAction ->
      let
        newModel = {model | ep = EPReading.update readingAction reading}
      in 
        (newModel, Cmd.none)


-- HELPERS


-- VIEW

view: Model -> Html Msg
view model =
  div [] 
  [ euDiv model
  , mpDiv model
  , epDiv model
  ]


-- HELPERS

euDiv: Model -> Html Msg
euDiv model =
  div [] [ map ModEu (Sunday.view model.eu) ]
  -- [ (Sunday.view (Signal.forwardTo (ModEU model.eu)) model.eu) ]

mpDiv: Model -> Html Msg
mpDiv model =
  div []
  [ map ModMp (MPReading.view model.mp)
  --(MPReading.view (Signal.forwardTo (ModMP model.mp)) model.mp)
  ]

epDiv: Model -> Html Msg
epDiv model =
  div []
  [ map ModEP (EPReading.view model.ep)
  -- (EPReading.view (Signal.forwardTo (ModEP model.ep)) model.ep)
  ]


euReadingStyle: Model -> Attribute msg
euReadingStyle model =
  hideable
    model.eu.show
    []

mpReadingStyle: Model -> Attribute msg
mpReadingStyle model =
  hideable
    model.mp.show
    []

epReadingStyle: Model -> Attribute msg
epReadingStyle model =
  hideable
    model.ep.show
    []



