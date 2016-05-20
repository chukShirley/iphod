module Iphod.MPReading (Model, init, Action, update, view, textStyle) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import String
import Markdown
import DynamicStyle exposing (hover)

import Iphod.Models as Models
import Iphod.Config as Config
import Iphod.Helper exposing (onClickLimited, hideable, getText)

-- MODEL

type alias Model = Models.DailyMP

init: Model
init = Models.initDailyMP


-- UPDATE

type Section
  = MP1
  | MP2
  | MPP

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
          _     -> model.mpp
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
          _     -> {model | mpp = newSection}
      in
        newModel


-- VIEW


view: Signal.Address Action -> Model -> Html
view address model =
  div
  []
  [ table [class "readings_table", tableStyle model]
      [ caption [titleStyle model, onClick address ToggleModelShow] [text (String.join " " ["Evening Prayer:", model.date])] 
      , tr
          [ class "rowStyle" ]
          [ th [] [ text "Morning 1"]
          , th [] [ text "Morning 2"]
          , th [] [ text "Morning Ps"]
          ]
      , tr
          [ class "rowStyle" ]
          [ td 
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model MP1)]
              -- [ ul [textStyle model] ( thisReading address model.mp1 model.config.mp1 model.config.fnotes ) ]
          , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model MP2)]
              -- [ ul [textStyle model] ( thisReading address model.mp2 model.config.mp2 model.config.fnotes ) ]
          , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading address model MPP)]
              -- [ ul [textStyle model] ( thisReading address model.mpp model.config.mpp model.config.fnotes ) ]
          ] -- end of row
      ] -- end of table
    , div [] (thisText address model model.mp1)
    , div [] (thisText address model model.mp2)
    , div [] (thisText address model model.mpp)
  ] -- end of div 


-- HELPERS

thisText: Signal.Address Action -> Model -> List Models.Lesson -> List Html
thisText address model lessons =
  let
    this_text l =
      let
        getTranslation s = 
          onClick getText.address [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", s), ("fnotes", "fnotes")]
      in
        if l.section == "mpp" || l.section == "epp"
          then
            div [id l.id, bodyStyle l, class "esv_text"] 
               [ span
                  [ style [("position", "relative"), ("top", "1em")] ]
                  [ button [class "translationButton", onClick address (ToggleShow l)] [text "Hide"]
                  , button 
                     [ class "translationButton", getTranslation "Coverdale"]
                     [ text "Coverdale"]
                  , button 
                     [ class "translationButton", getTranslation "BCP"]
                     [ text "BCP"]
                  , versionSelect address model l
                  ]
               , Markdown.toHtml l.body
               ]
          else
            div [id l.id, bodyStyle l, class "esv_text"] 
            [ span [style [("position", "relative"), ("top", "1em")]]
                [ button [class "translationButton", onClick address (ToggleShow l)] [text "Hide"]
                , versionSelect address model l
                ]
            , Markdown.toHtml l.body
            ]
  in
    List.map this_text lessons

versionSelect: Signal.Address Action -> Model -> Models.Lesson -> Html
versionSelect address model lesson =
  let
    thisVersion ver =
      option [value ver, selected (ver == lesson.version)] [text ver]
  in
    select
      [ on "change" targetValue 
        (\resp -> Signal.message 
                  getText.address 
                  [("ofType", "daily"), ("section", lesson.section), ("id", lesson.id), ("read", lesson.read), ("ver", resp), ("fnotes", "fnotes")]
        )
      ]
      (List.map thisVersion model.config.vers)


thisReading: Signal.Address Action -> Model -> Section -> List Html
thisReading address model section =
  let
    lessons = case section of
      MP1 -> model.mp1
      MP2 -> model.mp2
      MPP -> model.mpp

    req l = case section of
      MP1 -> [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.ot), ("fnotes", model.config.fnotes)]
      MP2 -> [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.nt), ("fnotes", model.config.fnotes)]
      MPP -> [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.ps), ("fnotes", model.config.fnotes)]

    this_lesson l = 
      if String.length l.body == 0
        then
          li
            (hoverable [this_style l, onClick getText.address (req l)] )
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


