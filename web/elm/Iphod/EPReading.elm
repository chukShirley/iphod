module Iphod.EPReading exposing (Model, init, Msg, update, view, textStyle) -- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Json
import Http
import String
import Markdown

import Iphod.Models as Models
import Iphod.Config as Config
import Iphod.Helper exposing (hideable)

-- MODEL

type alias Model = Models.DailyEP

init: Model
init = Models.initDailyEP


-- UPDATE

type Section
  = EP1
  | EP2
  | EPP

type Msg 
  = NoOp
  | GetText List (String, String)
  | ToggleModelShow
  | ToggleShow Models.Lesson
  | SetReading Model

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model

    GetText list ->
      let
        foo = "EP GETTEXT" list
      in
       model

    ToggleModelShow -> {model | show = not model.show}

    SetReading newModel -> newModel

    ToggleShow lesson ->
      let 
        this_section = case lesson.section of
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
          "ep1" -> {model | ep1 = newSection}
          "ep2" -> {model | ep2 = newSection}
          _     -> {model | epp = newSection}
      in
        newModel


-- VIEW


view: Model -> Html Msg
view model =
  div
  []
  [ table [class "readings_table", tableStyle model]
      [ caption [titleStyle model, onClick ToggleModelShow] [text (String.join " " ["Evening Prayer:", model.date])] 
      , tr
          [ class "rowStyle" ]
          [ th [] [ text "Evening 1"]
          , th [] [ text "Evening 2"]
          , th [] [ text "Evening Ps"]
          ]
      , tr
          [ class "rowStyle" ]
          [ td 
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading model EP1)]
              -- [ ul [textStyle model] ( thisReading model.ep1 model.config.ep1 model.config.fnotes ) ]
          , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading model EP2)]
              -- [ ul [textStyle model] ( thisReading model.ep2 model.config.ep2 model.config.fnotes ) ]
          , td
              [class "tdStyle", style [("width", "16%")] ]
              [ ul [textStyle model] ( thisReading model EPP)]
              -- [ ul [textStyle model] ( thisReading model.epp model.config.epp model.config.fnotes ) ]
          ] -- end of row
      ] -- end of table
    , div [] (thisText model model.ep1)
    , div [] (thisText model model.ep2)
    , div [] (thisText model model.epp)
  ] -- end of div 


-- HELPERS

thisText: Model -> List Models.Lesson -> (List Html msg)
thisText model lessons =
  let
    this_text l =
      let
        getTranslation s = 
          onClick GetText [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", s), ("fnotes", True)]
      in
        if l.section == "epp" || l.section == "epp"
          then
            div [id l.id, bodyStyle l, class "esv_text"] 
               [ span
                  [ style [("position", "relative"), ("top", "1em")] ]
                  [ button [class "translationButton", onClick (ToggleShow l)] [text "Hide"]
                  , button 
                     [ class "translationButton", getTranslation "Coverdale"]
                     [ text "Coverdale"]
                  , button 
                     [ class "translationButton", getTranslation "BCP"]
                     [ text "BCP"]
                  , versionSelect model l
                  ]
               , Markdown.toHtml l.body
               ]
          else
            div [id l.id, bodyStyle l, class "esv_text"] 
            [ span [style [("position", "relative"), ("top", "1em")]]
                [ button [class "translationButton", onClick (ToggleShow l)] [text "Hide"]
                , versionSelect model l
                ]
            , Markdown.toHtml l.body
            ]
  in
    List.map this_text lessons

versionSelect: Model -> Models.Lesson -> Html Msg
versionSelect model lesson =
  let
    thisVersion ver =
      option [value ver, selected (ver == lesson.version)] [text ver]
  in
    select
      [ on "change" 
        ( Json.succeed
          ( GetText 
            [ ("ofType", "daily")
            , ("section", lesson.section)
            , ("id", lesson.id)
            , ("read", lesson.read)
            , ("ver", thisVersion model.config.vers)
            , ("fnotes", True)
            ]
          )
        )
      ]
      (List.map thisVersion model.config.vers)


thisReading: Model -> Section -> List (Html Msg)
thisReading model section =
  let
    lessons = case section of
      EP1 -> model.ep1
      EP2 -> model.ep2
      EPP -> model.epp

    req l = case section of
      EP1 -> [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.ot), ("fnotes", model.config.fnotes)]
      EP2 -> [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.nt), ("fnotes", model.config.fnotes)]
      EPP -> [("ofType", "daily"), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.ps), ("fnotes", model.config.fnotes)]

    this_lesson l = 
      if String.length l.body == 0
        then
          li
            (hoverable [this_style l, onClick GetText (req l)] )
            [text l.read]
        else
          li 
            (hoverable [this_style l, onClick (ToggleShow l)] )
            [text l.read]
  in
    List.map this_lesson lessons



this_style: Models.Lesson -> Attribute msg
this_style l =
  case l.style of
    "req"     -> class "req_style"
    "opt"     -> class "opt_style"
    "alt"     -> class "alt_style"
    "alt-req" -> class "alt_style"
    "alt-opt" -> class "altOpt_style"
    _         -> class "bogis_style"

hoverable: List (Attribute msg) -> List (Attribute msg)
hoverable attrs =
  hover [("background-color", "white", "skyblue")] ++ attrs
  



-- STYLE

tableStyle: Model -> Attribute msg
tableStyle model =
  hideable
    model.show
    [ ("width", "100%")]


bodyStyle: Models.Lesson -> Attribute msg
bodyStyle lesson =
  hideable
    lesson.show
    []

titleStyle: Model -> Attribute msg
titleStyle model =
  hideable
    model.show
    [ ("font-size", "0.9em")
    , ("color", "blue")
    , ("height", "2em")
    ]

textStyle: Model -> Attribute msg
textStyle model =
  hideable
    model.show
    [ ("font-size", "1em")
    , ("margin", "0")
    , ("padding", "0em")
    , ("list-style-type", "none")
    , ("display", "inline-block")
    ]


