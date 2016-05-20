module Calendar where

import Debug

import StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json exposing ((:=))
import Effects exposing (Effects, Never)
import Task exposing (Task, andThen)
import String exposing (join)
import Markdown
import Graphics.Element as Graphics

import Iphod.Helper exposing (onClickLimited, hideable, getText)
import Iphod.Email as Email
import Iphod.Email exposing(sendContactMe)
import Iphod.Config as Config
import Iphod.Models as Models
import Iphod.Sunday as Sunday
import Iphod.MPReading as MPReading
import Iphod.EPReading as EPReading

app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =  [ incomingActions, incomingEU, incomingMP, incomingEP ]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


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

init:   (Model, Effects Action)
init =  (initModel, Effects.none)


-- SIGNALS

incomingActions: Signal Action
incomingActions =
  Signal.map InitCalendar newCalendar

incomingEU: Signal Action
incomingEU =
  Signal.map UpdateEU newEU

incomingMP: Signal Action
incomingMP =
  Signal.map UpdateMP newMP

incomingEP: Signal Action
incomingEP =
  Signal.map UpdateEP newEP

-- PORTS

port newCalendar: Signal Model
port newEU: Signal Models.Sunday
port newMP: Signal Models.DailyMP
port newEP: Signal Models.DailyEP

-- UPDATE

type Action
  = NoOp
  | InitCalendar Model
  | UpdateEU Models.Sunday
  | UpdateMP Models.DailyMP
  | UpdateEP Models.DailyEP
  | ModEU Sunday.Model Sunday.Action
  | ModMP MPReading.Model MPReading.Action
  | ModEP EPReading.Model EPReading.Action

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)

    InitCalendar newCalendar -> (newCalendar, Effects.none)

    UpdateEU eu -> 
      let
        newModel = {model | eu = eu}
      in
        (newModel, Effects.none)

    UpdateMP mp -> 
      let
        newModel = {model | mp = mp}
      in
        (newModel, Effects.none)

    UpdateEP ep -> 
      let
        newModel = {model | ep = ep}
      in
        (newModel, Effects.none)

    ModEU reading readingAction ->
      let
        foo = Debug.log "MODEU" (readingAction, reading)
        newModel = {model | eu = Sunday.update readingAction reading}
      in 
        (newModel, Effects.none)

    ModMP reading readingAction ->
      let
        newModel = {model | mp = MPReading.update readingAction reading}
      in 
        (newModel, Effects.none)

    ModEP reading readingAction ->
      let
        newModel = {model | ep = EPReading.update readingAction reading}
      in 
        (newModel, Effects.none)


-- HELPERS


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div [] 
  [ euDiv address model
  , mpDiv address model
  , epDiv address model
  ]


-- HELPERS

euDiv: Signal.Address Action -> Model -> Html
euDiv address model =
  div [] [ (Sunday.view (Signal.forwardTo address (ModEU model.eu)) model.eu) ]

mpDiv: Signal.Address Action -> Model -> Html
mpDiv address model =
  div []
  [ (MPReading.view (Signal.forwardTo address (ModMP model.mp)) model.mp)
  ]

epDiv: Signal.Address Action -> Model -> Html
epDiv address model =
  div []
  [ (EPReading.view (Signal.forwardTo address (ModEP model.ep)) model.ep)
  ]


-- readingsMP: Models.Daily -> List Html
-- readingsMP daily =
--   let
--     (thisId, thisRef, thisClose) = httpReferences "mp" daily.date
--   in
--     [ a [ href thisRef ] 
--         [ button [] [text "MP"] ]
--     , div 
--         [ id thisId, class "modalDialog" ]
--         [ div []
--             [ a [href thisClose, title "Close", class "close"] [text "X"] 
--             , h2 [class "modal_header"] 
--                 [ text "Morning Prayer"
--                 , br [] []
--                 , text daily.date
--                 ]
--             , reading daily.mp1
--             , reading daily.mp2
--             , reading daily.mpp
--             ]
--         ]
--     ]
-- 
-- readingsEP: Models.Daily -> List Html
-- readingsEP daily =
--   let
--     (thisId, thisRef, thisClose) = httpReferences "ep" daily.date
--   in
--     [ a [ href thisRef ] 
--         [ button [] [text "EP"] ]
--     , div 
--         [ id thisId, class "modalDialog" ]
--         [ div []
--             [ a [href thisClose, title "Close", class "close"] [text "X"] 
--             , h2 [class "modal_header"] 
--                 [ text "Evening Prayer"
--                 , br [] []
--                 , text daily.date
--                 ]
--             , reading daily.ep1
--             , reading daily.ep2
--             , reading daily.epp
--             ]
--         ]
--     ]
-- 
-- readingsEU: Models.Sunday -> List Html
-- readingsEU sunday =
--   let
--     (thisId, thisRef, thisClose) = httpReferences "he" sunday.date
--   in
--     [ a [ href thisRef ] 
--         [ button [] [text "HE"] ]
--     , div 
--         [ id thisId, class "modalDialog" ]
--         [ div []
--             [ a [href thisClose, title "Close", class "close"] [text "X"] 
--             , h2 [class "modal_header"] 
--                 [ text "Eucharistic Readings"
--                 , br [] []
--                 , text sunday.date
--                 ]
--             , reading sunday.ot
--             , reading sunday.ps
--             , reading sunday.nt
--             , reading sunday.gs
--             ]
--         ]
--     ]
-- 
-- httpReferences: String -> String -> (String, String, String)
-- httpReferences ante date =
--   let
--     id = ante ++ Regex.replace Regex.All (Regex.regex "[^A-Za-z0-9]") (\_ -> "") date
--     ref = "#" ++ id
--     close = "#close" ++ id
--   in
--     (id, ref, close)
-- 
-- reading: List Models.Lesson -> Html
-- reading lessons =
--   let
--     this_reading l =
--       li [class "reading_item"] [ text l.read ]
--   in
--     ul [class "reading_list"] (List.map this_reading lessons)
-- 
-- 
-- -- STYLE
-- 
-- day_classes: Models.Day -> Attribute
-- day_classes day =
--   let
--     firstColor = day.colors |> List.head |> Maybe.withDefault "green"
--     color_class = "day_" ++ firstColor
--   in
--     class ("day_of_month " ++ color_class)
-- 
-- styleBorder: Bool -> Attribute
-- styleBorder today =
--   if today 
--     then style [("border", "3px solid #555")]
--     else style []

euReadingStyle: Model -> Attribute
euReadingStyle model =
  let
    foo = Debug.log "STYLE EU" model.eu
  in
    hideable
      model.eu.show
      []

mpReadingStyle: Model -> Attribute
mpReadingStyle model =
  let
    foo = Debug.log "STYLE MP" model.mp
  in
    hideable
      model.mp.show
      []

epReadingStyle: Model -> Attribute
epReadingStyle model =
  let
    foo = Debug.log "STYLE EP" model.ep
  in
    hideable
      model.ep.show
      []



