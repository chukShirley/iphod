port module Translations exposing (..) -- where

-- import Debug

import Html exposing (..)
import Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex exposing (regex, contains, caseInsensitive)
import Json.Decode as Json

import Iphod.Helper exposing (hideable)


-- MAIN

main : Program Never Model Msg
main =
  Html.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }

-- MODEL

type alias Version =
  { id:       String
  , abbr:     String
  , name:     String
  , lang:     String
  , show:     Bool
  , selected: Bool
  }

initVersion: Version
initVersion =
  { id   = ""
  , abbr = ""
  , name = ""
  , lang = ""
  , show = False
  , selected = False
  }

type alias Model = List Version

init: (Model, Cmd Msg)
init = ([], Cmd.none)


port updateVersions: Version -> Cmd msg


port allVersions: (Model -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ allVersions AddModel ]

-- UPDATE

type Msg
  = NoOp
  | AddModel Model
  | Find String String
  | UseVersion Version

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)
    AddModel newModel -> (newModel, Cmd.none)
    Find col name ->
      let
        findThis ver =
          case col of
            "abbr"  ->
              if contains( caseInsensitive(regex name) ) ver.abbr
                then {ver | show = True}
                else {ver | show = False}
            "name"    ->
              if contains( caseInsensitive(regex name) ) ver.name
                then {ver | show = True}
                else {ver | show = False}
            _         -> -- language
              if contains( caseInsensitive(regex name) ) ver.lang
                then {ver | show = True}
                else {ver | show = False}

        newModel = List.map findThis model
      in
        (newModel, Cmd.none)

    UseVersion ver ->
      let
        newVer = {ver | selected = not ver.selected}
        selectModel this_model =
          if this_model.id == ver.id
            then {this_model | selected = newVer.selected}
            else this_model
        newModel = List.map selectModel model
      in
        (newModel, updateVersions newVer)


-- saveVersion: Version -> Effects Action
-- saveVersion ver =
--   let
--     saving = if ver.selected then "save" else "unsave"
--   in
--     Signal.send dbSaveVersion.address (saving, ver)
--     |> Task.toMaybe
--     |> Task.map (always NoOp)
--     |> Effects.task


-- VIEW

view: Model -> Html Msg
view model =
  let
    this_version ver =
      let
        using = if ver.selected then "Using" else "Use"
      in
        tr [ versionRow ver ]
          [ td [class "ver_abbr"] [text ver.abbr]
          , td [class "ver_name"] [text ver.name]
          , td [class "ver_language"] [text ver.lang]
          , td  [ class "ver_use"
                , onClick (UseVersion ver)
                ] [ button [] [text using] ]
          ]
  in
    div []
      [ h1 [] [text "Select Versions"]
      , table [class "versions"]
          [ thead []
              [ tr []
                  [ th [class "ver_abbr"] [text "Version"]
                  , th [class "ver_name"] [text "Version Name"]
                  , th [class "ver_language"] [text "Language"]
                  , th [class "ver_use"] [text "Select"]
                  ]
              , tr []
                  [ findVersion
                  , findName
                  , findLanguage
                  , td [class "ver_use"] [text "<<< Search"]
                  ]
              ]
          , tbody [] (List.map this_version model)
          ]
      ]

-- HELPERS


findVersion: Html Msg
findVersion  =
  th []
    [ input
        [ id "find_version"
        , type_ "text"
        , placeholder "Version"
        , autofocus True
        , name "find_version"
        , on "keyup" (Json.map (Find "abbr") targetValue)
        , onClick NoOp
        , style [("width", "90%")]
        ]
        []
    ]


findName: Html Msg
findName =
  th []
    [ input
        [ id "find_name"
        , type_ "text"
        , placeholder "Version Name"
        , autofocus True
        , name "find_name"
        , on "keyup" (Json.map (Find "name") targetValue)
        , onClick NoOp
        , style [("width", "90%")]
        ]
        []
    ]


findLanguage: Html Msg
findLanguage =
  th []
    [ input
        [ id "find_lang"
        , type_ "text"
        , placeholder "Language"
        , autofocus True
        , name "find_lang"
        , on "keyup" (Json.map (Find "lang") targetValue)
        , onClick NoOp
        , style [("width", "90%")]
        ]
        []
    ]


-- STYLE

versionRow: Version -> Attribute msg
versionRow model =
  let
    this_style =
      [ if model.selected
          then ("background-color", "lightgreen")
          else ("background-color", "white")
      ]
  in
    hideable model.show this_style
