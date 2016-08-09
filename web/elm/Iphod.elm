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

-- requestReading: [Date, section, ver]
port requestReading: List String -> Cmd msg


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
        (newModel, Cmd.none)

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
        newCmd =
          let 
            otVer = (List.head newModel.eu.ot |> Maybe.withDefault Models.initLesson).version
            psVer = (List.head newModel.eu.ps |> Maybe.withDefault Models.initLesson).version
            ntVer = (List.head newModel.eu.nt |> Maybe.withDefault Models.initLesson).version
            gsVer = (List.head newModel.eu.gs |> Maybe.withDefault Models.initLesson).version
          in
            if otVer /= "" then
              requestReading ["ot", otVer, model.eu.date]
            else if psVer /= "" then 
              requestReading ["ps", psVer, model.eu.date]
            else if ntVer /= "" then
              requestReading ["nt", ntVer, model.eu.date]
            else if gsVer /= "" then
              requestReading ["gs", gsVer, model.eu.date]
            else
              Cmd.none
      in 
        (newModel, newCmd)

    ModMP msg ->
      let
        newModel = {model | mp = MPReading.update msg model.mp}
        newCmd =
          let 
            mp1Ver = (List.head newModel.mp.mp1 |> Maybe.withDefault Models.initLesson).version
            mp2Ver = (List.head newModel.mp.mp2 |> Maybe.withDefault Models.initLesson).version
            mppVer = (List.head newModel.mp.mpp |> Maybe.withDefault Models.initLesson).version
          in
            if mp1Ver /= "" then
              requestReading ["mp1", mp1Ver, model.mp.date]
            else if mp2Ver /= "" then 
              requestReading ["mp2", mp2Ver, model.mp.date]
            else if mppVer /= "" then
              requestReading ["mpp", mppVer, model.mp.date]
            else
              Cmd.none
      in 
        (newModel, newCmd)

    ModEP msg ->
      let
        newModel = {model | ep = EPReading.update msg model.ep}
        newCmd =
          let 
            ep1Ver = (List.head newModel.ep.ep1 |> Maybe.withDefault Models.initLesson).version
            ep2Ver = (List.head newModel.ep.ep2 |> Maybe.withDefault Models.initLesson).version
            eppVer = (List.head newModel.ep.epp |> Maybe.withDefault Models.initLesson).version
          in
            if ep1Ver /= "" then
              requestReading ["ep1", ep1Ver, model.ep.date]
            else if ep2Ver /= "" then 
              requestReading ["ep2", ep2Ver, model.ep.date]
            else if eppVer /= "" then
              requestReading ["epp", eppVer, model.ep.date]
            else
              Cmd.none
      in 
        (newModel, newCmd)
--    Top msg ->
--      { model | topCounter = Counter.update msg model.topCounter }

-- HELPERS

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
  div [] 
  [ euDiv model
  , mpDiv model
  , epDiv model
  , reflectionDiv model
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

reflectionDiv: Model -> Html Msg
reflectionDiv model =
  div []
  [ div [id "reflection"] [Markdown.toHtml [] model.reflection.markdown]
  , p [class "author"] [text ("--- " ++ model.reflection.author)]
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



