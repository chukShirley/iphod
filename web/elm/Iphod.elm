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
import Task exposing (Task, andThen)
import String exposing (join)
import Markdown
import Graphics.Element as Graphics

import Iphod.Helper exposing (onClickLimited, hideable, getText)
import Iphod.Sunday as Sunday
import Iphod.MorningPrayer as MorningPrayer
import Iphod.EveningPrayer as EveningPrayer
import Iphod.Daily as Daily
import Iphod.Email as Email
import Iphod.Email exposing(sendContactMe)
import Iphod.Config as Config
import Iphod.Models as Models


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =  [ incomingActions
                , incomingText
                , incomingEmail
                ]
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
  , version:  String -- esv, bcp, coverdale, etc.
  }

type alias Model =
  { today:          String
  , sunday:         Models.Sunday
  , redLetter:      Models.Sunday
  , daily:          Models.Daily
  , morningPrayer:  Models.Daily
  , eveningPrayer:  Models.Daily
  , email:          Models.Email
  , config:         Models.Config
  , about:          Bool
  }

initModel: Model
initModel =
  { today =         ""
  , sunday =        Models.sundayInit
  , redLetter =     Models.sundayInit
  , daily =         Models.dailyInit
  , morningPrayer = Models.dailyInit
  , eveningPrayer = Models.dailyInit
  , email =         Models.emailInit
  , config =        Models.configInit
  , about =         False
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

incomingEmail: Signal Action
incomingEmail =
  Signal.map UpdateEmail newEmail

moveDate: Signal.Mailbox String
moveDate =
  Signal.mailbox ""

moveDay: Signal.Mailbox (String, String)
moveDay =
  Signal.mailbox ("", "")

namedDay: Signal.Mailbox (String, String)
namedDay =
  Signal.mailbox ("", "")

gatherAllText: Signal.Mailbox (String, String, Models.Config)
gatherAllText =
  Signal.mailbox ("", "", Models.configInit)

saveThisConfig: Signal.Mailbox Models.Config
saveThisConfig =
  Signal.mailbox Models.configInit



-- PORTS

port requestMoveDate: Signal String
port requestMoveDate =
  moveDate.signal

port requestMoveDay: Signal (String, String)
port requestMoveDay =
  moveDay.signal

port requestNamedDay: Signal (String, String)
port requestNamedDay =
  namedDay.signal

port requestAllText: Signal (String, String, Models.Config)
port requestAllText =
  gatherAllText.signal

port savingConfig: Signal Models.Config
port savingConfig = 
  saveThisConfig.signal

port sendEmail: Signal Models.Email
port sendEmail =
  sendContactMe.signal

port requestText: Signal (List (String, String))
port requestText =
  getText.signal

port nextSunday: Signal Model
port newText: Signal NewText
port newEmail: Signal Models.Email


-- UPDATE

type Action
  = NoOp
  | ReadMe String
  | ChangeDate String
  | ChangeDay String
  | ToggleAbout
  | ToggleEmail
  | ToggleMp
  | ToggleEp
  | ToggleDaily
  | ToggleSunday
  | ToggleRedLetter
  | SetSunday Model
  | UpdateText NewText
  | UpdateEmail Email.Model
  | ModEmail Email.Model Email.Action
  | ModMP MorningPrayer.Model MorningPrayer.Action
  | ModEP EveningPrayer.Model EveningPrayer.Action
  | ModSunday Sunday.Model Sunday.Action
  | ModDaily Daily.Model Daily.Action
  | ModConfig Config.Model Config.Action

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)

    ReadMe s ->
      let
        foo = Debug.log "README" s
      in
        (model, Effects.none)

    ChangeDate date -> (model, changeDate date)

    ChangeDay day -> (model, changeDay day model)

    ToggleAbout -> ({model | about = not model.about}, Effects.none)

    ToggleEmail -> 
      let 
        email = model.email
        newEmail = {email | show = not email.show}
        newModel = {model | email = newEmail}
      in
        (newModel, Effects.none)

    ToggleMp ->
      let
        mp = model.morningPrayer
        newmp = {mp | show = not mp.show}
        newModel = {model | morningPrayer = newmp}
        effect = if newmp.show 
                  then gatherText model "morningPrayer" 
                  else Effects.none
      in 
        (newModel, effect)

    ToggleEp ->
      let
        ep = model.eveningPrayer
        newep = {ep | show = not ep.show}
        newModel = {model | eveningPrayer = newep}
        effect = if newep.show 
                  then gatherText model "eveningPrayer" 
                  else Effects.none
      in 
        (newModel, effect)

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
          "sunday"    ->  {model | sunday = updateSundayText model.sunday text}
          "redletter" ->  {model | redLetter = updateSundayText model.redLetter text}
          "daily"     ->  {model | daily = updateDailyText model.daily text}
          "morningPrayer" -> {model | morningPrayer = updateDailyText model.morningPrayer text}
          "eveningPrayer" -> {model | eveningPrayer = updateDailyText model.eveningPrayer text}
          _           -> model
      in
        (newModel, Effects.none)

    UpdateEmail this_email -> ({model | email = this_email}, Effects.none)

    ModMP reading mpAction->
      let
        newModel = MorningPrayer.update mpAction reading
      in 
        (model, Effects.none)

    ModEP reading mpAction->
      let
        newModel = EveningPrayer.update mpAction reading
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

    ModEmail emodel eaction ->
      let
        newModel = {model | email = Email.update eaction emodel }
      in
        (newModel, Effects.none)

    ModConfig cmodel caction ->
      let
        foo = Debug.log "CONFIG" model.config
        newConfig = Config.update caction cmodel
        sunday = model.sunday 
        newSunday = {sunday | config = newConfig}
        red = model.redLetter 
        newRed = {red | config = newConfig}
        daily = model.daily
        newDaily = {daily | config = newConfig}
        newModel = {model | config = newConfig, 
                            sunday = newSunday, 
                            redLetter = newRed, 
                            daily = newDaily
                    }
      in
        (newModel, saveConfig newModel.config)

