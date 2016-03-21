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
import Helper exposing (onClickLimited, hideable, getText)
import Markdown
import Graphics.Element as Graphics

import Iphod.Sunday as Sunday
import Iphod.MorningPrayer as MorningPrayer
import Iphod.Daily as Daily


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingActions, incomingText]
    }

-- MAIN

main: Signal Html
main = 
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks


-- MODEL

type alias NewText = 
  { model:    String -- sunday, daily, redletter
  , section:  String -- ot, ps, nt, gs
  , id:       String -- id-ified reading, e.g. "Lk_22_39-71"
  , body:     String
  }

type alias Model =
  { today:          String
  , sunday:         Sunday.Model
  , redLetter:      Sunday.Model
  , daily:          Daily.Model  
  , morningPrayer:  MorningPrayer.Model
--  , ep: EveningPrayer.Model
  , about:          Bool
  }

initModel: Model
initModel =
  { today =         ""
  , sunday =        Sunday.init
  , redLetter =     Sunday.init
  , daily =         Daily.init
  , morningPrayer = MorningPrayer.init
  , about =         False
--  , ep = EveningPrayer.init
  }

init: (Model, Effects Action)
init =
  (initModel, Effects.none)


-- SIGNALS


incomingActions: Signal Action
incomingActions =
  Signal.map SetSunday nextSunday

incomingText: Signal Action
incomingText =
  Signal.map UpdateText newText

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
port newText: Signal NewText

-- UPDATE

type Action
  = NoOp
  | ToggleAbout
  | ToggleMp
  | SetSunday Model
  | UpdateText NewText
  | ModMP MorningPrayer.Model MorningPrayer.Action
  | ModSunday Sunday.Model Sunday.Action
  | ModDaily Daily.Model Daily.Action

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)
    ToggleAbout -> ({model | about = not model.about}, Effects.none)
    ToggleMp ->
      let
        mp = model.daily
        newmp = {mp | show = not mp.show}
        newModel = {model | daily = newmp}
      in 
        (newModel, Effects.none)
    SetSunday readings -> (readings, Effects.none)
    UpdateText text ->
      let 
        newModel = case text.model of
          "sunday"    -> {model | sunday = updateSundayText model.sunday text}
          "redletter" -> {model | redLetter = updateSundayText model.redLetter text}
          "daily"     -> {model | daily = updateDailyText model.daily text}
          _           -> model
      in
        (newModel, Effects.none)

    ModMP reading mpAction->
      let
        newModel = MorningPrayer.update mpAction reading
      in 
        (model, Effects.none)

    ModSunday reading readingAction ->
      let
        newModel = case reading.ofType of
          "sunday"    -> {model | sunday = Sunday.update readingAction reading}
          "redletter" -> {model | redLetter = Sunday.update readingAction reading}
          _           -> model
      in 
        (newModel, Effects.none)

    ModDaily reading readingAction ->
      let
        newModel = {model | daily = Daily.update readingAction reading}
      in
        (newModel, Effects.none)


-- HELPERS

updateSundayText: Sunday.Model -> NewText -> Sunday.Model
updateSundayText sunday text =
  let 
    this_section = case text.section of
      "ot" -> sunday.ot
      "ps" -> sunday.ps
      "nt" -> sunday.nt
      _    -> sunday.gs
    update_text this_lesson =
      if this_lesson.id == text.id 
        then 
          {this_lesson | body = text.body, show = True}
        else 
          this_lesson
    newSection = List.map update_text this_section
    newSunday = case text.section of
      "ot" -> {sunday | ot = newSection}
      "ps" -> {sunday | ps = newSection}
      "nt" -> {sunday | nt = newSection}
      _    -> {sunday | gs = newSection}
  in
    newSunday


