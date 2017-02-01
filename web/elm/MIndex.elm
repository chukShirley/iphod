port module MIndex exposing (..) -- where
import Debug

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json exposing ((:=))
import Platform.Sub as Sub exposing (batch, none)
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
  { config:     Models.Config
  , eu:         Models.Sunday
  , mp:         Models.DailyMP
  , ep:         Models.DailyEP
  , reflection: Models.Reflection
  , oneLesson:    List Models.Lesson
  }

initModel: Model
initModel =
  { config     = Models.configInit
  , eu         = Models.sundayInit
  , mp         = Models.initDailyMP
  , ep         = Models.initDailyEP
  , reflection = Models.initReflection
  , oneLesson     = []
  }

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)


-- REQUEST PORTS
port requestReading: List String -> Cmd msg
port requestAltReading: List String -> Cmd msg

-- SUBSCRIPTIONS


port portEU: (Models.Sunday -> msg) -> Sub msg

port portMP: (Models.DailyMP -> msg) -> Sub msg

port portEP: (Models.DailyEP -> msg) -> Sub msg

port portOneLesson: (List Models.Lesson -> msg) -> Sub msg

port portReflection: (Models.Reflection -> msg) -> Sub msg

port portReadings: (Models.Daily -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
--  Sub.none
  Sub.batch
--  [ portCalendar InitCalendar
  [ portEU UpdateEU
  , portMP UpdateMP
  , portEP UpdateEP
  , portOneLesson UpdateOneLesson
  , portReflection UpdateReflection
  ]


-- UODATE

type Msg
  = NoOp
  | UpdateEU Models.Sunday
  | UpdateMP Models.DailyMP
  | UpdateEP Models.DailyEP
  | UpdateReflection Models.Reflection
  | UpdateOneLesson (List Models.Lesson)
  | ModEU Sunday.Msg
  | ModMP MPReading.Msg
  | ModEP EPReading.Msg


update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of 
    NoOp -> (model, Cmd.none)

    UpdateEU eu -> 
      let
        tModel = initModel
        newEU = {eu | show = True}
        newModel = {tModel  | eu = newEU }
      in
        (newModel, Cmd.none)

    UpdateMP mp -> 
      let
        tModel = initModel
        newMP = {mp | show = True}
        newModel = {tModel  | mp = newMP }
      in
        (newModel, Cmd.none)

    UpdateEP ep -> 
      let
        tModel = initModel
        newEP = {ep | show = True}
        newModel = {tModel  | ep = newEP }
      in
        (newModel, Cmd.none)

    UpdateReflection reflection -> 
      let
        newModel = 
          {model  | reflection = reflection }
      in
        (newModel, Cmd.none)

    UpdateOneLesson lesson ->
      let
        tModel = initModel
        newModel = {tModel | oneLesson = lesson}
      in
        (newModel, Cmd.none)

    ModEU msg ->
      let
        newModel = {model | eu = Sunday.update msg model.eu}
      -- in 
      --   (newModel, Cmd.none)
        newCmd =
          let 
            otVer = (List.head newModel.eu.ot |> Maybe.withDefault Models.initLesson).version
            psVer = (List.head newModel.eu.ps |> Maybe.withDefault Models.initLesson).version
            ntVer = (List.head newModel.eu.nt |> Maybe.withDefault Models.initLesson).version
            gsVer = (List.head newModel.eu.gs |> Maybe.withDefault Models.initLesson).version
            otAlt = (List.head newModel.eu.ot |> Maybe.withDefault Models.initLesson).altRead
            ntAlt = (List.head newModel.eu.nt |> Maybe.withDefault Models.initLesson).altRead
            gsAlt = (List.head newModel.eu.gs |> Maybe.withDefault Models.initLesson).altRead
          in
            if otVer /= "" then
              requestReading ["ot", otVer, model.eu.date]
            else if psVer /= "" then 
              requestReading ["ps", psVer, model.eu.date]
            else if ntVer /= "" then
              requestReading ["nt", ntVer, model.eu.date]
            else if gsVer /= "" then
              requestReading ["gs", gsVer, model.eu.date]
            else if otAlt /= "" then
              requestAltReading ["ot", otVer, otAlt]
            else if ntAlt /= "" then
              requestAltReading ["ot", ntVer, ntAlt]
            else if gsAlt /= "" then
              requestAltReading ["gs", gsVer, gsAlt]
            else
              Cmd.none
      in 
        (newModel, newCmd)
      

    ModMP msg ->
      let
        newModel = {model | mp = MPReading.update msg model.mp}
      in 
        (newModel, Cmd.none)

    ModEP msg ->
      let
        newModel = {model | ep = EPReading.update msg model.ep}
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
  , reflectionDiv model
  , oneLessonDiv model
  ]


-- HELPERS

euDiv: Model -> Html Msg
euDiv model =
  div [] [ App.map ModEU (Sunday.view model.eu) ]

mpDiv: Model -> Html Msg
mpDiv model =
  div []
  [ App.map ModMP (MPReading.view model.mp)
  ]

epDiv: Model -> Html Msg
epDiv model =
  div []
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

oneLessonDiv: Model -> Html Msg
oneLessonDiv model =
  let
    putLesson l = p [] [Markdown.toHtml [] l.body]
  in
    div [] (List.map putLesson model.oneLesson)

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

