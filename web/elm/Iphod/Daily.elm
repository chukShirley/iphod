module Iphod.Daily (Model, init, Action, update, view, textStyle) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Helper exposing (onClickLimited, hideable, getText)
import String
import Markdown
import Iphod.Models as Models
import DynamicStyle exposing (hover)

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
          "mpp" -> model.mpp
          "ep1" -> model.ep1
          "ep2" -> model.ep2
          _     -> model.epp
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
          "mpp" -> {model | mpp = newSection}
          "ep1" -> {model | ep1 = newSection}
          "ep2" -> {model | ep2 = newSection}
          _     -> {model | epp = newSection}
      in
        newModel

view: Signal.Address Action -> Model -> Html
view address model =
  div
  []
  [ table [class "readings_table", tableStyle model]
      [ caption [titleStyle model, onClick address ToggleModelShow] [text ("Daily Office: " ++ model.title)] 
      , tr
          [ class "rowStyle" ]
          [ th [] [ text "Morning 1"]
          , th [] [ text "Morning 2"]
          , th [] [ text "Morning Ps"]
          , th [] [ text "Evening 1"]
          , th [] [ text "Evening 2"]
          , th [] [ text "Evening Ps"]
          ]
      , tr
          [ class "rowStyle" ]
          [ td 
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model.mp1 ) ]
          , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model.mp2 ) ]
          , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model.mpp ) ]
           , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model.ep1 ) ]
           , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model.ep2) ]
           , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model.epp) ]
          ] -- end of row
      ] -- end of table
    , div [] (thisText address model.mp1)
    , div [] (thisText address model.mp2)
    , div [] (thisText address model.mpp)
    , div [] (thisText address model.ep1)
    , div [] (thisText address model.ep2)
    , div [] (thisText address model.epp)
  ] -- end of div 


-- HELPERS

thisText: Signal.Address Action -> List Models.Lesson -> List Html
thisText address lessons =
  let
    this_text l =
      if l.section == "mpp" || l.section == "epp"
        then
          div [id l.id, bodyStyle l, class "esv_text"] 
             [ button 
              [ class "translationButton"
              , onClick getText.address ("daily", l.section, l.id, l.read, "Coverdale")
              ] 
              [text "Coverdale"]
             , button 
              [ class "translationButton"
              , onClick getText.address ("daily", l.section, l.id, l.read, "ESV")
              ] 
              [text "ESV"]
             , button 
              [ class "translationButton"
              , onClick getText.address ("daily", l.section, l.id, l.read, "BCP")
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



thisReading: Signal.Address Action ->List Models.Lesson -> List Html
thisReading address lessons =
  let
    this_lesson l =
      let
        ver = if l.section == "mpp" || l.section == "epp" then "Coverdale" else "ESV"
      in
        if String.length l.body == 0
          then
            li 
              ( hoverable [ this_style l, onClick getText.address ("daily", l.section, l.id, l.read, ver) ] )
              [text l.read]
          else
            li 
              ( hoverable [ this_style l , onClick address (ToggleShow l) ] )
              [ text l.read ]
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
    []

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
    , ("margin", "0")
    , ("padding", "0em")
    , ("list-style-type", "none")
    , ("display", "inline-block")
    ]


