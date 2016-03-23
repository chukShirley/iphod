module Iphod.Daily (Model, init, Action, update, view, textStyle) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Helper exposing (onClickLimited, hideable, getText)
import String
import Markdown
import Iphod.Models as Models

-- MODEL

type alias Model = Models.Daily

init: Model
init = Models.dailyInit


-- SIGNALS

-- getText : Signal.Mailbox (String, String, String, String)
-- getText =
--   Signal.mailbox ("", "", "", "") -- e.g. sunday, ot, Isaiah_52_13-53_12, Isaiah 52.13-53.12


-- UPDATE

type Action 
  = NoOp
  | ToggleModelShow
  | ToggleShow Models.Lesson
  | SetReading Model

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ToggleModelShow -> {model | show = not model.show}
    SetReading newModel -> newModel
    ToggleShow lesson ->
      let 
        this_section = case lesson.section of
          "mp1" -> model.mp1
          "mp2" -> model.mp2
          "ep1" -> model.ep1
          _     -> model.ep2
        update_text this_lesson =
          if this_lesson.id == lesson.id 
            then 
              {this_lesson | show = not this_lesson.show}
            else 
              this_lesson
        newSection = List.map update_text this_section
        newModel = case lesson.section of
          "mp1" -> {model | mp1 = newSection}
          "mp2" -> {model | mp2 = newSection}
          "ep1" -> {model | ep1 = newSection}
          _     -> {model | ep2 = newSection}
      in
        newModel

view: Signal.Address Action -> Model -> List Html
view address model =
  [ li [titleStyle model, onClick address ToggleModelShow] [text model.title]
  , ul [textStyle model] ([text "Morning 1: "] ++ thisReading address model.mp1 ++ thisText model.mp1)
  , ul [textStyle model] ([text "Morning 2: "] ++ thisReading address model.mp2 ++ thisText model.mp2)
  , ul [textStyle model] ([text "Evening 1: "] ++ thisReading address model.ep1 ++ thisText model.ep1)
  , ul [textStyle model] ([text "Evening 2: "] ++ thisReading address model.ep2 ++ thisText model.ep2)
  ]


-- HELPERS

thisText: List Models.Lesson -> List Html
thisText lessons =
  let
    this_text l =
      li [id l.id, bodyStyle l, class "esv_text"] [Markdown.toHtml l.body]
  in
    List.map this_text lessons

thisReading: Signal.Address Action ->List Models.Lesson -> List Html
thisReading address lessons =
  let
    this_lesson l =
      if String.length l.body == 0
        then
          li [this_style l, onClick getText.address ("daily", l.section, l.id, l.read)] [text l.read]
        else
          li [this_style l, onClick address (ToggleShow l)] [text l.read]
  in
    List.map this_lesson lessons
  
this_style: Models.Lesson -> Attribute
this_style l =
  case l.style of
    "req"     -> req_style  l
    "opt"     -> opt_style l
    "alt"     -> alt_style l
    "alt-req" -> alt_style l
    "alt-opt" -> altOpt_style l
    _         -> bogis_style l



-- STYLE
 
bodyStyle: Models.Lesson -> Attribute
bodyStyle lesson =
  hideable
    lesson.show
    []

titleStyle: Model -> Attribute
titleStyle model =
  hideable
    model.show
    [ ("font-size", "0.8em")
    , ("color", "blue")
    , ("height", "2em")
    ]

textStyle: Model -> Attribute
textStyle model =
  hideable
    model.show
    [ ("font-size", "0.8em")
    , ("margin", "0")
    ]

req_style: Models.Lesson -> Attribute
req_style lesson =
  style
    [ ("color", "black")
    , ("display", "inline-block")
    , ("padding","0 1em 0 1em")
    ]


opt_style: Models.Lesson -> Attribute
opt_style lesson =
  style
    [ ("color", "grey")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]


alt_style: Models.Lesson -> Attribute
alt_style lesson =
  style
    [ ("color", "darkblue")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]

altOpt_style: Models.Lesson -> Attribute
altOpt_style lesson =
  style
    [ ("color", "indego")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]


bogis_style: Models.Lesson -> Attribute
bogis_style lesson =
  style
    [ ("color", "red")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]


