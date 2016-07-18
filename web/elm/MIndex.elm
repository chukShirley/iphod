port module MIndex exposing (..) -- where
import Debug

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Regex
import Json.Decode as Json exposing ((:=))
import Platform.Sub as Sub exposing (batch, none)
import Platform.Cmd as Cmd exposing (Cmd)
import String exposing (join)
import Markdown

import Iphod.Helper exposing (hideable)
import Iphod.Models as Models
import Iphod.Sunday as Sunday
import Iphod.MPReading as MPReading
import Iphod.EPReading as EPReading


-- MAIN

main =
  App.program
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
  { today:      String
  , advent:     String
  , epiphany:   String
  , lent:       String
  , easter:     String
  , pentecost:  String
  , calendar:   Models.Daily
  , config:     Models.Config
  }

initModel: Model
initModel =
  { today      = ""
  , advent     = ""
  , epiphany   = ""
  , lent       = ""
  , easter     = ""
  , pentecost  = ""
  , calendar   = Models.dailyInit
  , config     = Models.configInit
  }

init: (Model, Cmd Msg)
init = (initModel, Cmd.none)


-- REQUEST PORTS


-- SUBSCRIPTIONS

port portCalendar: (Model -> msg) -> Sub msg

port portEU: (Models.Sunday -> msg) -> Sub msg

port portMP: (Models.DailyMP -> msg) -> Sub msg

port portEP: (Models.DailyEP -> msg) -> Sub msg

port portLesson: (List Models.Lesson -> msg) -> Sub msg

subscriptions: Model -> Sub Msg
subscriptions model =
  Sub.none
--  Sub.batch
--  [ portCalendar InitCalendar
--  , portEU UpdateEU
--  , portMP UpdateMP
--  , portEP UpdateEP
--  , portLesson UpdateLesson
--  ]


-- UODATE

type Msg
  = NoOp
  | Advent
  | Christmas
  | Epiphany
  | Lent
  | Easter
  | Pentecost

update: Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of 
    NoOp -> (model, Cmd.none)

    Advent -> (model, Cmd.none)

    Christmas -> (model, Cmd.none)

    Epiphany -> (model, Cmd.none)

    Lent -> (model, Cmd.none)

    Easter -> (model, Cmd.none)

    Pentecost -> (model, Cmd.none)


-- VIEW

view: Model -> Html Msg
view model =
  div []
  [ text "Date Picker"
  , (options1 model)
  , (seasons model)
  -- , (mCalendar model)
  -- , (the_texts model)
  ]


-- HELPERS

options1: Model -> Html Msg
options1 model =
  let 
    foo = Debug.log "OPTIONS 1" model
    mp = "/morningPrayer/" ++ model.config.ps
    ep = "/eveningPrayer/" ++ model.config.ps
    reflection = ""
  in  
    div [class "m-options1"]
    [ ul []
      [ (li_a_button mp "Morning Prayer")
      , (li_a_button reflection "Reflection")
      , (li_a_button ep "Evening Prayer")
      ]
    ]

seasons: Model -> Html Msg
seasons model =
  div [class "m-seasons"]
  [ ul []
    [ (li_button model Advent "Advent")
    , (li_button model Christmas "Christmas")
    , (li_button model Epiphany "Epiphany")
    , (li_button model Lent "Lent")
    , (li_button model Easter "Easter")
    , (li_button model Pentecost "Pentecost")
    ]
  ]

li_a_button: String -> String -> Html Msg
li_a_button ref label =
  li []
  [ a [ href ref ]
    [ button [] [ text label ] ]
  ]

li_button: Model -> Msg -> String -> Html Msg
li_button model msg label =
  li []
  [ button [onClick msg] [text label]
  ]


