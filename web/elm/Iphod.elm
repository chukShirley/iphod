port module Iphod exposing (..) -- where
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
  , reflection: Models.Reflection
  }

initModel: Model
initModel =
  { eu = Models.sundayInit
  , mp = Models.initDailyMP
  , ep = Models.initDailyEP
  , reflection = Models.initReflection
  }

init:   (Model, Cmd Msg)
init =  (initModel, Cmd.none)

-- REQUEST PORTS

port requestReading: List String -> Cmd msg
port requestAltReading: List String -> Cmd msg
port requestScrollTop: String -> Cmd msg


-- SUBSCRIPTIONS

port portCalendar: (Model -> msg) -> Sub msg

port portEU: (Models.Sunday -> msg) -> Sub msg

port portMP: (Models.DailyMP -> msg) -> Sub msg

port portEP: (Models.DailyEP -> msg) -> Sub msg

port portLesson: (List Models.Lesson -> msg) -> Sub msg

port portReflection: (Models.Reflection -> msg) -> Sub msg


subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ portCalendar InitCalendar
  , portEU UpdateEU
  , portMP UpdateMP
  , portEP UpdateEP
  , portLesson UpdateLesson
  , portReflection UpdateReflection
  ]

-- UPDATE

type ShowHide = Show | Hide

type Msg
  = NoOp
  | InitCalendar Model
  | UpdateEU Models.Sunday
  | UpdateMP Models.DailyMP
  | UpdateEP Models.DailyEP
  | UpdateReflection Models.Reflection
  | UpdateLesson (List Models.Lesson)
  | ModEU Sunday.Msg
  | ModMP MPReading.Msg
  | ModEP EPReading.Msg

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    InitCalendar newCalendar -> (newCalendar, Cmd.none)

    UpdateEU eu -> 
      let
        newModel = 
          {model  | eu = eu
                  , mp = Models.initDailyMP
                  , ep = Models.initDailyEP
                  , reflection = Models.initReflection
          }
      in
        (newModel, requestScrollTop "0" )

    UpdateMP mp -> 
      let
        newModel = 
          {model  | eu = Models.sundayInit
                  , mp = mp
                  , ep = Models.initDailyEP
                  , reflection = Models.initReflection
          }
      in
        (newModel, Cmd.none)

    UpdateEP ep -> 
      let
        newModel = 
          {model  | eu = Models.sundayInit
                  , mp = Models.initDailyMP
                  , ep = ep
                  , reflection = Models.initReflection
          }
      in
        (newModel, Cmd.none)

    UpdateReflection reflection -> 
      let
        newModel = 
          {model  | eu = Models.sundayInit
                  , mp = Models.initDailyMP
                  , ep = Models.initDailyEP
                  , reflection = reflection
          }
      in
        (newModel, Cmd.none)

    UpdateLesson lesson -> 
      let 
        section = (List.head lesson |> Maybe.withDefault Models.initLesson).section
        newModel = setLesson model section lesson
      in
        (newModel, Cmd.none)

    ModEU msg ->
      let
        newModel = {model | eu = Sunday.update msg model.eu}
        newCmd = changeEuLesson model.eu newModel.eu
      in 
        (newModel, newCmd)

    ModMP msg ->
      let
        newModel = {model | mp = MPReading.update msg model.mp}
        newCmd = changeMpLesson model.mp newModel.mp
      in 
        (newModel, newCmd)

    ModEP msg ->
      let
        newModel = {model | ep = EPReading.update msg model.ep}
        newCmd = changeEpLesson model.ep newModel.ep
      in 
        (newModel, newCmd)


-- HELPERS

changeMpLesson: Models.DailyMP -> Models.DailyMP -> Cmd Msg
changeMpLesson daily newDaily =
  let 
    newMp1Ver = (List.head newDaily.mp1 |> Maybe.withDefault Models.initLesson).version
    newMp2Ver = (List.head newDaily.mp2 |> Maybe.withDefault Models.initLesson).version
    newMppVer = (List.head newDaily.mpp |> Maybe.withDefault Models.initLesson).version
    mp1Ver = (List.head daily.mp1 |> Maybe.withDefault Models.initLesson).version
    mp2Ver = (List.head daily.mp2 |> Maybe.withDefault Models.initLesson).version
    mppVer = (List.head daily.mpp |> Maybe.withDefault Models.initLesson).version
  in
    if mp1Ver /= newMp1Ver then
      requestReading ["mp1", newMp1Ver, daily.date]
    else if mp2Ver /= newMp2Ver then 
      requestReading ["mp2", newMp2Ver, daily.date]
    else if mppVer /= newMppVer then
      requestReading ["mpp", newMppVer, daily.date]
    else
      Cmd.none

changeEpLesson: Models.DailyEP -> Models.DailyEP -> Cmd Msg
changeEpLesson daily newDaily =
  let 
    newEp1Ver = (List.head newDaily.ep1 |> Maybe.withDefault Models.initLesson).version
    newEp2Ver = (List.head newDaily.ep2 |> Maybe.withDefault Models.initLesson).version
    newEppVer = (List.head newDaily.epp |> Maybe.withDefault Models.initLesson).version
    ep1Ver = (List.head daily.ep1 |> Maybe.withDefault Models.initLesson).version
    ep2Ver = (List.head daily.ep2 |> Maybe.withDefault Models.initLesson).version
    eppVer = (List.head daily.epp |> Maybe.withDefault Models.initLesson).version
  in
    if ep1Ver /= newEp1Ver then
      requestReading ["ep1", newEp1Ver, daily.date]
    else if ep2Ver /= newEp2Ver then 
      requestReading ["ep2", newEp2Ver, daily.date]
    else if eppVer /= newEppVer then
      requestReading ["epp", newEppVer, daily.date]
    else
      Cmd.none

