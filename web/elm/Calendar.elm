port module Calendar exposing (..) -- where
import Debug

-- import StartApp
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json exposing ((:=))
import Platform.Sub as Sub exposing (batch)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown

import Iphod.Helper exposing (hideable)
import Iphod.Models as Models
import Iphod.Sunday as Sunday
import Iphod.MPReading as MPReading
import Iphod.EPReading as EPReading


-- MAIN

main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


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



-- SUBSCRIPTIONS

-- port suggestions : (List String -> msg) -> Sub msg
-- 
-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--   suggestions Suggest
-- 

port portCalendar: (Model -> msg) -> Sub msg
subscribeCalendar: Model -> Sub Msg
subscribeCalendar model =
  portCalendar InitCalendar

port portEU: (Models.Sunday -> msg) -> Sub msg
subscribeEU: Model -> Sub Msg
subscribeEU eu =
  portEU UpdateEU

port portMP: (Models.DailyMP -> msg) -> Sub msg
subscribeMP: Model -> Sub Msg
subscribeMP mp =
  portMP UpdateMP

port portEP: (Models.DailyEP -> msg) -> Sub msg
subscribeEP: Model -> Sub Msg
subscribeEP ep =
  portEP UpdateEP

subscriptions : Model -> Sub Msg  
subscriptions model = 
  Sub.batch
    [ subscribeEU
    , subscribeMP
    , subscribeEP
    ]

-- UPDATE

type Msg
  = NoOp
  | InitCalendar Model
  | UpdateEU Models.Sunday
  | UpdateMP Models.DailyMP
  | UpdateEP Models.DailyEP
  | ModEU Sunday.Model Sunday.Msg
  | ModMP MPReading.Model MPReading.Msg
  | ModEP EPReading.Model EPReading.Msg

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
  div [] [ App.map ModEU (Sunday.view model.eu) ]
  -- [ (Sunday.view (Signal.forwardTo (ModEU model.eu)) model.eu) ]

mpDiv: Model -> Html Msg
mpDiv model =
  div []
  [ App.map ModMP (MPReading.view model.mp)
  --(MPReading.view (Signal.forwardTo (ModMP model.mp)) model.mp)
  ]

epDiv: Model -> Html Msg
epDiv model =
  div []
  [ App.map ModEP (EPReading.view model.ep)
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



