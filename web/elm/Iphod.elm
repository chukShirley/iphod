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

yesterdayFrom: Signal.Mailbox String
yesterdayFrom =
  Signal.mailbox ""

tomorrowFrom: Signal.Mailbox String
tomorrowFrom =
  Signal.mailbox ""

-- PORTS

port requestNextSunday: Signal String
port requestNextSunday = 
  nextSundayFrom.signal

port requestLastSunday: Signal String
port requestLastSunday = 
  lastSundayFrom.signal

port requestYesterday: Signal String
port requestYesterday = 
  yesterdayFrom.signal

port requestTomorrow: Signal String
port requestTomorrow = 
  tomorrowFrom.signal

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
  | ToggleDaily
  | ToggleSunday
  | ToggleRedLetter
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
        mp = model.morningPrayer
        newmp = {mp | show = not mp.show}
        newModel = {model | morningPrayer = newmp}
      in 
        (newModel, Effects.none)
    ToggleDaily ->
      let
        daily = model.daily
        newdaily = {daily | show = not daily.show}
        newModel = {model | daily = newdaily}
      in 
        (newModel, Effects.none)
    ToggleSunday ->
      let
        sunday = model.sunday
        newSunday = {sunday | show = not sunday.show}
        newModel = {model | sunday = newSunday}
      in 
        (newModel, Effects.none)
    ToggleRedLetter ->
      let
        rl = model.redLetter
        newRL = {rl | show = not rl.show}
        newModel = {model | redLetter = newRL}
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
        foo = Debug.log "READING" reading
        bar = Debug.log "MPACTION" mpAction
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
    [ fancyNav address model
    , aboutDiv address model
    , br [] []
    , listDates address model
    , dateNav address model
    , readingNav address model
    , listReadings address model
    , morningPrayerDiv address model
    ]

aboutDiv: Signal.Address Action -> Model -> Html
aboutDiv address model =
  div []
    [ p [ class "about"
          , aboutStyle model
          , onClick address ToggleAbout
        ] 
        [Markdown.toHtml about]
    ]

listDates: Signal.Address Action -> Model -> Html
listDates address model =
  div []
    [ ul []
      [ li [] [text ("From: " ++ model.today)]
      , li [] [text (model.sunday.title ++ " - " ++ model.sunday.date)]
      , li [] [text ("Next Feast Day: " ++ model.redLetter.title ++ " - " ++ model.redLetter.date)]
      ]
    ]


fancyNav: Signal.Address Action -> Model -> Html
fancyNav address model =
  div [class "cssmenu"] [
    ul []
      [ li [onClick address ToggleMp] [ a [href "#"] [ text "Morning Prayer"] ]
      , li [] [ a [href "#"] [ text "Evening Prayer"] ]
      , li [class "has-sub"] 
          [ a [href "#"] [ text "Easter"]
          , ul [] 
              [ li [] [ a [href "#"] [ text "Liturgy of the Palms"] ]
              , li [] [ a [href "#"] [ text "Palm Sunday"] ]
              , li [class "has-sub"]
                  [ a [href "#"] [ text "Holy Week"]
                  , ul [] 
                      [ li [] [ a [href "#"] [ text "Monday of Holy Week"] ]
                      , li [] [ a [href "#"] [ text "Tuesday of Holy Week"] ]
                      , li [] [ a [href "#"] [ text "Wednesday of Holy Week"] ]
                      , li [] [ a [href "#"] [ text "Maunday Thursday"] ]
                      , li [] [ a [href "#"] [ text "Good Friday"] ]
                      , li [] [ a [href "#"] [ text "Holy Saturday"] ]
                      ]
                  ]
              , li [] [ a [href "#"] [ text "Great Vigil of Easter"] ]
              , li [] [ a [href "#"] [ text "Easter Day: Early"] ]
              , li [] [ a [href "#"] [ text "Easter Day: Early"] ]
              , li [] [ a [href "#"] [ text "Easter Day Principle"] ]
              , li [] [ a [href "#"] [ text "Easter Day Evening"] ]
              , li [class "has-sub"] 
                  [ a [href "#"] [ text "Week Following"]
                  , ul [] 
                    [ li [] [ a [href "#"] [ text "Easter Monday"] ]
                    , li [] [ a [href "#"] [ text "Easter Tuesday"] ]
                    , li [] [ a [href "#"] [ text "Easter Wednesday"] ]
                    , li [] [ a [href "#"] [ text "Easter Thursday"] ]
                    , li [] [ a [href "#"] [ text "Easter Friday"] ]
                    , li [] [ a [href "#"] [ text "Easter Saturday"] ]
                    ]
                  ]
              ]
          ]
      , li [onClick address ToggleAbout] [ a [href "#"] [ text "About"] ]
      , li [] [ a [href "#"] [ text "Contact"] ]
    ]
  ]

dateNav: Signal.Address Action -> Model -> Html
dateNav address model =
  div [class "cssmenu"] 
  [ ul []
      [ li [onClick lastSundayFrom.address model.sunday.date] [ a [href "#"] [ text "Last Sunday"] ]
      , li [onClick yesterdayFrom.address model.today] [ a [href "#"] [ text "Yesterday"] ]
      , li [style [("width", "22%"), ("text-align", "center")]] [ a [href "#"] [ text model.today] ]
      , li [onClick tomorrowFrom.address model.today] [ a [href "#"] [ text "Tomorrow"] ]
      , li [onClick nextSundayFrom.address model.sunday.date] [ a [href "#"] [ text "Next Sunday"] ]
      ]
  ]

    
readingNav: Signal.Address Action -> Model -> Html
readingNav address model =
  div [class "cssmenu"] 
  [ ul []
      [ li [onClick address ToggleDaily] [ a [href "#"] [ text "Daily"] ]
      , li [onClick address ToggleSunday ] [ a [href "#"] [ text "Sunday"] ]
      , li [onClick address ToggleRedLetter] [ a [href "#"] [ text "Red Letter"] ]
      ]
  ]

    
listReadings: Signal.Address Action -> Model -> Html
listReadings address model =
  div [style [("margin-top", "0em")]]
    [ ul [] (Sunday.view (Signal.forwardTo address (ModSunday model.sunday)) model.sunday)
    , ul [] (Sunday.view (Signal.forwardTo address (ModSunday model.redLetter)) model.redLetter)
    , ul [] (Daily.view (Signal.forwardTo address (ModDaily model.daily)) model.daily) 
    ]

morningPrayerDiv: Signal.Address Action -> Model -> Html
morningPrayerDiv address model =
  div []
    [ (MorningPrayer.view (Signal.forwardTo address (ModMP model.morningPrayer)) model.morningPrayer)
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