updateDailyText: Daily.Model -> NewText -> Daily.Model
updateDailyText daily text =
  let 
    this_section = case text.section of
      "mp1" -> daily.mp1
      "mp2" -> daily.mp2
      "ep1" -> daily.ep1
      _     -> daily.ep2
    update_text this_lesson =
      if this_lesson.id == text.id 
        then 
          {this_lesson | body = text.body, show = True}
        else 
          this_lesson
    newSection = List.map update_text this_section
    newDaily = case text.section of
      "mp1" -> {daily | mp1 = newSection}
      "mp2" -> {daily | mp2 = newSection}
      "ep1" -> {daily | ep1 = newSection}
      _     -> {daily | ep2 = newSection}
  in 
    newDaily

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div 
    []
    [ p [ class "about"
          , aboutStyle model
          , onClick address ToggleAbout
        ] 
        [Markdown.toHtml about]
    , br [] []
    , ul 
      []
      [ li [] [text ("From: " ++ model.today)]
      , li [] [text (model.sunday.title ++ " - " ++ model.sunday.date)]
      , li [] [text ("Next Feast Day: " ++ model.redLetter.title ++ " - " ++ model.redLetter.date)]
      , li [] (basicNav address model)
      , li 
          []
          [ ul [] (Sunday.view (Signal.forwardTo address (ModSunday model.sunday)) model.sunday) ]
      , li 
          []
          [ ul [] (Sunday.view (Signal.forwardTo address (ModSunday model.redLetter)) model.redLetter) ]
      , li 
          []
          [ ul [] (Daily.view (Signal.forwardTo address (ModDaily model.daily)) model.daily) ]
      , li
        []
        [ (MorningPrayer.view (Signal.forwardTo address (ModMP model.morningPrayer)) model.morningPrayer) ]
      ]
    ]

basicNav: Signal.Address Action -> Model -> List Html
basicNav address model =
      [ button [buttonStyle, onClick lastSundayFrom.address model.sunday.date] [text "last Sunday"]
      , button [buttonStyle, onClick nextSundayFrom.address model.sunday.date] [text "next Sunday"]
      , button [aboutButtonStyle, onClick address ToggleAbout] [text "About"]
      , br [] []
      , button [inactiveButtonStyle] [text "Readings Yesterday"]
      , button [inactiveButtonStyle] [text "Readings Today"]
      , button [inactiveButtonStyle] [text "Readings Tomorrow"]
      , button [buttonStyle, onClick address ToggleMp] [text "Daily Office"]
      , button [inactiveButtonStyle] [text "Morning Psalms"]
      , button [inactiveButtonStyle] [text "Evening Psalms"]
      , br [] []
      ]

about =  """

#### How to use

* click on stuff
  * click on the reading "title" and the text appears below
  * click on the title again and the text is hidden
* colors
  * Black is a required reading
  * Grey is optional
  * Dark Blue is alternative

#### About Iphod

* It is a work in progress
* Inerrancy is not gauranteed, so don't expect it
* shows the readings for the ACNA Red Letter andSunday Lectionary. Current fails include...
  * Days with more than one service (Like Easter)
  * Complicated times (like Holy Week and Week following)
  * Psalms are shown as ESV rather than Coverdale
  * partial verses mean nothing to the ESV API, so in this app only complete verses are shown
* Path forward
  * Daily readings
  * Daily Office
  * Daily Office with redings inserted
  * Canticals
  * Coverdale
  * Printable readings
    * so you don't have to cut and paste

#### Contact
* questions or comments email frpaulas at gmail dot com
* at this point in time I am looking for
  * error reports
  * useability suggestions
  * suggestions for features

#### Want to help?
* this is an open source project
* you can fork the project at https://github.com/frpaulas/iphod

"""

-- STYLE

aboutStyle: Model -> Attribute
aboutStyle model =
  hideable
    model.about
    [ ("font-size", "0.7em")]

buttonStyle: Attribute
buttonStyle =
  style
    [ ("position", "relative")
    , ("float", "left")
    , ("padding", "2px 2px")
    , ("font-size", "0.8em")
    , ("display", "inline-block")
    ]

aboutButtonStyle: Attribute
aboutButtonStyle =
  style
    [ ("position", "relative")
    , ("float", "right")
--    , ("float", "left")
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
