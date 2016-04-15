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


-- UPDATE

type Section
  = OT
  | PS
  | NT
  | GS

type Action
  = NoOp
  | SetReading Model
  | ToggleShow Models.Lesson
  | ToggleModelShow
  | ToggleCollect

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
    ToggleCollect ->
      let
        collect = model.collect
        newCollect = {collect | show = not collect.show}
        newModel = {model | collect = newCollect}
      in
        newModel

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div
  []
  [ table [class "readings_table", tableStyle model]
      [ caption 
        [titleStyle model]
        [ span [onClick address ToggleModelShow] [text model.title]
        , br [] []
        , button 
          [ class "button"
          , onClick address ToggleCollect
          ] 
          [text "Collect"]
        ]
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
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading address model OT) ]
              -- [ ul [textStyle model] ( thisReading address model.ofType model.ot model.config.gs model.config.fnotes) ]
          , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading address model PS)]
              -- [ ul [textStyle model] ( thisReading address model.ofType model.ps model.config.gs model.config.fnotes) ]
           , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading address model NT)]
              -- [ ul [textStyle model] ( thisReading address model.ofType model.nt model.config.gs model.config.fnotes) ]
           , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading address model GS)]
          ] -- end of row
      ] -- end of table
    , div [] (thisText address model.ofType model.ot )
    , div [] (thisText address model.ofType model.ps )
    , div [] (thisText address model.ofType model.nt )
    , div [] (thisText address model.ofType model.gs )
    , div [ collectStyle model.collect ] (thisCollect address model.collect)

--    [ li [titleStyle model, onClick address ToggleModelShow] [text model.title]
 
  ] -- end of div 


-- HELPERS

thisCollect: Signal.Address Action -> Models.SundayCollect -> List Html
thisCollect address sundayCollect =
  let
    this_collect c = 
      p 
      [] 
      ([text c.collect] ++ List.map thisProper c.propers)
  in
    [ p 
        [class "collect_instruction"]
        [ text sundayCollect.instruction ]
    , button 
        [ class "collect_hide"
        , onClick address ToggleCollect
        ] 
        [text "hide"]
    , p
        [class "collect_title"]
        [ text sundayCollect.title ]
    , div
        [class "collect_text"]
        (List.map this_collect sundayCollect.collects)
    ]

thisProper: Models.Proper -> Html
thisProper proper =
  div []
      [ p [class "proper_title"] [text ("Proper: " ++ proper.title)]
      , p [class "proper_text"] [text proper.text]
      ]

thisText: Signal.Address Action -> String -> List Models.Lesson -> List Html
thisText address ofType lessons =
  let
    this_text l =
      let
        getTranslation s = 
          onClick getText.address [("ofType", ofType), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", s), ("fnotes", "fnotes")]
      in
        if l.section == "ps"
          then
            div [id l.id, bodyStyle l, class "esv_text"] 
               [ button 
                [ class "translationButton", getTranslation "Coverdale"]
                [text "Coverdale"]
               , button 
                [ class "translationButton", getTranslation "ESV"]
                [text "ESV"]
               , button 
                [ class "translationButton", getTranslation "BCP"]
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

thisReading: Signal.Address Action -> Model -> Section -> List Html
thisReading address model section =
  let
    lessons = case section of
      OT -> model.ot
      PS -> model.ps
      NT -> model.nt
      GS -> model.gs

    req l = case section of
      OT -> [("ofType", model.ofType), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.ot), ("fnotes", model.config.fnotes)]
      PS -> [("ofType", model.ofType), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.ps), ("fnotes", model.config.fnotes)]
      NT -> [("ofType", model.ofType), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.nt), ("fnotes", model.config.fnotes)]
      GS -> [("ofType", model.ofType), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", model.config.gs), ("fnotes", model.config.fnotes)]

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

-- thisReading: Signal.Address Action -> String -> List Models.Lesson -> String -> String -> List Html
-- thisReading address ofType lessons ver fnotes=
--   let
--     this_lesson l =
--       let
--         -- ver = if l.section == "mpp" || l.section == "epp" then "Coverdale" else "ESV"
--         req = [ofType, l.section, l.id, l.read, ver, fnotes]
-- 
--         -- ver = if l.section == "ps" then "Coverdale" else "ESV"
--       in
--         if String.length l.body == 0
--           then
--             li 
--               (hoverable [this_style l, onClick getText.address req] )
--               [text l.read]
--           else
--             li 
--               (hoverable [this_style l, onClick address (ToggleShow l)] )
--               [text l.read]
--   in
--     List.map this_lesson lessons
  
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
    , ("height", "2.3em")
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

collectStyle: Models.SundayCollect -> Attribute
collectStyle model =
  hideable
    model.show
    [ ("font-size", "1em")
    , ("background-color", "white")
    , ("margin", "0em")
    , ("padding", "0em")
    , ("list-style-type", "none")
    , ("display", "inline-block")
    ]



