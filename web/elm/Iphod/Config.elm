module Iphod.Config where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Effects exposing (Effects, Never)
import String exposing (join)
import Json.Decode as Json
import Helper exposing (onClickLimited, hideable, getText)
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
  | Footnotes

type Action
  = NoOp
  | Change Key String

update: Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    Change key val -> 
      let
        foo = Debug.log "CHANGE" (key, val)
      in
        model

--      case key of
--        OT -> {model | ot = val}
--        PS -> {model | ps = val}
--        NT -> {model | nt = val}
--        GS -> {model | gs = val}
--        Footnotes -> {model | fnotes = (val == "True")}


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  div
    [ class "config"]
    [ text "Psalms in: "
    , psRadio address model PS "Coverdale"
    , psRadio address model PS "ESV"
    , psRadio address model PS "BCP"
    ]


-- HELPERS

psRadio: Signal.Address Action -> Model -> Key -> String -> Html
psRadio address model key val =
  span [class "radio_button"]
  [ input
      [ type' "radio"
      , id val
      , checked (model.ps == val)
      , on "change" targetChecked (\_ -> Signal.message address (Change key val))
      , name "psalm"
      , class "radio_button"
      ]
      []
  , label [class "radio_label", for val] [text val]
  ]
