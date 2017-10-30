module Iphod.Helper exposing (..) -- where

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events exposing (onWithOptions)
-- import Json.Decode as Json


-- onClickLimited: a -> Attribute
-- onClickLimited msg =
--   onWithOptions "click" { stopPropagation = True, preventDefault = True } Json.value (\_ -> Signal.message msg)

hideable: Bool -> List (String, String) -> Attribute msg
hideable show attr =
  if show then style attr else style [("display", "none")]