-- HELPERS|> Task.toMaybe

gatherText: Model -> String -> Effects Action
gatherText model prayer =
  Signal.send gatherAllText.address (prayer, model.today, model.config)
  |> Task.toMaybe
  |> Task.map (always NoOp)
  |> Effects.task

changeDate: String -> Effects Action
changeDate date =
  Signal.send moveDate.address date
  |> Task.toMaybe
  |> Task.map (always NoOp)
  |> Effects.task

changeDay: String -> Model -> Effects Action
changeDay day model =
  Signal.send moveDay.address (day, model.today)
  |> Task.toMaybe
  |> Task.map (always NoOp)
  |> Effects.task

saveConfig: Models.Config -> Effects Action
saveConfig config =
  Signal.send saveThisConfig.address (config)
  |> Task.toMaybe
  |> Task.map (always NoOp)
  |> Effects.task

  -- end with NoOp

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
          {this_lesson | body = text.body, show = True, version = text.version}
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
      "mpp" -> daily.mpp
      "ep1" -> daily.ep1
      "ep2" -> daily.ep2
      "epp" -> daily.epp
      _     -> daily.epp
    update_text this_lesson =
      if this_lesson.id == text.id 
        then 
          {this_lesson | body = text.body, show = True, version = text.version}
        else 
          this_lesson

    newSection = List.map update_text this_section
    newDaily = case text.section of
      "mp1" -> {daily | mp1 = newSection}
      "mp2" -> {daily | mp2 = newSection}
      "mpp" -> {daily | mpp = newSection}
      "ep1" -> {daily | ep1 = newSection}
      "ep2" -> {daily | ep2 = newSection}
      "epp" -> {daily | epp = newSection}
      _     -> {daily | epp = newSection}
  in 
    newDaily

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div 
    []
    [ fancyNav address model
    , emailMe address model
    , aboutDiv address model
    , br [] []
    , listDates address model
    , dateNav address model
    , readingNav address model
    , config address model
    , listReadings address model
    , morningPrayerDiv address model
    , eveningPrayerDiv address model
    ]

emailMe: Signal.Address Action -> Model -> Html
emailMe address model =
  div []
    [(Email.view (Signal.forwardTo address (ModEmail model.email)) model.email)]
-- Sunday.view (Signal.forwardTo address (ModSunday model.sunday)) model.sunday

