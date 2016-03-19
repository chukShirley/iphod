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
import Helper exposing (onClickLimited, hideable)

import Iphod.Sunday exposing (getText)
import Iphod.Sunday as Sunday
import Iphod.MorningPrayer as MorningPrayer
import Iphod.Daily as Daily


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingActions, incomingSundayText]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias NewSundayText = 
  { model:    String -- sunday, daily, redletter
  , section:  String -- ot, ps, nt, gs
  , id:       String -- id-ified reading, e.g. "Lk_22_39-71"
  , body:     String
  }

type alias Model =
  { today:        String
  , sunday:       Sunday.Model
  , redLetter:    Sunday.Model
  , daily:        MorningPrayer.Model
--  , ep: EveningPrayer.Model
--  , daily: Daily.Model  
  }

initModel: Model
initModel =
  { today =         ""
  , sunday =        Sunday.init
  , redLetter =     Sunday.init
  , daily =         MorningPrayer.init
--  , ep = EveningPrayer.init
--  , daily= Daily.init
  }

init: (Model, Effects Action)
init =
  (initModel, Effects.none)


-- SIGNALS


incomingActions: Signal Action
incomingActions =
  Signal.map SetSunday nextSunday

incomingSundayText: Signal Action
incomingSundayText =
  Signal.map UpdateSunday newSundayText

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

port requestText: Signal (String, String, String, String)
port requestText =
  getText.signal

port nextSunday: Signal Model
port newSundayText: Signal NewSundayText

-- UPDATE

type Action
  = NoOp
  | SetSunday Model
  | UpdateSunday NewSundayText
  | RequestEsvText (List String)
  | Modify Sunday.Model Sunday.Action
  | ModMP MorningPrayer.Model MorningPrayer.Action

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)
    SetSunday readings -> (readings, Effects.none)
    UpdateSunday text ->
      let 
        this_model = if text.model == "redletter" then model.redLetter
                    else model.sunday -- default to sunday. Why? beats me.
        this_section = if text.section == "ot" then this_model.ot
                  else if text.section == "ps" then this_model.ps
                  else if text.section == "nt" then this_model.nt
                  else this_model.gs -- default to gs. Why? beats me.
        update_text this_lesson =
          if this_lesson.id == text.id 
            then 
              {this_lesson | body = text.body, show = True}
            else 
              this_lesson
        newSection = List.map update_text this_section
        newDayModel = case text.section of
          "ot" -> {this_model | ot = newSection}
          "ps" -> {this_model | ps = newSection}
          "nt" -> {this_model | nt = newSection}
          _    -> {this_model | gs = newSection}

        newModel = case text.model of
          "redletter" -> {model | redLetter = newDayModel}
          _           -> {model | sunday = newDayModel}
      in
        (newModel, Effects.none)
    RequestEsvText vss ->
      (model, Effects.none)
    Modify reading readingAction->
      let
        newModel = {model | sunday = Sunday.update readingAction reading}
      in 
        (newModel, Effects.none)
    ModMP reading mpAction->
      let
        foo = Debug.log "DAILY MODIFY READING" reading
        bar = Debug.log "DAILY READING ACTION" mpAction
        newModel = MorningPrayer.update mpAction reading
      in 
        (model, Effects.none)


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div 
    []
    [ ul 
      []
      [ li [] [text ("From: " ++ model.today)]
      , li [] [text (model.sunday.title ++ " - " ++ model.sunday.date)]
      , li [] [text ("Next Feast Day: " ++ model.redLetter.title ++ " - " ++ model.redLetter.date)]
      , li [] (basicNav address model)
      , li 
          []
-- [ ul [] (theseSunday address model.sunday) ]
          [ ul [] (Sunday.view (Signal.forwardTo address (Modify model.sunday)) model.sunday) ]
      , li 
          []
          [ ul [] (Sunday.view (Signal.forwardTo address (Modify model.redLetter)) model.redLetter) ]
      , li
        []
        [ (MorningPrayer.view (Signal.forwardTo address (ModMP model.daily)) model.daily) ]
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

-- STYLE

buttonStyle: Attribute
buttonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]
inactiveButtonStyle: Attribute
inactiveButtonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    , ("color", "lightgrey")
    ]