changeEuLesson: Models.Sunday -> Models.Sunday -> Cmd Msg
changeEuLesson sunday newSunday =
  let 
    newOtVer = (List.head newSunday.ot |> Maybe.withDefault Models.initLesson).version
    newPsVer = (List.head newSunday.ps |> Maybe.withDefault Models.initLesson).version
    newNtVer = (List.head newSunday.nt |> Maybe.withDefault Models.initLesson).version
    newGsVer = (List.head newSunday.gs |> Maybe.withDefault Models.initLesson).version
    newOtAlt = (List.head newSunday.ot |> Maybe.withDefault Models.initLesson).altRead
    newNtAlt = (List.head newSunday.nt |> Maybe.withDefault Models.initLesson).altRead
    newGsAlt = (List.head newSunday.gs |> Maybe.withDefault Models.initLesson).altRead
    newOtCmd = (List.head newSunday.ot |> Maybe.withDefault Models.initLesson).cmd
    newNtCmd = (List.head newSunday.nt |> Maybe.withDefault Models.initLesson).cmd
    newGsCmd = (List.head newSunday.gs |> Maybe.withDefault Models.initLesson).cmd

    otVer = (List.head sunday.ot |> Maybe.withDefault Models.initLesson).version
    psVer = (List.head sunday.ps |> Maybe.withDefault Models.initLesson).version
    ntVer = (List.head sunday.nt |> Maybe.withDefault Models.initLesson).version
    gsVer = (List.head sunday.gs |> Maybe.withDefault Models.initLesson).version
    otAlt = (List.head sunday.ot |> Maybe.withDefault Models.initLesson).altRead
    ntAlt = (List.head sunday.nt |> Maybe.withDefault Models.initLesson).altRead
    gsAlt = (List.head sunday.gs |> Maybe.withDefault Models.initLesson).altRead
    otCmd = (List.head sunday.ot |> Maybe.withDefault Models.initLesson).cmd
    ntCmd = (List.head sunday.nt |> Maybe.withDefault Models.initLesson).cmd
    gsCmd = (List.head sunday.gs |> Maybe.withDefault Models.initLesson).cmd

  in
    if otVer /= newOtVer then
      requestReading ["ot", newOtVer, sunday.date]
    else if psVer /= newPsVer then 
      requestReading ["ps", newPsVer, sunday.date]
    else if ntVer /= newNtVer then
      requestReading ["nt", newNtVer, sunday.date]
    else if gsVer /= newGsVer then
      requestReading ["gs", newGsVer, sunday.date]
    else if otCmd /= newOtCmd then
      requestAltReading ["ot", newOtVer, otAlt]
    else if ntCmd /= newNtCmd then
      requestAltReading ["ot", newNtVer, ntAlt]
    else if gsCmd /= newGsCmd then
      requestAltReading ["gs", newGsVer, gsAlt]
    else
      Cmd.none



setLesson: Model -> String -> List Models.Lesson -> Model
setLesson model section lesson =
 let
    newModel = case section of
      "mp1" -> 
        let
          thisMP = model.mp
          newMP = {thisMP | mp1 = lesson}
          newModel = {model | mp = newMP}
        in
          newModel
      "mp2" -> 
        let
          thisMP = model.mp
          newMP = {thisMP | mp2 = lesson}
          newModel = {model | mp = newMP}
        in
          newModel
      "mpp" -> 
        let
          thisMP = model.mp
          newMP = {thisMP | mpp = lesson}
          newModel = {model | mp = newMP}
        in
          newModel
      "ep1" -> 
        let
          thisEP = model.ep
          newEP = {thisEP | ep1 = lesson}
          newModel = {model | ep = newEP}
        in
          newModel
      "ep2" -> 
        let
          thisEP = model.ep
          newEP = {thisEP | ep2 = lesson}
          newModel = {model | ep = newEP}
        in
          newModel
      "epp" -> 
        let
          thisEP = model.ep
          newEP = {thisEP | epp = lesson}
          newModel = {model | ep = newEP}
        in
          newModel
      "ot" -> 
        let
          thisEU = model.eu
          newEU = {thisEU | ot = lesson}
          newModel = {model | eu = newEU}
        in
          newModel
      "ps"  -> 
         let
           thisEU = model.eu
           newEU = {thisEU | ps = lesson}
           newModel = {model | eu = newEU}
         in
           newModel
      "nt"  -> 
         let
           thisEU = model.eu
           newEU = {thisEU | nt = lesson}
           newModel = {model | eu = newEU}
         in
           newModel
      "gs"  -> 
         let
           thisEU = model.eu
           newEU = {thisEU | gs = lesson}
           newModel = {model | eu = newEU}
         in
           newModel
           
      _   -> model
 in
   newModel


-- VIEW

view: Model -> Html Msg
view model =
  div [id "reading-container"]
    [ euDiv model
    , mpDiv model
    , epDiv model
    , reflectionDiv model
    ]

euDiv: Model -> Html Msg
euDiv model =
  div [ id "eu" ] [ App.map ModEU (Sunday.view model.eu) ]

mpDiv: Model -> Html Msg
mpDiv model =
  div [ id "mp" ]
  [ App.map ModMP (MPReading.view model.mp)
  ]

epDiv: Model -> Html Msg
epDiv model =
  div [ id "ep" ]
  [ App.map ModEP (EPReading.view model.ep)
  ]

reflectionDiv: Model -> Html Msg
reflectionDiv model =
  let
    author =  if String.length model.reflection.author > 0 
              then "--- " ++ model.reflection.author
              else ""
  in
    div []
    [ div [id "reflection"] [Markdown.toHtml [] model.reflection.markdown]
    , p [class "author"] [text author]
    ]
