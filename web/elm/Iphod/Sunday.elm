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
  [ table [class "readings_table", tableStyle model]
      [ caption [titleStyle model, onClick address ToggleModelShow] [text model.title]
      , tr 
          [ class "rowStyle" ]
          [ th [] [ text "1st Lesson"]
          , th [] [ text "Psalm"]
          , th [] [ text "2nd Lesson"]
          , th [] [ text "Gospel"]
          ]
      , tr
          [ class "rowStyle" ]
          [ td 
              [class "tdStyle", style [("width", "25%")] ]
              [ ul [textStyle model] ( thisReading address model.ofType model.ot ) ]
          , td
              [class "tdStyle", style [("width", "25%")] ]
              [ ul [textStyle model] ( thisReading address model.ofType model.ps ) ]
           , td
              [class "tdStyle", style [("width", "25%")] ]
              [ ul [textStyle model] ( thisReading address model.ofType model.nt ) ]
           , td
              [class "tdStyle", style [("width", "25%")] ]
              [ ul [textStyle model] ( thisReading address model.ofType model.gs) ]
          ] -- end of row
      ] -- end of table
    , div [] (thisText address model.ofType model.ot)
    , div [] (thisText address model.ofType model.ps)
    , div [] (thisText address model.ofType model.nt)
    , div [] (thisText address model.ofType model.gs)

--    [ li [titleStyle model, onClick address ToggleModelShow] [text model.title]
 
  ] -- end of div 


-- HELPERS

thisText: Signal.Address Action -> String -> List Models.Lesson -> List Html
thisText address ofType lessons =
  let
    this_text l =
      if l.section == "ps"
        then
          div [id l.id, bodyStyle l, class "esv_text"] 
             [ button 
              [ class "translationButton"
              , onClick getText.address (ofType, l.section, l.id, l.read, "Coverdale")
              ] 
              [text "Coverdale"]
             , button 
              [ class "translationButton"
              , onClick getText.address (ofType, l.section, l.id, l.read, "ESV")
              ] 
              [text "ESV"]
             , button 
              [ class "translationButton"
              , onClick getText.address (ofType, l.section, l.id, l.read, "BCP")
              ] 
              [text "BCP"]
             , button [class "translationButton", onClick address (ToggleShow l)] [text "Hide"]
             , Markdown.toHtml l.body
             ]
        else
          div [id l.id, bodyStyle l, class "esv_text"] 
          [ button [class "translationButton", onClick address (ToggleShow l)] [text "Hide"]
          , Markdown.toHtml l.body
          ]
  in
    List.map this_text lessons

thisReading: Signal.Address Action -> String -> List Models.Lesson -> List Html
thisReading address ofType lessons =
  let
    this_lesson l =
      let
        ver = if l.section == "ps" then "Coverdale" else "ESV"
      in
        if String.length l.body == 0
          then
            li 
              (hoverable [this_style l, onClick getText.address (ofType, l.section, l.id, l.read, ver)] )
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
    "req"     -> class "req_style" 
    "opt"     -> class "opt_style"
    "alt"     -> class "alt_style"
    "alt-req" -> class "alt_style"
    "alt-opt" -> class "altOpt_style"
    _         -> class "bogis_style"

hoverable: List Attribute -> List Attribute
hoverable attrs =
  hover [("background-color", "white", "skyblue")] ++ attrs
  


-- STYLE

tableStyle: Model -> Attribute
tableStyle model =
  hideable
    model.show
    [ ("width", "100%")]

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


