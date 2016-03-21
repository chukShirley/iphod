module Iphod.Sunday ( Model, init, Action, update, view,
                      textStyle) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Helper exposing (onClickLimited, hideable, getText)
import String exposing (join)
import Regex exposing (..)
import Markdown
import Iphod.Models as Models

-- MODEL

type alias Model = Models.Sunday

init: Model
init = Models.sundayInit

-- SIGNALS

-- getText : Signal.Mailbox (String, String, String, String)
-- getText =
--   Signal.mailbox ("", "", "", "") -- e.g. sunday, ot, Isaiah_52_13-53_12, Isaiah 52.13-53.12


-- UPDATE

type Action
  = NoOp
  | SetReading Model
  | ToggleShow Models.Lesson
  | ToggleModelShow

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    ToggleModelShow -> {model | show = not model.show}
    SetReading newModel -> newModel
    ToggleShow lesson ->
      let 
        this_section = case lesson.section of
          "ot" -> model.ot
          "ps" -> model.ps
          "nt" -> model.nt
          _    -> model.gs
        update_text this_lesson =
          if this_lesson.id == lesson.id 
            then 
              {this_lesson | show = not this_lesson.show}
            else 
              this_lesson
        newSection = List.map update_text this_section
        newModel = case lesson.section of
          "ot" -> {model | ot = newSection}
          "ps" -> {model | ps = newSection}
          "nt" -> {model | nt = newSection}
          _    -> {model | gs = newSection}
      in
        newModel

-- VIEW

view: Signal.Address Action -> Model -> List Html
view address model =
  [ li [titleStyle, onClick address ToggleModelShow] [text model.title]
  , ul [textStyle model] (thisReading address model.ot ++ thisText model.ot)
  , ul [textStyle model] (thisReading address model.ps ++ thisText model.ps)
  , ul [textStyle model] (thisReading address model.nt ++ thisText model.nt)
  , ul [textStyle model] (thisReading address model.gs ++ thisText model.gs)
  ]


-- HELPERS

thisText: List Models.Lesson -> List Html
thisText lessons =
  let
    this_text l =
      li [id l.id, bodyStyle l, class "esv_text"] [Markdown.toHtml l.body] -- place holder
  in
    List.map this_text lessons

thisReading: Signal.Address Action ->List Models.Lesson -> List Html
thisReading address lessons =
  let
    this_lesson l =
      if String.length l.body == 0
        then
          li [this_style l, onClick getText.address ("sunday", l.section, l.id, l.read)] [text l.read]
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

titleStyle: Attribute
titleStyle =
  style
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