aboutDiv: Signal.Address Action -> Model -> Html
aboutDiv address model =
  div [class "about"]
    [ p [ class "about"
          , aboutStyle model
          , onClick address ToggleAbout
        ] 
        [Markdown.toHtml about]
    ]

listDates: Signal.Address Action -> Model -> Html
listDates address model =
  div [class "list_dates"]
    [ ul [class "list_dates"]
      [ li [] [text ("Next Sunday from " ++ model.today ++ " is " ++ model.sunday.title)]
      , li [] [text ("Next Feast Day: " ++ model.redLetter.title ++ " - " ++ model.redLetter.date)]
      ]
    ]


fancyNav: Signal.Address Action -> Model -> Html
fancyNav address model =
  let 
    mp = "/morningPrayer/" ++ model.config.ps
    ep = "/eveningPrayer/" ++ model.config.ps
    foo = Debug.log "MorningPrayer" mp
  in
    div [id "menu1", class "cssmenu"] [
      ul []
        [ li [onClick address ToggleMp] [ a [href mp] [ text "Morning Prayer"] ]
        , li [onClick address ToggleEp] [ a [href mp] [ text "Evening Prayer"] ]
        , li [class "has-sub"] 
            [ a [href "#"] [ text "Easter"]
            , ul [] 
                [ li [onClick namedDay.address ("palmSundayPalms", "1")] [ a [href "#"] [ text "Liturgy of the Palms"] ]
                , li [onClick namedDay.address ("palmSunday", "1")] [ a [href "#"] [ text "Palm Sunday"] ]
                , li [class "has-sub"]
                    [ a [href "#"] [ text "Holy Week"]
                    , ul [] 
                        [ li [onClick namedDay.address ("holyWeek", "1")] [ a [href "#"] [ text "Monday of Holy Week"] ]
                        , li [onClick namedDay.address ("holyWeek", "2")] [ a [href "#"] [ text "Tuesday of Holy Week"] ]
                        , li [onClick namedDay.address ("holyWeek", "3")] [ a [href "#"] [ text "Wednesday of Holy Week"] ]
                        , li [onClick namedDay.address ("holyWeek", "4")] [ a [href "#"] [ text "Maunday Thursday"] ]
                        , li [onClick namedDay.address ("holyWeek", "5")] [ a [href "#"] [ text "Good Friday"] ]
                        , li [onClick namedDay.address ("holyWeek", "6")] [ a [href "#"] [ text "Holy Saturday"] ]
                        ]
                    ]
                , li [onClick namedDay.address ("easterDayVigil", "1")] [ a [href "#"] [ text "Great Vigil of Easter"] ]
                , li [onClick namedDay.address ("easterDay", "1")] [ a [href "#"] [ text "Easter Day: Early"] ]
                , li [onClick namedDay.address ("easterDay", "2")] [ a [href "#"] [ text "Easter Day Principle"] ]
                , li [onClick namedDay.address ("easterDay", "3")] [ a [href "#"] [ text "Easter Day Evening"] ]
                , li [class "has-sub"] 
                    [ a [href "#"] [ text "Week Following"]
                    , ul [] 
                      [ li [onClick namedDay.address ("easterWeek", "1")] [ a [href "#"] [ text "Easter Monday"] ]
                      , li [onClick namedDay.address ("easterWeek", "2")] [ a [href "#"] [ text "Easter Tuesday"] ]
                      , li [onClick namedDay.address ("easterWeek", "3")] [ a [href "#"] [ text "Easter Wednesday"] ]
                      , li [onClick namedDay.address ("easterWeek", "4")] [ a [href "#"] [ text "Easter Thursday"] ]
                      , li [onClick namedDay.address ("easterWeek", "5")] [ a [href "#"] [ text "Easter Friday"] ]
                      , li [onClick namedDay.address ("easterWeek", "6")] [ a [href "#"] [ text "Easter Saturday"] ]
                      ]
                    ]
                ]
            ]
        , li [class "has-sub"]
            [ a [href "#"] [text "More..."]
            , ul []
                [ li [] [ a [href "printables"] [text "Printables"] ]
                , li [] [ a [href "versions"] [text "Bible Versions"] ]
                , li [] [ a [href "calendar"] [text "Calendar View"] ]
                , li [onClick address ToggleAbout] [ a [href "#"] [ text "About"] ]
                , li [onClick address ToggleEmail] [ a [href "#"] [ text "Contact"] ]
                ]
            ]
      ]
    ]

