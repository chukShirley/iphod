module Iphod.Sunday ( Model, init, Action, update, view,
                      textStyle) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Helper exposing (onClickLimited, hideable, getText)
import String exposing (join)
import Regex exposing (..)
import Markdown
import DynamicStyle exposing (hover, hover')
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

view: Signal.Address Action -> Model -> Html
view address model =
  div
  []
  [ table [tableStyle model]
      [ caption [titleStyle model, onClick address ToggleModelShow] [text model.title]
      , tr 
          [ rowStyle ]
          [ th [] [ text "1st Lesson"]
          , th [] [ text "Psalm"]
          , th [] [ text "2nd Lesson"]
          , th [] [ text "Gospel"]
          ]
      , tr
          [ rowStyle ]
          [ td 
              [tdStyle]
              [ ul [textStyle model] ( thisReading address model.ofType model.ot ) ]
          , td
              [tdStyle]
              [ ul [textStyle model] ( thisReading address model.ofType model.ps ) ]
           , td
              [tdStyle]
              [ ul [textStyle model] ( thisReading address model.ofType model.nt ) ]
           , td
              [tdStyle]
              [ ul [textStyle model] ( thisReading address model.ofType model.gs) ]
          ] -- end of row
      ] -- end of table
    , div [] (thisText model.ot)
    , div [] (thisText model.ps)
    , div [] (thisText model.nt)
    , div [] (thisText model.gs)

--    [ li [titleStyle model, onClick address ToggleModelShow] [text model.title]
 
  ] -- end of div 


-- HELPERS

thisText: List Models.Lesson -> List Html
thisText lessons =
  let
    this_text l =
      li [id l.id, bodyStyle l, class "esv_text"] [Markdown.toHtml l.body] -- place holder
  in
    List.map this_text lessons

thisReading: Signal.Address Action -> String -> List Models.Lesson -> List Html
thisReading address ofType lessons =
  let
    this_lesson l =
      if String.length l.body == 0
        then
          li 
            (hoverable [this_style l, onClick getText.address (ofType, l.section, l.id, l.read)] )
            [text l.read]
        else
          li 
            (hoverable [this_style l, onClick address (ToggleShow l)] )
            [text l.read]
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

hoverable: List Attribute -> List Attribute
hoverable attrs =
  hover [("background-color", "white", "skyblue")] ++ attrs
  


-- STYLE

tableStyle: Model -> Attribute
tableStyle model =
  hideable
    model.show
    [ ("width", "100%")]

rowStyle: Attribute
rowStyle =
  style [("text-align", "left")]

tdStyle: Attribute
tdStyle =
  style [("vertical-align", "top")]

bodyStyle: Models.Lesson -> Attribute
bodyStyle lesson =
  hideable
    lesson.show
    [ ("background-color", "white")
    ]

titleStyle: Model -> Attribute
titleStyle model =
  hideable
    model.show
    [ ("font-size", "0.9em")
    , ("color", "blue")
    , ("height", "2em")
    ]

textStyle: Model -> Attribute
textStyle model =
  hideable
    model.show
    [ ("font-size", "1em")
    , ("background-color", "white")
    , ("margin", "0em")
    , ("padding", "0em")
    , ("list-style-type", "none")
    , ("display", "inline-block")
    ]

req_style: Models.Lesson -> Attribute
req_style lesson =
  style
    [ ("color", "black")
    , ("background-color", "white")
    , ("display", "block")
    , ("padding","0 1em 0 1em")
    ]


opt_style: Models.Lesson -> Attribute
opt_style lesson =
  style
    [ ("color", "grey")
    , ("background-color", "white")
    , ("display", "block")
    , ("padding", "0 1em 0 1em")
    ]


alt_style: Models.Lesson -> Attribute
alt_style lesson =
  style
    [ ("color", "darkblue")
    , ("background-color", "white")
    , ("display", "block")
    , ("padding", "0 1em 0 1em")
    ]

altOpt_style: Models.Lesson -> Attribute
altOpt_style lesson =
  style
    [ ("color", "indego")
    , ("background-color", "white")
    , ("display", "block")
    , ("padding", "0 1em 0 1em")
    ]


bogis_style: Models.Lesson -> Attribute
bogis_style lesson =
  style
    [ ("color", "red")
    , ("background-color", "white")
    , ("display", "block")
    , ("padding", "0 1em 0 1em")
    ]


