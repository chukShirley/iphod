module Helper where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json


onClickLimited: Signal.Address a -> a -> Attribute
onClickLimited address msg =
  onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message address msg)

hideable: Bool -> List (String, String) -> Attribute
hideable show attr =
  if show then style attr else style [("display", "none")]

-- SIGNALS

getText : Signal.Mailbox (List (String, String))
getText =
  Signal.mailbox [] -- e.g. sunday, ot, Isaiah_52_13-53_12, Isaiah 52.13-53.12


