module Iphod.Sunday exposing ( Model, init, Msg, update, view, textStyle) -- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import String exposing (join)
import Markdown
-- import Debug

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
  | UpdateAltReading Models.Lesson String
  | ChangeText String String
  | RequestAltReading Models.Lesson
  | ToggleShow Models.Lesson
  | ToggleModelShow
  | ToggleCollect

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model

    ToggleModelShow ->
      let
        newModel = {model | show = not model.show}
      in
        newModel

    SetReading newModel -> newModel

    ChangeText section ver ->
      let
        thisConfig = model.config
        thisRef = case section of
          "ot" -> getRef model.ot
          "ps" -> getRef model.ps
          "nt" -> getRef model.nt
          "gs" -> getRef model.gs
          _    -> ""

        thisUpdate = Models.setSectionUpdate section ver thisRef
        newConfig = case section of
          "ot" -> {thisConfig | ot = ver}
          "ps" -> {thisConfig | ps = ver}
          "nt" -> {thisConfig | nt = ver}
          "gs" -> {thisConfig | gs = ver}
          _    -> thisConfig

        newModel = case section of
          "ot" -> {model | ot = changeText model ver model.ot, sectionUpdate = thisUpdate, config = newConfig}
          "ps" -> {model | ps = changeText model ver model.ps, sectionUpdate = thisUpdate, config = newConfig}
          "nt" -> {model | nt = changeText model ver model.nt, sectionUpdate = thisUpdate, config = newConfig}
          _    -> {model | gs = changeText model ver model.gs, sectionUpdate = thisUpdate, config = newConfig}
      in
        newModel

    UpdateAltReading lesson str ->
      let
        this_section = thisSection model lesson
        update_altReading this_lesson =
          if this_lesson.id == lesson.id
            then
              {this_lesson | altRead = str}
            else
              this_lesson
        newSection = List.map update_altReading this_section
        newModel = updateModel model lesson newSection
      in
        newModel

    RequestAltReading lesson ->
      let
        thisUpdate = Models.setSectionUpdate lesson.section lesson.version lesson.altRead
        newLesson = [{lesson | cmd = "alt" ++ String.toUpper(lesson.section)}]
        newModel = case lesson.section of
          "ot" -> {model | ot = newLesson, sectionUpdate = thisUpdate}
          "ps" -> {model | ps = newLesson, sectionUpdate = thisUpdate}
          "nt" -> {model | nt = newLesson, sectionUpdate = thisUpdate}
          _    -> {model | gs = newLesson, sectionUpdate = thisUpdate}
      in
        newModel


    ToggleShow lesson ->
      let
        this_section = thisSection model lesson
        update_text this_lesson =
          if this_lesson.id == lesson.id
            then
              {this_lesson | show = not this_lesson.show}
            else
              this_lesson
        newSection = List.map update_text this_section
        newModel = updateModel model lesson newSection
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

getRef: List Models.Lesson -> String
getRef lessons =
  let
    justRefs l = l.read
  in
    List.map justRefs lessons |> String.join ","

changeText: Model -> String -> List Models.Lesson -> List Models.Lesson
changeText model ver lessons =
  let
    changeText lesson = {lesson | version = ver, cmd = "new" ++ String.toUpper(lesson.section)}
  in
    List.map changeText lessons

thisSection: Model -> Models.Lesson -> List Models.Lesson
thisSection model lesson =
  case lesson.section of
    "ot" -> model.ot
    "ps" -> model.ps
    "nt" -> model.nt
    _    -> model.gs

updateModel: Model -> Models.Lesson -> List Models.Lesson -> Model
updateModel model lesson newSection =
  case lesson.section of
    "ot" -> {model | ot = newSection}
    "ps" -> {model | ps = newSection}
    "nt" -> {model | nt = newSection}
    _    -> {model | gs = newSection}

-- VIEW

view: Model -> Html Msg
view model =
  div
  []
  [ table [class "readings_table", tableStyle model]
      [ caption
        [titleStyle model]
        [ span [onClick ToggleModelShow] [text model.title]
        , p []
          [ button [ class "button collect-button", onClick ToggleCollect]
            [text "Collect"]
          ]
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
          , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading model PS)]
           , td
              [class "tdStyle", style [("width", "20%")] ]
              [ ul [textStyle model] ( thisReading model NT)]
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
          onClick (ChangeText l.section s)
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
                , altReading model l
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

    ver = case section of
      OT -> model.config.ot
      PS -> model.config.ps
      NT -> model.config.nt
      GS -> model.config.gs
    this_lesson l =
      if String.length l.body == 0
        then
          li
            (hoverable [this_style l, onClick (ChangeText l.section ver)] )
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
      option [value ver, selected (ver == lesson.version)] [text ver]

  in
    select
      [ on "change"
        (Json.map (ChangeText lesson.section) targetValue)
      ]
      -- (List.map thisVersion model.config.vers)
      (List.map thisVersion (selections model lesson))

selections: Model -> Models.Lesson -> List String
selections model lesson =
  let
    this_ver =
      case lesson.section of
        "ot" -> model.config.ot
        "ps" -> model.config.ps
        "nt" -> model.config.nt
        "gs" -> model.config.nt
        _    -> model.config.current
  in
    this_ver :: model.config.vers

altReading: Model -> Models.Lesson -> Html Msg
altReading model lesson =
  input [ placeholder "Alt Reading"
        , autofocus True
        , value lesson.altRead
        , name "altReading"
        , onInput (UpdateAltReading lesson)
        , onEnter (RequestAltReading lesson)
        ]
        []

onEnter : Msg -> Attribute Msg
onEnter msg =
  let
    tagger code =
      if code == 13 then
        msg
      else
        NoOp
  in
    on "keydown" (Json.map tagger keyCode)


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
    , ("height", "3em")
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
