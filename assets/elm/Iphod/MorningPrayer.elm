module Iphod.MorningPrayer exposing (Model, init, Msg, update, view)
import Html exposing (..)
import Html.Attributes exposing (..)
import String
import Markdown
import Regex exposing (split, regex)

import Iphod.Models as Models
import Iphod.Helper exposing (hideable)


-- MODEL

type alias Model = Models.Daily

init: Model
init = Models.dailyInit


-- UPDATE

type Msg
  = NoOp
  | Show
  | JustToday

update: Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model
    Show -> {model | show = not model.show}
    JustToday -> {model | justToday = not model.justToday}