dateNav: Signal.Address Action -> Model -> Html
dateNav address model =
  div [id "date_nav"]
    [ div [ id "datepicker_div", datepickerStyle model ] 
          [ input 
              [ type' "text"
              , class "current_date"
              , id "datepicker"
              , value model.today
              , style [("z-index", "200")]
              , on "change" targetValue (\str -> Signal.message address (ChangeDate str))
              ] []
          ]
    , div [id "menu2", class "cssmenu", style [("z-index", "99")] ] 
        [ ul []
          [ li [style [("width", "25%")], onClick address (ChangeDay "lastSunday")] [ a [href "#"] [ text "Last Sunday"] ]
          , li [style [("width", "25%")], onClick address (ChangeDay "yesterday")] [ a [href "#"] [ text "Yesterday"] ]
          , li [style [("width", "25%")], onClick address (ChangeDay "tomorrow")] [ a [href "#"] [ text "Tomorrow"] ]
          , li [style [("width", "25%")], onClick address (ChangeDay "nextSunday")] [ a [href "#"] [ text "Next Sunday"] ]
          ]
      ]
    ]

    
readingNav: Signal.Address Action -> Model -> Html
readingNav address model =
  div [id "menu3", class "cssmenu", style [("z-index", "99")] ] 
  [ ul []
      [ li [style [("width", "33%")], onClick address ToggleDaily] [ a [href "#"] [ text "Daily"] ]
      , li [style [("width", "33%")], onClick address ToggleSunday ] [ a [href "#"] [ text "Sunday"] ]
      , li [style [("width", "33%")], onClick address ToggleRedLetter] [ a [href "#"] [ text "Red Letter"] ]
      ]
  ]

config: Signal.Address Action -> Model -> Html
config address model = 
  div [class "cssmenu", style [("z-index", "99")]]
    [(Config.view (Signal.forwardTo address (ModConfig model.config)) model.config)]

    
listReadings: Signal.Address Action -> Model -> Html
listReadings address model =
  div [class "list_readings", style [("margin-top", "0em"), ("z-index", "99")]]
    [ (Daily.view (Signal.forwardTo address (ModDaily model.daily)) model.daily)
    , (Sunday.view (Signal.forwardTo address (ModSunday model.sunday)) model.sunday)
    , (Sunday.view (Signal.forwardTo address (ModSunday model.redLetter)) model.redLetter)
    ]

morningPrayerDiv: Signal.Address Action -> Model -> Html
morningPrayerDiv address model =
  div []
    [ (MorningPrayer.view (Signal.forwardTo address (ModMP model.morningPrayer)) model.morningPrayer)
    ]

eveningPrayerDiv: Signal.Address Action -> Model -> Html
eveningPrayerDiv address model =
  div []
    [ (EveningPrayer.view (Signal.forwardTo address (ModEP model.eveningPrayer)) model.eveningPrayer)
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
* Facebook group at https://www.facebook.com/groups/471879323003692/
  * report errors
  * make suggestions
  * ask questions
* shows assigned readings and ESV text for the ACNA Red Letter, Sunday Lectionary, and Daily Prayer. Current fails include...
  * partial verses mean nothing to the ESV API, so in this app only complete verses are shown
* Path forward
  * Daily Office
  * Daily Office with redings inserted
  * Canticals
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

datepickerStyle: Model -> Attribute
datepickerStyle model =
  style
    [ ("background-color", "gold")
    , ("background", "-moz-linear-gradient(top, #ffec80 0%, #e6c300 100%)")
    , ("background", "-webkit-gradient(linear, left top, left bottom, color-stop(0%, #ffec80), color-stop(100%, #e6c300))")
    , ("background", "-webkit-linear-gradient(top, #ffec80 0%, #e6c300 100%)")
    , ("background", "-o-linear-gradient(top, #ffec80 0%, #e6c300 100%)")
    , ("background", "-ms-linear-gradient(top, #ffec80 0%, #e6c300 100%)")
    , ("background", "linear-gradient(to bottom, #ffec80 0%, #e6c300 100%)")
    ]

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
