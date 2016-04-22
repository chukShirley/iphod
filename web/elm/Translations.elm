module Translations where

import Debug

import StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import Task exposing (Task)
import Helper exposing (onClickLimited, hideable, getText)
import Regex exposing (regex, contains, caseInsensitive)


app = 
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [incomingVersion]
    }

-- MAIN
main: Signal Html
main =
  app.html

port tasks: Signal (Task Never ())
port tasks =
  app.tasks

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

init: (Model, Effects Action)
init = ([], Effects.none)

-- SIGNALS

incomingVersion: Signal Action
incomingVersion =
  Signal.map AddModel allVersions


-- PORTS

port allVersions: Signal Model


-- UPDATE

type Action
  = NoOp
  | AddModel Model
  | Find String String

update: Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> (model, Effects.none)
    AddModel newModel -> (newModel, Effects.none)
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
              -- (findVer ver ver.lang name)
              if contains( caseInsensitive(regex name) ) ver.lang
                then {ver | show = True}
                else {ver | show = False}

        newModel = List.map findThis model
      in
        (newModel, Effects.none)

-- findVer: Version -> String -> String -> Version
-- findVer ver col reg =
--   if contains( caseInsensitive(regex reg) ) col
--     then {ver | show = True}
--     else {ver | show = False}

-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  let
    this_version ver =
      let
        using = if ver.selected then "Using" else "Use"
      in
        tr [ versionRow ver ]
          [ td [class "ver_abbr"] [text ver.abbr]
          , td [class "ver_name"] [text ver.name]
          , td [class "ver_language"] [text ver.lang]
          , td [class "ver_use"] [ button [] [text using] ]
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
                  [ findVersion address 
                  , findName address 
                  , findLanguage address 
                  , td [class "ver_use"] [text "<<< Search"]
                  ]
              ]
          , tbody [] (List.map this_version model)
          ]
      ]

-- HELPERS


findVersion: Signal.Address Action  -> Html
findVersion address  =
  th []
    [ input 
        [ id "find_version"
        , type' "text"
        , placeholder "Version"
        , autofocus True
        , name "find_version"
        , on "keyup" targetValue (\str -> Signal.message address (Find "abbr" str))
        , onClickLimited address NoOp
        , style [("width", "90%")]
        ]
        []
    ]


findName: Signal.Address Action -> Html
findName address  =
  th []
    [ input 
        [ id "find_name"
        , type' "text"
        , placeholder "Version Name"
        , autofocus True
        , name "find_name"
        , on "keyup" targetValue (\str -> Signal.message address (Find "name" str))
        , onClickLimited address NoOp
        , style [("width", "90%")]
        ]
        []
    ]


findLanguage: Signal.Address Action -> Html
findLanguage address =
  th []
    [ input 
        [ id "find_lang"
        , type' "text"
        , placeholder "Language"
        , autofocus True
        , name "find_lang"
        , on "keyup" targetValue (\str -> Signal.message address (Find "lang" str))
        , onClickLimited address NoOp
        , style [("width", "90%")]
        ]
        []
    ]


-- STYLE

selectedStyle: Version -> Attribute
selectedStyle model =
  if model.selected
    then style [("background-color", "lightgreen")]
    else style [("background-color", "none")]

versionRow: Version -> Attribute
versionRow model =
  let
    this_style = 
      [ if model.selected
          then ("background-color", "lightgreen")
          else ("background-color", "none")
      ]
  in
    hideable model.show this_style
    







