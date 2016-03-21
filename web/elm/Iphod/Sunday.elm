module Iphod.Sunday ( Model, Lesson, init, Action, update, view, getText,
                      textStyle) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Helper exposing (onClickLimited, hideable)
import String exposing (join)
import Regex exposing (..)
import Markdown

-- MODEL

type alias Lesson =
  { style:    String
  , show:     Bool
  , read:     String
  , body:     String
  , id:       String
  , section:  String
  }

type alias Model =
  { ofType:   String
  , date:     String
  , season:   String
  , week:     String
  , title:    String
  , ot:       List Lesson
  , ps:       List Lesson
  , nt:       List Lesson
  , gs:       List Lesson
}

init: Model
init =
  { ofType  = ""
  , date    = ""
  , season  = ""
  , week    = ""
  , title   = ""
  , ot      = []
  , ps      = []
  , nt      = []
  , gs      = []
  }


-- SIGNALS

getText : Signal.Mailbox (String, String, String, String)
getText =
  Signal.mailbox ("", "", "", "") -- e.g. sunday, ot, Isaiah_52_13-53_12, Isaiah 52.13-53.12


-- UPDATE

type Action
  = NoOp
  | SetReading Model
  | ToggleShow Lesson

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
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
  [ li [] [text model.title]
  , ul [textStyle] (thisReading address model.ot ++ thisText model.ot)
  , ul [textStyle] (thisReading address model.ps ++ thisText model.ps)
  , ul [textStyle] (thisReading address model.nt ++ thisText model.nt)
  , ul [textStyle] (thisReading address model.gs ++ thisText model.gs)
  ]


-- HELPERS

thisText: List Lesson -> List Html
thisText lessons =
  let
    this_text l =
      li [id l.id, bodyStyle l, class "esv_text"] [Markdown.toHtml l.body] -- place holder
  in
    List.map this_text lessons

thisReading: Signal.Address Action ->List Lesson -> List Html
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
  
this_style: Lesson -> Attribute
this_style l =
  case l.style of
    "req" -> req_style  l
    "opt" -> opt_style l
    "alt" -> alt_style l
    _     -> bogis_style l



-- STYLE

bodyStyle: Lesson -> Attribute
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

textStyle: Attribute
textStyle =
  style
    [ ("font-size", "0.8em")
    , ("margin", "0")
    ]

req_style: Lesson -> Attribute
req_style lesson =
  style
    [ ("color", "black")
    , ("display", "inline-block")
    , ("padding","0 1em 0 1em")
    ]


opt_style: Lesson -> Attribute
opt_style lesson =
  style
    [ ("color", "grey")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]


alt_style: Lesson -> Attribute
alt_style lesson =
  style
    [ ("color", "blue")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]


bogis_style: Lesson -> Attribute
bogis_style lesson =
  style
    [ ("color", "red")
    , ("display", "inline-block")
    , ("padding", "0 1em 0 1em")
    ]


