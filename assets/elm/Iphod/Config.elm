module Iphod.Config exposing (..) -- where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onCheck, onClick, targetValue)
import Json.Decode as Json

import Iphod.Models exposing (Config, configInit)

-- MODEL

type alias Model = Config

init: Model
init = configInit


-- UPDATE

type Key
  = OT
  | PS
  | NT
  | GS
  | Current

type Msg
  = NoOp
  | Checked Key String
  | ChangeVersion String
  | ChangeFootnote Bool

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model

    Checked key val ->
      let
        newModel = case key of
          OT -> {model | ot = val}
          PS -> {model | ps = val}
          NT -> {model | nt = val}
          GS -> {model | gs = val}
          Current -> {model | current = val}
      in
        newModel

    ChangeVersion ver ->
      let
        newModel =
          { model | ot = ver
                  , ps = ver
                  , nt = ver
                  , gs = ver
                  , current = ver
          }
      in
        newModel

    ChangeFootnote bool -> {model | fnotes = if bool then "True" else "False"}


-- VIEW

view: Model -> Html Msg
view model =
  div
  [ class "config"]
  [ p
      []
      [ text "Psalms in: "
      , psRadio model PS "Coverdale"
      , psRadio model PS "ESV"
      , psRadio model PS "BCP"
      ]
  , p
      [style [("margin-left", "2em")]]
      [ text "FootNotes: "
      , ftnoteCheck model "fnotes"
      ]
  , p
      [style [("margin-left", "2em")]]
      [ text "Version: "
      , versionSelect model
      ]
  ]


-- HELPERS

versionSelect: Model -> Html Msg
versionSelect model =
  let
    thisVersion ver =
      option
        [ value ver
        , selected (ver == model.current)
        ]
        [text ver]
  in
    select [on "change" (Json.map ChangeVersion targetValue)] (List.map thisVersion model.vers)

psRadio: Model -> Key -> String -> Html Msg
psRadio model key val =
  let
    isSelected = model.ps == val
  in
    span [class "radio_button"]
    [ input
      [ type_ "radio"
      , checked isSelected
      , onCheck (\_ -> Checked key val)
      , name "psalm"
      , class "radio_button"
      , id val
      ] []
  , label [class "radio_label", for val] [text val]
  ]

ftnoteCheck: Model -> String -> Html Msg
ftnoteCheck model val =
  let
    isChecked = model.fnotes == "True"
  in
    span [class "config_checkbox"]
    [ input
      [ type_ "checkbox"
      , id val
      , checked isChecked, onCheck ChangeFootnote
      , name val
      , class "config_checkbox"
      ] []
    , label [class "checkbox_label", for val] [text "Show"]
    ]
