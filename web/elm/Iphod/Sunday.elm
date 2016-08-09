module Iphod.Sunday exposing ( Model, init, Msg, update, view, textStyle) -- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import String exposing (join)
import Regex exposing (..)
import Markdown

import Iphod.Helper exposing (hideable)
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

type Msg
  = NoOp
  | SetReading Model
  | GetText (List (String, String))
  | ChangeText String String
  | ToggleShow Models.Lesson
  | ToggleModelShow
  | ToggleCollect

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model

    ToggleModelShow -> {model | show = not model.show}

    SetReading newModel -> newModel

    GetText list -> model

    ChangeText section ver ->
      let
        newModel = case section of 
          "ot" -> {model | ot = changeText model ver model.ot}
          "ps" -> {model | ps = changeText model ver model.ps}
          "nt" -> {model | nt = changeText model ver model.nt}
          _    -> {model | gs = changeText model ver model.gs}
      in
        newModel

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


-- HELPERS

changeText: Model -> String -> List Models.Lesson -> List Models.Lesson
changeText model ver lessons =
  let 
    changeText lesson = {lesson | version = ver}
  in
    List.map changeText lessons


-- VIEW

view: Model -> Html Msg
view model =
  div
  []
  [ table [class "readings_table", tableStyle model]
      [ caption 
        [titleStyle model]
        [ span [onClick ToggleModelShow] [text model.title]
        , br [] []
        , button 
          [ class "button"
          , onClick ToggleCollect
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
              [ ul [textStyle model] ( thisReading model OT) ]
              -- [ ul [textStyle model] ( thisReading model.ofType model.ot model.config.gs model.config.fnotes) ]
          , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading model PS)]
              -- [ ul [textStyle model] ( thisReading model.ofType model.ps model.config.gs model.config.fnotes) ]
           , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading model NT)]
              -- [ ul [textStyle model] ( thisReading model.ofType model.nt model.config.gs model.config.fnotes) ]
           , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading model GS)]
          ] -- end of row
      ] -- end of table
    , div [] (thisText model model.ot )
    , div [] (thisText model model.ps )
    , div [] (thisText model model.nt )
    , div [] (thisText model model.gs )
    , div [ collectStyle model.collect ] (thisCollect model.collect)

--    [ li [titleStyle model, onClick ToggleModelShow] [text model.title]
 
  ] -- end of div 


-- HELPERS

thisCollect: Models.SundayCollect -> List (Html Msg)
thisCollect sundayCollect =
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
        , onClick ToggleCollect
        ] 
        [text "hide"]
    , p
        [class "collect_title"]
        [ text sundayCollect.title ]
    , div
        [class "collect_text"]
        (List.map this_collect sundayCollect.collects)
    ]

thisProper: Models.Proper -> Html Msg
thisProper proper =
  div []
      [ p [class "proper_title"] [text ("Proper: " ++ proper.title)]
      , p [class "proper_text"] [text proper.text]
      ]

thisText: Model -> List Models.Lesson -> List (Html Msg)
thisText model lessons =
  let
    this_text l =
      let
        getTranslation s = 
          onClick (GetText [("ofType", model.ofType), ("section", l.section), ("id", l.id), ("read", l.read), ("ver", s), ("fnotes", "True")])
      in
        if l.section == "ps"
          then
            div [id l.id, bodyStyle l, class "esv_text"] 
               [ span 
                  [ style [("position", "relative"), ("top", "1em")]]
                  [ button [ class "translationButton", onClick (ToggleShow l) ] [ text "Hide" ]
                  , button 
                     [ class "translationButton", getTranslation "Coverdale"]
                     [ text "Coverdale"]
                  , button 
                     [ class "translationButton", getTranslation "BCP"]
                     [ text "BCP"]
                  , versionSelect model l
                  ]
               , Markdown.toHtml [] l.body
               ]
          else
            div [id l.id, bodyStyle l, class "esv_text"] 
            [ span [style [("position", "relative"), ("top", "1em")]]
                [ button [class "translationButton", onClick (ToggleShow l)] [text "Hide"]
                , versionSelect model l
                ]
            , Markdown.toHtml [] l.body
            ]
  in
    List.map this_text lessons

thisReading: Model -> Section -> List (Html Msg)
thisReading model section =
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
            (hoverable [this_style l, onClick (GetText (req l))] )
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
  -- hover [("background-color", "white", "skyblue")] ++ attrs
  attrs
  
versionSelect: Model -> Models.Lesson -> Html Msg
versionSelect model lesson =
  let
    thisVersion ver =
      let
        foo = Debug.log "VERSION SELECT" (ver, lesson.version)
      in
        option [value ver, selected (ver == lesson.version)] [text ver]
      
  in
    select
      [ on "change" 
        (Json.map (ChangeText lesson.section) targetValue)
      ]
      (List.map thisVersion model.config.vers)



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
    [ ("background-color", "white") ]

titleStyle: Model -> Attribute msg
titleStyle model =
  hideable
    model.show
    [ ("font-size", "0.9em")
    , ("color", "blue")
    , ("height", "2.3em")
    ]

textStyle: Model -> Attribute msg
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

collectStyle: Models.SundayCollect -> Attribute msg
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



